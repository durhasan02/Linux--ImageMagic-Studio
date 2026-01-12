#!/bin/bash

# ImageMagic Studio - TUI Version

# Gerekli araçları kontrol et
check_dependencies() {
    local missing_deps=()
    # Araçları tek tek kontrol et, eksik olanları diziye ekle
    command -v whiptail >/dev/null 2>&1 || missing_deps+=("whiptail")
    command -v convert >/dev/null 2>&1 || missing_deps+=("imagemagick")
    command -v identify >/dev/null 2>&1 || missing_deps+=("imagemagick")
    # Eğer eksik bağımlılık varsa hata mesajı bas ve programdan çık
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}Eksik bağımlılıklar: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}Kurulum için: sudo apt install imagemagick whiptail${NC}"
        exit 1
    fi
}

# Global değişkenler
SELECTED_IMAGE=""
OUTPUT_DIR="$HOME/ImageMagic-Output"
mkdir -p "$OUTPUT_DIR"

# Terminal boyutları
TERM_HEIGHT=$(tput lines)
TERM_WIDTH=$(tput cols)
MENU_HEIGHT=20
MENU_WIDTH=70


# YARDIMCI FONKSİYONLAR

show_message() {
    whiptail --title "$1" --msgbox "$2" 10 60
}
show_error() {
    whiptail --title "Hata" --msgbox "$1" 10 60
}
show_success() {
    whiptail --title "Başarılı" --msgbox "$1" 10 60
}
show_info() {
    whiptail --title "Bilgi" --msgbox "$1" 15 70
}
# Dosya seçici
select_file() {
    local dir="${1:-$HOME}" # Eğer dizin verilmezse başlangıç Ev dizini olsun.
    
    # resimlerin bulunduğu dizin yolunun girilmesi istenir
    dir=$(whiptail --title "Dizin Seçin" --inputbox "Resimlerin bulunduğu dizin:" 12 70 "$dir" 3>&1 1>&2 2>&3)
    # İptal veya boş giriş kontrolü
    if [ $? -ne 0 ] || [ -z "$dir" ]; then
        return 1
    fi

    # ls ve grep kullanarak resim dosyalarını listele.
    local file_list=()
    while IFS= read -r line; do
        file_list+=("$line" "") # whiptail her öğe için bir etiket ve açıklama bekler.
    done < <(ls -p "$dir" | grep -v / | grep -E '\.(jpg|jpeg|png|gif|webp|bmp|JPG|PNG)$')
    local selected_file
    # eğer resim bulunamazsa uyarı verir
    if [ ${#file_list[@]} -eq 0 ]; then
        whiptail --title "Hata" --msgbox "Bu dizinde desteklenen resim dosyası bulunamadı!" 10 60
        return 1
    fi

    #  Whiptail Menü ile dosyayı seçtir.
    local selected_file
    selected_file=$(whiptail --title "Dosya Seçin" --menu "İşlem yapılacak resmi seçin:" 20 70 10 "${file_list[@]}" 3>&1 1>&2 2>&3)
    # seçilen resmin tam yolunu global değişkene kaydeder
    if [ $? -eq 0 ]; then
        SELECTED_IMAGE="$dir/$selected_file"
        whiptail --title "Başarılı" --msgbox "Seçilen: $selected_file" 10 60
        return 0
    fi
    return 1
}

# Dizin seçici
select_directory() {
    local dir
    dir=$(whiptail --title "Dizin Seçin" --inputbox "Dizin yolu girin:" 10 60 "$HOME" 3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ] && [ -d "$dir" ]; then
        echo "$dir"
        return 0
    else
        return 1
    fi
}

# RESİM BİLGİLERİ
show_image_info() {
    if [ -z "$SELECTED_IMAGE" ]; then
        show_error "Önce bir resim seçmelisiniz!"
        return 1
    fi
    
    local format=$(identify -format "%m" "$SELECTED_IMAGE")
    local width=$(identify -format "%w" "$SELECTED_IMAGE")
    local height=$(identify -format "%h" "$SELECTED_IMAGE")
    local size=$(du -h "$SELECTED_IMAGE" | cut -f1)
    local colorspace=$(identify -format "%[colorspace]" "$SELECTED_IMAGE")
    local filename=$(basename "$SELECTED_IMAGE")
    
    local info="Dosya: $filename
Format: $format
Boyut: ${width}x${height} piksel
Dosya Boyutu: $size
Renk Uzayı: $colorspace
Tam Yol: $SELECTED_IMAGE"
    
    show_info "$info"
}

# FORMAT DÖNÜŞTÜRME
convert_format() {
    if [ -z "$SELECTED_IMAGE" ]; then
        show_error "Önce bir resim seçmelisiniz!"
        return 1
    fi
    # Hedef format seçimi
    local format 
    format=$(whiptail --title "Format Seçin" --menu "Hedef format:" 15 60 6 \
        "PNG" "PNG Format" \
        "JPG" "JPEG Format" \
        "WEBP" "WebP Format" \
        "BMP" "Bitmap Format" \
        "GIF" "GIF Format" \
        "TIFF" "TIFF Format" \
        3>&1 1>&2 2>&3)
    
    [ $? -ne 0 ] && return 1
    # Kalite değeri girişi
    local quality
    quality=$(whiptail --title "Kalite" --inputbox "Kalite (1-100):" 10 60 "90" 3>&1 1>&2 2>&3)
    
    [ $? -ne 0 ] && return 1
    
    local basename=$(basename "$SELECTED_IMAGE" | sed 's/\.[^.]*$//')
    local output="$OUTPUT_DIR/${basename}.${format,,}"
    # Dönüştürme işlemini yaparken ilerleme çubuğu gösterir
    convert "$SELECTED_IMAGE" -quality "$quality" "$output" 2>&1 | \
        whiptail --title "Dönüştürme" --gauge "İşleniyor..." 7 60 0
    
    if [ -f "$output" ]; then
        show_success "Resim başarıyla dönüştürüldü!\n\nKonum: $output"
    else
        show_error "Dönüştürme sırasında hata oluştu!"
    fi
}

# BOYUTLANDIRMA
resize_image() {
    if [ -z "$SELECTED_IMAGE" ]; then
        show_error "Önce bir resim seçmelisiniz!"
        return 1
    fi
    local current_width=$(identify -format "%w" "$SELECTED_IMAGE")
    local current_height=$(identify -format "%h" "$SELECTED_IMAGE")
    
    local method
    method=$(whiptail --title "Boyutlandırma Yöntemi" --menu "Yöntem seçin:" 15 60 3 \
        "1" "Piksel Bazlı" \
        "2" "Yüzde Bazlı" \
        "3" "Hazır Boyutlar" \
        3>&1 1>&2 2>&3)
    
    [ $? -ne 0 ] && return 1
    
    local resize_param=""
    
    case "$method" in
        "1")
            local width
            width=$(whiptail --title "Genişlik" --inputbox "Yeni genişlik (piksel):" 10 60 "$current_width" 3>&1 1>&2 2>&3)
            [ $? -ne 0 ] && return 1
            
            local height
            height=$(whiptail --title "Yükseklik" --inputbox "Yeni yükseklik (piksel):" 10 60 "$current_height" 3>&1 1>&2 2>&3)
            [ $? -ne 0 ] && return 1
            
            if whiptail --title "Oran Koru" --yesno "En-boy oranını korumak istiyor musunuz?" 10 60; then
                resize_param="${width}x${height}"
            else
                resize_param="${width}x${height}!"
            fi
            ;;
        "2")
            local percent
            percent=$(whiptail --title "Yüzde" --inputbox "Yüzde değeri (örn: 50):" 10 60 "50" 3>&1 1>&2 2>&3)
            [ $? -ne 0 ] && return 1
            resize_param="${percent}%"
            ;;
        "3")
            local preset
            preset=$(whiptail --title "Hazır Boyut" --menu "Boyut seçin:" 18 70 10 \
                "1" "Instagram Kare (1080x1080)" \
                "2" "Instagram Dikey (1080x1350)" \
                "3" "HD (1920x1080)" \
                "4" "4K (3840x2160)" \
                "5" "Facebook Kapak (820x312)" \
                3>&1 1>&2 2>&3)
            
            [ $? -ne 0 ] && return 1
            
            case "$preset" in
                "1") resize_param="1080x1080" ;;
                "2") resize_param="1080x1350" ;;
                "3") resize_param="1920x1080" ;;
                "4") resize_param="3840x2160" ;;
                "5") resize_param="820x312!" ;;
            esac
            ;;
    esac
    
    local basename=$(basename "$SELECTED_IMAGE")
    local output="$OUTPUT_DIR/resized_${basename}"
    
    convert "$SELECTED_IMAGE" -resize "$resize_param" "$output" 2>&1 | \
        whiptail --title "Boyutlandırma" --gauge "İşleniyor..." 7 60 0
    
    if [ -f "$output" ]; then
        show_success "Resim başarıyla boyutlandırıldı!\n\nKonum: $output"
    else
        show_error "Boyutlandırma sırasında hata oluştu!"
    fi
}

