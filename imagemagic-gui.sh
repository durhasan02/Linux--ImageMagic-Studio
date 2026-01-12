#!/bin/bash

# ImageMagic Studio - GUI Version

# Gerekli araçları kontrol et
check_dependencies() {
    local missing_deps=()
    
    command -v yad >/dev/null 2>&1 || missing_deps+=("yad")
    command -v convert >/dev/null 2>&1 || missing_deps+=("imagemagick")
    command -v identify >/dev/null 2>&1 || missing_deps+=("imagemagick")
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}Eksik bağımlılıklar: ${missing_deps[*]}${NC}"
        echo -e "${YELLOW}Kurulum için: sudo apt install imagemagick yad${NC}"
        exit 1
    fi
}

# Geçici dizin oluştur
TEMP_DIR="/tmp/imagemagic-studio-$$"
mkdir -p "$TEMP_DIR"

# Çıkışta temizlik
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Global değişkenler
SELECTED_IMAGE=""
OUTPUT_DIR="$HOME/ImageMagic-Output"
mkdir -p "$OUTPUT_DIR"

# YARDIMCI FONKSİYONLAR
show_notification() {
    yad --notification \
        --image="dialog-information" \
        --text="$1" \
        --timeout=3
}

show_error() {
    yad --error \
        --title="Hata" \
        --text="$1" \
        --width=300 \
        --button="Tamam:0"
}

show_success() {
    yad --info \
        --title="Başarılı" \
        --text="$1" \
        --width=300 \
        --timeout=3 \
        --button="Tamam:0"
}

# Resim seç
select_image() {
    local file
    file=$(yad --file-selection \
        --title="Resim Seçin" \
        --file-filter="Resim Dosyaları | *.jpg *.jpeg *.png *.gif *.bmp *.webp *.tiff *.JPG *.JPEG *.PNG *.GIF *.BMP *.WEBP *.TIFF" \
        --file-filter="Tüm Dosyalar | *" \
        --width=800 \
        --height=600 \
        --image="gtk-open" \
        2>/dev/null)
    
    # Kullanıcı iptal ettiyse
    [ $? -ne 0 ] && return 1
    
    # Dosya seçildi mi ve geçerli mi kontrol et
    if [ -n "$file" ] && [ -f "$file" ]; then
        SELECTED_IMAGE="$file"
        show_success "Resim seçildi:\n\n$(basename "$file")"
        return 0
    elif [ -n "$file" ]; then
        show_error "Seçilen dosya bulunamadı:\n\n$file"
        return 1
    else
        return 1
    fi
}

# Çoklu resim seç
select_multiple_images() {
    yad --file-selection \
        --title="Resimler Seçin (Çoklu Seçim)" \
        --multiple \
        --separator="|" \
        --file-filter="Resim Dosyaları | *.jpg *.jpeg *.png *.gif *.bmp *.webp *.tiff *.JPG *.JPEG *.PNG *.GIF *.BMP *.WEBP *.TIFF" \
        --file-filter="Tüm Dosyalar | *" \
        --width=800 \
        --height=600 \
        --image="gtk-open"
}

# Resim bilgilerini göster
show_image_info() {
    if [ -z "$SELECTED_IMAGE" ]; then
        show_error "Önce bir resim seçmelisiniz!"
        return 1
    fi
    
    local info
    info=$(identify -verbose "$SELECTED_IMAGE")
    local format=$(identify -format "%m" "$SELECTED_IMAGE")
    local width=$(identify -format "%w" "$SELECTED_IMAGE")
    local height=$(identify -format "%h" "$SELECTED_IMAGE")
    local size=$(du -h "$SELECTED_IMAGE" | cut -f1)
    local colorspace=$(identify -format "%[colorspace]" "$SELECTED_IMAGE")
    
    yad --text-info \
        --title="Resim Bilgileri - $(basename "$SELECTED_IMAGE")" \
        --width=600 \
        --height=500 \
        --text="<b>Dosya:</b> $(basename "$SELECTED_IMAGE")
<b>Format:</b> $format
<b>Boyut:</b> ${width}x${height} piksel
<b>Dosya Boyutu:</b> $size
<b>Renk Uzayı:</b> $colorspace

<b>Detaylı Bilgi:</b>
$info" \
        --button="Tamam:0"
}