# DÖNDÜRME & ÇEVİRME
rotate_flip() {
    if [ -z "$SELECTED_IMAGE" ]; then
        show_error "Önce bir resim seçmelisiniz!"
        return 1
    fi
    
    local operation
    operation=$(whiptail --title "Döndürme/Çevirme" --menu "İşlem seçin:" 18 70 8 \
        "1" "90° Sağa Döndür" \
        "2" "180° Döndür" \
        "3" "270° Sağa Döndür (90° Sola)" \
        "4" "Yatay Çevir" \
        "5" "Dikey Çevir" \
        3>&1 1>&2 2>&3)
    
    [ $? -ne 0 ] && return 1
    
    local basename=$(basename "$SELECTED_IMAGE")
    local output="$OUTPUT_DIR/rotated_${basename}"
    
    local cmd=""
    case "$operation" in
        "1") cmd="-rotate 90" ;;
        "2") cmd="-rotate 180" ;;
        "3") cmd="-rotate 270" ;;
        "4") cmd="-flop" ;;
        "5") cmd="-flip" ;;
    esac
    
    convert "$SELECTED_IMAGE" $cmd "$output" 2>&1 | \
        whiptail --title "Döndürme/Çevirme" --gauge "İşleniyor..." 7 60 0
    
    if [ -f "$output" ]; then
        show_success "İşlem başarıyla tamamlandı!\n\nKonum: $output"
    else
        show_error "İşlem sırasında hata oluştu!"
    fi
}

# FİLTRELER & EFEKTLER
apply_effects() {
    if [ -z "$SELECTED_IMAGE" ]; then
        show_error "Önce bir resim seçmelisiniz!"
        return 1
    fi
    local effect
    effect=$(whiptail --title "Efekt Seçin" --menu "Uygulanacak efekti seçin:" 20 70 12 \
        "1" "Bulanıklaştırma (Blur)" \
        "2" "Keskinleştirme (Sharpen)" \
        "3" "Siyah-Beyaz" \
        "4" "Sepia Tone" \
        "5" "Vintage" \
        "6" "Sketch (Karakalem)" \
        "7" "Parlaklık Artır" \
        "8" "Kontrast Artır" \
        3>&1 1>&2 2>&3)
    
    [ $? -ne 0 ] && return 1
    
    local basename=$(basename "$SELECTED_IMAGE")
    local output="$OUTPUT_DIR/effect_${basename}"
    
    local cmd=""
    case "$effect" in
        "1") cmd="-blur 0x5" ;;
        "2") cmd="-sharpen 0x5" ;;
        "3") cmd="-colorspace Gray" ;;
        "4") cmd="-sepia-tone 80%" ;;
        "5") cmd="-sepia-tone 80% -modulate 90,50,100" ;;
        "6") cmd="-sketch 0x20+120" ;;
        "7") cmd="-modulate 150,100,100" ;;
        "8") cmd="-brightness-contrast 0x30" ;;
    esac
    
    convert "$SELECTED_IMAGE" $cmd "$output" 2>&1 | \
        whiptail --title "Efekt Uygulama" --gauge "İşleniyor..." 7 60 0
    
    if [ -f "$output" ]; then
        show_success "Efekt başarıyla uygulandı!\n\nKonum: $output"
    else
        show_error "Efekt uygulama sırasında hata oluştu!"
    fi
}