#PDF olusturma 
create_pdf() {
    local images
    images=$(yad --file-selection \
        --title="PDF İçin Resimleri Seçin" \
        --multiple \
        --separator=" " \
        --file-filter="Resimler | *.jpg *.jpeg *.png *.gif *.bmp *.webp *.tiff *.JPG *.JPEG *.PNG *.GIF *.BMP *.WEBP *.TIFF" \
        --file-filter="Tüm Dosyalar | *" \
        --width=800 \
        --height=600 \
        --image="gtk-open")
    
    [ -z "$images" ] && return 1
    
    local output="$OUTPUT_DIR/album_$(date +%Y%m%d_%H%M).pdf"
    
    (
        echo "50"; echo "# PDF dosyası birleştiriliyor..."
        convert $images "$output" 2>&1
        echo "100"; echo "# Tamamlandı!"
    ) | yad --progress --title="PDF Oluştur" --auto-close --width=300
    
    if [ -f "$output" ]; then
        show_success "PDF Başarıyla Oluşturuldu!\nKonum: $output"
    else
        show_error "PDF oluşturma başarısız."
    fi
}

# FORMAT DÖNÜŞTÜRME
convert_format() {
    if [ -z "$SELECTED_IMAGE" ]; then
        show_error "Önce bir resim seçmelisiniz!"
        return 1
    fi
    
    local result
    result=$(yad --form \
        --title="Format Dönüştürme" \
        --width=400 \
        --field="Hedef Format:CB" "PNG!JPG!WEBP!BMP!GIF!TIFF" \
        --field="Kalite (1-100):NUM" "90!1..100!1" \
        --button="İptal:1" \
        --button="Dönüştür:0")
    
    [ $? -eq 1 ] && return 1
    
    local format=$(echo "$result" | cut -d'|' -f1)
    local quality=$(echo "$result" | cut -d'|' -f2 | cut -d'.' -f1)
    
    local basename=$(basename "$SELECTED_IMAGE" | sed 's/\.[^.]*$//')
    local output="$OUTPUT_DIR/${basename}.${format,,}"
    
    (
        echo "10"; echo "# Dönüştürme başlıyor..."
        convert "$SELECTED_IMAGE" -quality "$quality" "$output" 2>&1
        echo "100"; echo "# Tamamlandı!"
    ) | yad --progress \
        --title="Format Dönüştürme" \
        --width=400 \
        --auto-close \
        --no-cancel
    
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
    
    local result
    result=$(yad --form \
        --title="Boyutlandırma - Mevcut: ${current_width}x${current_height}" \
        --width=500 \
        --field="Yöntem:CB" "Piksel Bazlı!Yüzde Bazlı!Hazır Boyutlar" \
        --field="Genişlik:NUM" "${current_width}!1..10000!1" \
        --field="Yükseklik:NUM" "${current_height}!1..10000!1" \
        --field="En-Boy Oranını Koru:CHK" "TRUE" \
        --field="Hazır Boyut:CB" "Instagram Kare (1080x1080)!Instagram Dikey (1080x1350)!HD (1920x1080)!Full HD (1920x1080)!4K (3840x2160)!Facebook Kapak (820x312)" \
        --button="İptal:1" \
        --button="Uygula:0")
    
    [ $? -eq 1 ] && return 1
    
    local method=$(echo "$result" | cut -d'|' -f1)
    local new_width=$(echo "$result" | cut -d'|' -f2 | cut -d'.' -f1)
    local new_height=$(echo "$result" | cut -d'|' -f3 | cut -d'.' -f1)
    local keep_ratio=$(echo "$result" | cut -d'|' -f4)
    local preset=$(echo "$result" | cut -d'|' -f5)
    
    local resize_param=""
    
    case "$method" in
        "Piksel Bazlı")
            if [ "$keep_ratio" == "TRUE" ]; then
                resize_param="${new_width}x${new_height}"
            else
                resize_param="${new_width}x${new_height}!"
            fi
            ;;
        "Yüzde Bazlı")
            resize_param="${new_width}%"
            ;;
        "Hazır Boyutlar")
            case "$preset" in
                "Instagram Kare (1080x1080)") resize_param="1080x1080" ;;
                "Instagram Dikey (1080x1350)") resize_param="1080x1350" ;;
                "HD (1920x1080)") resize_param="1920x1080" ;;
                "Full HD (1920x1080)") resize_param="1920x1080" ;;
                "4K (3840x2160)") resize_param="3840x2160" ;;
                "Facebook Kapak (820x312)") resize_param="820x312!" ;;
            esac
            ;;
    esac
    
    local basename=$(basename "$SELECTED_IMAGE")
    local output="$OUTPUT_DIR/resized_${basename}"
    
    (
        echo "10"; echo "# Boyutlandırma başlıyor..."
        convert "$SELECTED_IMAGE" -resize "$resize_param" "$output" 2>&1
        echo "100"; echo "# Tamamlandı!"
    ) | yad --progress \
        --title="Boyutlandırma" \
        --width=400 \
        --auto-close \
        --no-cancel
    
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
    operation=$(yad --list \
        --title="Döndürme/Çevirme" \
        --width=400 \
        --height=300 \
        --column="İşlem" \
        "90° Sağa Döndür" \
        "180° Döndür" \
        "270° Sağa Döndür" \
        "Yatay Çevir" \
        "Dikey Çevir" \
        --button="İptal:1" \
        --button="Uygula:0" \
        --print-column=1)
    
    [ $? -eq 1 ] && return 1
    
    # Pipe karakterini temizle ve baş/son boşlukları kaldır
    operation=$(echo "$operation" | cut -d'|' -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    local basename=$(basename "$SELECTED_IMAGE")
    local output="$OUTPUT_DIR/rotated_${basename}"
    
    case "$operation" in
        "90° Sağa Döndür") convert "$SELECTED_IMAGE" -rotate 90 "$output" ;;
        "180° Döndür") convert "$SELECTED_IMAGE" -rotate 180 "$output" ;;
        "270° Sağa Döndür") convert "$SELECTED_IMAGE" -rotate 270 "$output" ;;
        "Yatay Çevir") convert "$SELECTED_IMAGE" -flop "$output" ;;
        "Dikey Çevir") convert "$SELECTED_IMAGE" -flip "$output" ;;
    esac
    
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
    effect=$(yad --list \
        --title="Efekt Seçin" \
        --width=400 \
        --height=400 \
        --column="Efekt" \
        "Siyah-Beyaz" \
        "Sepia" \
        "Bulanıklaştırma" \
        "Keskinleştirme" \
        "Vintage" \
        --button="İptal:1" \
        --button="Uygula:0" \
        --print-column=1)
    
    [ $? -eq 1 ] && return 1
    
    # Pipe karakterini temizle ve baş/son boşlukları kaldır
    effect=$(echo "$effect" | cut -d'|' -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    local basename=$(basename "$SELECTED_IMAGE")
    local output="$OUTPUT_DIR/effect_${basename}"
    
    case "$effect" in
        "Siyah-Beyaz") 
            convert "$SELECTED_IMAGE" -colorspace Gray "$output"
            ;;
        "Sepia") 
            convert "$SELECTED_IMAGE" -sepia-tone 80% "$output"
            ;;
        "Bulanıklaştırma") 
            convert "$SELECTED_IMAGE" -blur 0x5 "$output"
            ;;
        "Keskinleştirme") 
            convert "$SELECTED_IMAGE" -sharpen 0x5 "$output"
            ;;
        "Vintage") 
            convert "$SELECTED_IMAGE" -sepia-tone 80% -modulate 90,50,100 "$output"
            ;;
    esac
    
    if [ -f "$output" ]; then
        show_success "Efekt başarıyla uygulandı!\n\nKonum: $output"
    else
        show_error "Efekt uygulama sırasında hata oluştu!"
    fi
}