# KIRPMA
crop_image() {
    if [ -z "$SELECTED_IMAGE" ]; then
        show_error "Önce bir resim seçmelisiniz!"
        return 1
    fi
    
    local current_width=$(identify -format "%w" "$SELECTED_IMAGE")
    local current_height=$(identify -format "%h" "$SELECTED_IMAGE")
    
    local crop_type
    crop_type=$(whiptail --title "Kırpma Türü" --menu "Kırpma türü seçin:" 15 70 4 \
        "1" "Merkez Kırpma" \
        "2" "Kare Kırpma (1:1)" \
        "3" "16:9 Oran" \
        "4" "Manuel Kırpma" \
        3>&1 1>&2 2>&3)
    
    [ $? -ne 0 ] && return 1
    
    local basename=$(basename "$SELECTED_IMAGE")
    local output="$OUTPUT_DIR/cropped_${basename}"
    local crop_param=""
    
    case "$crop_type" in
        "1")
            local width
            width=$(whiptail --title "Genişlik" --inputbox "Kırpma genişliği:" 10 60 "$((current_width/2))" 3>&1 1>&2 2>&3)
            [ $? -ne 0 ] && return 1
            
            local height
            height=$(whiptail --title "Yükseklik" --inputbox "Kırpma yüksekliği:" 10 60 "$((current_height/2))" 3>&1 1>&2 2>&3)
            [ $? -ne 0 ] && return 1
            
            crop_param="${width}x${height}+$(( (current_width - width) / 2 ))+$(( (current_height - height) / 2 ))"
            ;;
        "2")
            local min_dim=$((current_width < current_height ? current_width : current_height))
            crop_param="${min_dim}x${min_dim}+$(( (current_width - min_dim) / 2 ))+$(( (current_height - min_dim) / 2 ))"
            ;;
        "3")
            local crop_height=$((current_width * 9 / 16))
            crop_param="${current_width}x${crop_height}+0+$(( (current_height - crop_height) / 2 ))"
            ;;
        "4")
            local width
            width=$(whiptail --title "Genişlik" --inputbox "Kırpma genişliği:" 10 60 "800" 3>&1 1>&2 2>&3)
            [ $? -ne 0 ] && return 1
            
            local height
            height=$(whiptail --title "Yükseklik" --inputbox "Kırpma yüksekliği:" 10 60 "600" 3>&1 1>&2 2>&3)
            [ $? -ne 0 ] && return 1
            
            local x_start
            x_start=$(whiptail --title "X Başlangıç" --inputbox "X koordinatı:" 10 60 "0" 3>&1 1>&2 2>&3)
            [ $? -ne 0 ] && return 1
            
            local y_start
            y_start=$(whiptail --title "Y Başlangıç" --inputbox "Y koordinatı:" 10 60 "0" 3>&1 1>&2 2>&3)
            [ $? -ne 0 ] && return 1
            
            crop_param="${width}x${height}+${x_start}+${y_start}"
            ;;
    esac
    
    convert "$SELECTED_IMAGE" -crop "$crop_param" +repage "$output" 2>&1 | \
        whiptail --title "Kırpma" --gauge "İşleniyor..." 7 60 0
    
    if [ -f "$output" ]; then
        show_success "Resim başarıyla kırpıldı!\n\nKonum: $output"
    else
        show_error "Kırpma sırasında hata oluştu!"
    fi
}

# METİN EKLEME
add_text() {
    if [ -z "$SELECTED_IMAGE" ]; then
        show_error "Önce bir resim seçmelisiniz!"
        return 1
    fi
    
    local text
    text=$(whiptail --title "Metin Girin" --inputbox "Eklenecek metin:" 10 60 "ImageMagic Studio" 3>&1 1>&2 2>&3)
    
    [ $? -ne 0 ] && return 1
    
    local position
    position=$(whiptail --title "Pozisyon" --menu "Metin pozisyonu:" 15 60 6 \
        "1" "Merkez" \
        "2" "Sol Üst" \
        "3" "Sağ Üst" \
        "4" "Sol Alt" \
        "5" "Sağ Alt" \
        3>&1 1>&2 2>&3)
    
    [ $? -ne 0 ] && return 1
    
    local gravity="center"
    local offset="+0+0"
    
    case "$position" in
        "1") gravity="center"; offset="+0+0" ;;
        "2") gravity="northwest"; offset="+10+10" ;;
        "3") gravity="northeast"; offset="+10+10" ;;
        "4") gravity="southwest"; offset="+10+10" ;;
        "5") gravity="southeast"; offset="+10+10" ;;
    esac
    
    local basename=$(basename "$SELECTED_IMAGE")
    local output="$OUTPUT_DIR/text_${basename}"
    # -annotate kullanarak resme yazı işler
    convert "$SELECTED_IMAGE" \
        -gravity $gravity \
        -pointsize 48 \
        -fill white \
        -stroke black \
        -strokewidth 2 \
        -annotate $offset "$text" \
        "$output" 2>&1 | \
        whiptail --title "Metin Ekleme" --gauge "İşleniyor..." 7 60 0

    if [ -f "$output" ]; then
        show_success "Metin başarıyla eklendi!\n\nKonum: $output"
    else
        show_error "Metin ekleme sırasında hata oluştu!"
    fi
}
#PDF olusturma 
create_pdf() {
    local dir
    dir=$(whiptail --title "PDF Oluştur" --inputbox "Resimlerin bulunduğu dizin:" 10 60 "$HOME" 3>&1 1>&2 2>&3)
    
    [ $? -ne 0 ] || [ -z "$dir" ] && return 1

    # Dizin kontrolü
    if [ ! -d "$dir" ]; then
        whiptail --title "Hata" --msgbox "Belirtilen dizin bulunamadı!" 10 60
        return 1
    fi

    local output="$OUTPUT_DIR/tui_album_$(date +%Y%m%d_%H%M).pdf"
    
    # Büyük/küçük harf duyarlılığını geçici olarak kapat
    shopt -s nocaseglob
    
    # Resim dosyalarını bul ve bir diziye ata
    local files=("$dir"/*.{jpg,jpeg,png,webp,bmp})
    
    # Dosya varlık kontrolü (Dizi boş değilse ve ilk eleman gerçekten varsa)
    if [ -e "${files[0]}" ]; then
        (
            echo "50"; echo "# Resimler birleştiriliyor, lütfen bekleyin..."
            convert "${files[@]}" "$output" 2>&1
            echo "100"; echo "# İşlem tamamlandı!"
        ) | whiptail --title "PDF Oluşturuluyor" --gauge "İşleniyor..." 7 60 0

        whiptail --title "Başarılı" --msgbox "PDF başarıyla oluşturuldu:\n$output" 12 60
    else
        whiptail --title "Hata" --msgbox "Seçilen dizinde uygun formatta (JPG, PNG vb.) resim bulunamadı!" 10 60
        log_action "ERROR" "TUI: PDF için kaynak resim bulunamadı"
    fi
    # Ayarı eski haline döndür
    shopt -u nocaseglob
}

# ANA MENÜ
show_main_menu() {
    while true; do
        local selected_info="Resim seçilmedi"
        if [ -n "$SELECTED_IMAGE" ]; then
            selected_info="Seçili: $(basename "$SELECTED_IMAGE")"
        fi
        local choice
        choice=$(whiptail --title "ImageMagic Studio - TUI" \
            --menu "\n$selected_info\nÇıktı: $OUTPUT_DIR\n\nBir işlem seçin:" 22 70 11 \
            "1" "Resim Seç" \
            "2" "Resim Bilgileri" \
            "3" "Format Dönüştürme" \
            "4" "Boyutlandırma" \
            "5" "Kırpma" \
            "6" "Döndürme & Çevirme" \
            "7" "Efektler" \
            "8" "Metin Ekle" \
            "9" "PDF Oluştur" \
            "0" "Çıkış" \
            3>&1 1>&2 2>&3)
        
        [ $? -ne 0 ] && break
        
        case "$choice" in
            "1") select_file "$HOME" ;;
            "2") show_image_info ;;
            "3") convert_format ;;
            "4") resize_image ;;
            "5") crop_image ;;
            "6") rotate_flip ;;
            "7") apply_effects ;;
            "8") add_text ;;
            "9") create_pdf ;;
            "0") 
                if whiptail --title "Çıkış" --yesno "Çıkmak istediğinize emin misiniz?" 10 60; then
                    break
                fi
                ;;
        esac
    done
}
# ANA PROGRAM
main() {
    clear
    echo "ImageMagic Studio - TUI başlatılıyor..."
    sleep 1
    
    # Bağımlılıkları kontrol et
    check_dependencies

    # Ana menüyü göster
    show_main_menu
    clear
    echo "ImageMagic Studio kapatıldı. Teşekkürler!"
}
# Programı çalıştır
main