# METİN EKLEME
add_text() {
    if [ -z "$SELECTED_IMAGE" ]; then
        show_error "Önce bir resim seçmelisiniz!"
        return 1
    fi
    
    local result
    result=$(yad --form \
        --title="Metin Ekleme" \
        --width=500 \
        --field="Metin:" "ImageMagic Studio" \
        --field="Font Boyutu:NUM" "48!12..200!1" \
        --field="Renk:CLR" "#FFFFFF" \
        --field="Pozisyon:CB" "Merkez!Sol Üst!Sağ Üst!Sol Alt!Sağ Alt!Özel" \
        --field="X Koordinat:NUM" "0!0..5000!10" \
        --field="Y Koordinat:NUM" "0!0..5000!10" \
        --field="Şeffaflık (0-100):NUM" "100!0..100!1" \
        --button="İptal:1" \
        --button="Ekle:0")
    
    [ $? -eq 1 ] && return 1
    
    local text=$(echo "$result" | cut -d'|' -f1)
    local fontsize=$(echo "$result" | cut -d'|' -f2 | cut -d'.' -f1)
    local color=$(echo "$result" | cut -d'|' -f3)
    local position=$(echo "$result" | cut -d'|' -f4)
    local x_coord=$(echo "$result" | cut -d'|' -f5 | cut -d'.' -f1)
    local y_coord=$(echo "$result" | cut -d'|' -f6 | cut -d'.' -f1)
    local opacity=$(echo "$result" | cut -d'|' -f7 | cut -d'.' -f1)
    
    local gravity="center"
    local offset="+0+0"
    
    case "$position" in
        "Merkez") gravity="center"; offset="+0+0" ;;
        "Sol Üst") gravity="northwest"; offset="+10+10" ;;
        "Sağ Üst") gravity="northeast"; offset="+10+10" ;;
        "Sol Alt") gravity="southwest"; offset="+10+10" ;;
        "Sağ Alt") gravity="southeast"; offset="+10+10" ;;
        "Özel") gravity="northwest"; offset="+${x_coord}+${y_coord}" ;;
    esac
    
    local alpha=$(echo "scale=2; $opacity / 100" | bc)
    
    local basename=$(basename "$SELECTED_IMAGE")
    local output="$OUTPUT_DIR/text_${basename}"
    
    (
        echo "10"; echo "# Metin ekleniyor..."
        convert "$SELECTED_IMAGE" \
            -gravity $gravity \
            -pointsize $fontsize \
            -fill "$color" \
            -annotate $offset "$text" \
            "$output" 2>&1
        echo "100"; echo "# Tamamlandı!"
    ) | yad --progress \
        --title="Metin Ekleme" \
        --width=400 \
        --auto-close \
        --no-cancel
    
    if [ -f "$output" ]; then
        show_success "Metin başarıyla eklendi!\n\nKonum: $output"
    else
        show_error "Metin ekleme sırasında hata oluştu!"
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
    
    local result
    result=$(yad --form \
        --title="Kırpma - Mevcut: ${current_width}x${current_height}" \
        --width=500 \
        --field="Kırpma Türü:CB" "Merkez Kırpma!Manuel Kırpma!Kare Kırpma!Oran Bazlı" \
        --field="Genişlik:NUM" "$((current_width/2))!1..${current_width}!1" \
        --field="Yükseklik:NUM" "$((current_height/2))!1..${current_height}!1" \
        --field="X Başlangıç:NUM" "0!0..${current_width}!1" \
        --field="Y Başlangıç:NUM" "0!0..${current_height}!1" \
        --field="En-Boy Oranı:CB" "1:1 (Kare)!16:9 (Widescreen)!4:3 (Klasik)!3:2 (Fotoğraf)" \
        --button="İptal:1" \
        --button="Kırp:0")
    
    [ $? -eq 1 ] && return 1
    
    local crop_type=$(echo "$result" | cut -d'|' -f1)
    local width=$(echo "$result" | cut -d'|' -f2 | cut -d'.' -f1)
    local height=$(echo "$result" | cut -d'|' -f3 | cut -d'.' -f1)
    local x_start=$(echo "$result" | cut -d'|' -f4 | cut -d'.' -f1)
    local y_start=$(echo "$result" | cut -d'|' -f5 | cut -d'.' -f1)
    local ratio=$(echo "$result" | cut -d'|' -f6)
    
    local basename=$(basename "$SELECTED_IMAGE")
    local output="$OUTPUT_DIR/cropped_${basename}"
    
    local crop_param=""
    
    case "$crop_type" in
        "Merkez Kırpma")
            crop_param="${width}x${height}+$(( (current_width - width) / 2 ))+$(( (current_height - height) / 2 ))"
            ;;
        "Manuel Kırpma")
            crop_param="${width}x${height}+${x_start}+${y_start}"
            ;;
        "Kare Kırpma")
            local min_dim=$((current_width < current_height ? current_width : current_height))
            crop_param="${min_dim}x${min_dim}+$(( (current_width - min_dim) / 2 ))+$(( (current_height - min_dim) / 2 ))"
            ;;
        "Oran Bazlı")
            case "$ratio" in
                "1:1 (Kare)")
                    local min_dim=$((current_width < current_height ? current_width : current_height))
                    crop_param="${min_dim}x${min_dim}+$(( (current_width - min_dim) / 2 ))+$(( (current_height - min_dim) / 2 ))"
                    ;;
                "16:9 (Widescreen)")
                    local crop_height=$((current_width * 9 / 16))
                    crop_param="${current_width}x${crop_height}+0+$(( (current_height - crop_height) / 2 ))"
                    ;;
                "4:3 (Klasik)")
                    local crop_height=$((current_width * 3 / 4))
                    crop_param="${current_width}x${crop_height}+0+$(( (current_height - crop_height) / 2 ))"
                    ;;
                "3:2 (Fotoğraf)")
                    local crop_height=$((current_width * 2 / 3))
                    crop_param="${current_width}x${crop_height}+0+$(( (current_height - crop_height) / 2 ))"
                    ;;
            esac
            ;;
    esac
    
    (
        echo "10"; echo "# Kırpma başlıyor..."
        convert "$SELECTED_IMAGE" -crop "$crop_param" +repage "$output" 2>&1
        echo "100"; echo "# Tamamlandı!"
    ) | yad --progress \
        --title="Kırpma" \
        --width=400 \
        --auto-close \
        --no-cancel
    
    if [ -f "$output" ]; then
        show_success "Resim başarıyla kırpıldı!\n\nKonum: $output"
    else
        show_error "Kırpma sırasında hata oluştu!"
    fi
}


# ANA MENÜ
show_main_menu() {
    while true; do
        local selected_info=""
        if [ -n "$SELECTED_IMAGE" ]; then
            selected_info="Seçili: $(basename "$SELECTED_IMAGE")"
        else
            selected_info="Resim seçilmedi"
        fi
        # Ana işlem listesi
        local choice
        choice=$(yad --list \
            --title="ImageMagic Studio - GUI" \
            --width=700 \
            --height=500 \
            --text="<b>ImageMagick için Kullanıcı Dostu Arayüz</b>\n\n$selected_info\nÇıktı Klasörü: $OUTPUT_DIR" \
            --column="İşlem" \
            --column="Açıklama" \
            "Resim Seç" "Düzenlenecek resmi seçin" \
            "Resim Bilgileri" "Seçili resim hakkında bilgi" \
            "Format Dönüştürme" "JPG, PNG, WEBP vb. arası dönüştürme" \
            "Boyutlandırma" "Resmi yeniden boyutlandır" \
            "Kırpma" "Resmi kırp" \
            "Döndürme & Çevirme" "Resmi döndür veya çevir" \
            "Efektler" "Blur, Sepia, Siyah-Beyaz vb." \
            "Metin Ekle" "Resme metin veya watermark ekle" \
            "PDF Oluştur" "Birden fazla resimden PDF oluştur" \
            "Çık" "Programdan çık" \
            --button="Tamam:0" \
            --button="İptal:1" \
            --print-column=1)

        # Kullanıcı kapattıysa veya iptal dediyse döngüden çıkar
        [ $? -eq 1 ] && break
        
        case "$choice" in
            "Resim Seç|")
                select_image
                ;;
            "Resim Bilgileri|")
                show_image_info
                ;;
            "Format Dönüştürme|")
                convert_format
                ;;
            "Boyutlandırma|")
                resize_image
                ;;
            "Kırpma|")
                crop_image
                ;;
            "Döndürme & Çevirme|")
                rotate_flip
                ;;
            "Efektler|")
                apply_effects
                ;;
            "Metin Ekle|")
                add_text
                ;;
            "PDF Oluştur|")
                create_pdf
                ;;
            "Çık|")
                break
                ;;
        esac
    done
}

# ANA PROGRAM
main() {
    echo "ImageMagic Studio - GUI başlatılıyor..."
    
    # Bağımlılıkları kontrol et
    check_dependencies
    
    # Ana menüyü göster
    show_main_menu
    
    echo "ImageMagic Studio kapatıldı."
}

# Programı çalıştır
main
