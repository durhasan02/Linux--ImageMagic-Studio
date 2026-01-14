# Linux-ImageMagic-Studio

**ImageMagick Kullanıcı Dostu GUI ve TUI Arayüzü**
**PARDUS İle Tam Uyumlu**

Linux Scriptleri ve Araçları Dersi - Dönem Projesi

---

##  Proje Hakkında
**ImageMagic Studio**, komut satırında kullanılan güçlü resim işleme aracı **ImageMagick** için geliştirilmiş modern ve kullanıcı dostu bir arayüzdür. Bu proje, karmaşık ImageMagick komutlarını bilmeyen kullanıcıların bile profesyonel resim düzenleme işlemlerini kolayca yapabilmesini sağlar.Yerli linux dağıtımımız olan PARDUS üzerinde tüm özellikler test edilmiş ve eksiksiz çalışmıştır.

###  Proje Amacı

Bu proje, Linux Scriptleri ve Araçları dersi kapsamında, **Shell Scripting (Bash)** kullanarak hem **Grafiksel Kullanıcı Arayüzü (GUI)** hem de **Terminal Tabanlı Kullanıcı Arayüzü (TUI)** geliştirme becerilerini göstermek amacıyla hazırlanmıştır.

###  Neden ImageMagic Studio?

-  **Kolay Kullanım**: Karmaşık komutları hatırlamaya gerek yok
-  **Hızlı İşlem**: Tek tıkla profesyonel düzenlemeler
-  **Zengin Özellikler**: Format dönüştürme, boyutlandırma, efektler ve daha fazlası
-  **İki Arayüz**: Grafik (YAD) ve Terminal (whiptail) seçenekleri
-  **PARDUS  Tam Uyumlu**: Yerli işletim sistemimizde sorunsuz çalışır

---
## Video Tanıtımı

 **YouTube Videosu**: [ImageMagic Studio - Tanıtım ve Kullanım]( )
-Videoda:
-  Kurulum adımları
-  GUI ve TUI kullanımı
-  Tüm özelliklerin demonstrasyonu
-  Örnek kullanım senaryoları
-  İpuçları ve püf noktaları
---

##  Özellikler

###  Dosya İşlemleri
-  Resim seçme ve önizleme
-  Detaylı resim bilgileri (boyut, format, EXIF vb.)

###  Format Dönüştürme
- **Desteklenen Formatlar**: JPG, PNG, WEBP, BMP, GIF, TIFF
- Kalite ayarı (1-100)
- Tek tık ile dönüştürme
  
###  Boyutlandırma
- **Piksel bazlı**: Manuel genişlik x yükseklik
- **Yüzde bazlı**: %50, %75 gibi oransal boyutlandırma
- **Hazır boyutlar**: 
  - Instagram Kare (1080x1080)
  - Instagram Dikey (1080x1350)
  - HD (1920x1080)
  - 4K (3840x2160)
  - Facebook Kapak (820x312)
- En-boy oranını koruma seçeneği

###  Kırpma
- Merkez kırpma
- Kare kırpma (1:1)
- Oran bazlı kırpma (16:9, 4:3, 3:2)
- Manuel kırpma (X, Y koordinatları ile)
  
###  Döndürme & Çevirme
- 90°, 180°, 270° döndürme
- Yatay ve dikey çevirme
  
###  Filtreler & Efektler
- **Bulanıklaştırma** (Blur)
- **Keskinleştirme** (Sharpen)
- **Siyah-Beyaz** dönüşüm
- **Sepia** tone efekti
- **Vintage** stil
  
###  Metin & Watermark
- Resme metin ekleme
- Font boyutu ayarı
- Renk seçimi
- Pozisyon seçimi (merkez, köşeler, özel)
- Şeffaflık ayarı
- Copyright watermark ekleme
  
###  PDF Oluşturma
- Birden fazla resimden PDF oluşturma
- Çoklu resim seçimi
- Otomatik sıralama
- İlerleme göstergesi
  
---

##  Ekran Görüntüleri

### GUI Sürümü (YAD)

#### Ana Menü
![Ana Menü](screenshots/gui-ana-menu.png)
*Modern ve kullanıcı dostu ana menü*

#### Format Dönüştürme
![ Gui Format Değiştirme](screenshots/gui-format.png)
*Kolay format dönüştürme arayüzü*

#### Boyutlandırma
![Boyutlandırma](screenshots/gui-boyutlandırma.png)
*Hazır boyutlar ve özel boyutlandırma seçenekleri*

#### Efektler
![Efektler](screenshots/gui-efekt.png)
*Çeşitli filtre ve efektler*

#### PDF Oluşturma
![PDF Oluşturma](screenshots/gui-pdf.png)
*Birden fazla resimden PDF oluşturma*

#### Metin Ekleme
![Metin Ekleme](screenshots/gui-metin-ekle.png)
*Resmin istenilen her hangi bir yerine istenilen renkte metin ekleme*

#### Resmi döndürme
![Resmi Döndürme](screenshots/gui-dondurme.png)
*Resmi döndürme*

### TUI Sürümü (whiptail)

#### TUI Ana Menü
![TUI Menü](screenshots/tui-ana-menu.png)
*Terminal tabanlı kullanıcı arayüzü*

#### EFEKT
![Efek Ekleme](screenshots/tui-efekt.png)
*Çeşitli efekler ekleme*

#### Format Değiştirme
![Format Değiştirme](screenshots/tui-format.png)
*Farklı formatlara değiştirme*

#### Metin ekleme
![Metin  Ekleme](screenshots/tui-metin.png)
*Resmin istenilen herhangi bir yerine istenilen renkte ve boyutta metin ekleme*

#### Resmi kırpma
![Resmi Kırpma](screenshots/kırpma.png)
*Resmi kırpma*

#### PDF dönüştürme
![PDF Dönüştürme](screenshots/tui-pdf.png)
![](screenshots/tui-pdf1.png)
*Seçilen dizindeki resimleri pdf dönüştürme*

---
#### imagemagic output
![imagemagic output](screenshots/output.png)
*işlem yapılan resimlerin tutulduğu output klasörü*

---

##  Kurulum

### Otomatik Kurulum (Önerilen)

```bash
# Repoyu klonlayın
git clone https://github.com/[durhasan02]/Linux-ImageMagic-Studio.git
cd Linux-ImageMagic-Studio

# Kurulum scriptini çalıştırın
chmod +x install.sh
./install.sh
```

Kurulum scripti otomatik olarak:
- Gerekli bağımlılıkları kurar
- Program dosyalarını doğru konuma kopyalar
- PATH yapılandırmasını yapar

### Manuel Kurulum

```bash
# 1. Bağımlılıkları kurun
sudo apt update
sudo apt install imagemagick yad whiptail bc

# 2. Scriptleri çalıştırılabilir yapın
chmod +x imagemagic-gui.sh
chmod +x imagemagic-tui.sh

# 3. Programları kullanmaya başlayın
./imagemagic-gui.sh   # GUI sürümü
./imagemagic-tui.sh   # TUI sürümü
```

---

##  Kullanım

### GUI Sürümü

Grafiksel arayüz ile kullanım:

**Temel İş Akışı:**
1. "Resim Seç" ile düzenlenecek resmi seçin
2. İstediğiniz işlemi seçin (dönüştürme, boyutlandırma, efekt vb.)
3. Parametreleri ayarlayın (format, kalite, boyut vb.)
4. "Uygula" veya "Dönüştür" butonuna tıklayın
5. İşlenmiş resim `~/ImageMagic-Output` klasörüne kaydedilir
6. Başarı mesajı ile işlem tamamlandığı bildirilir

### TUI Sürümü

Terminal arayüzü ile kullanım:

**Navigasyon:**
-  Ok tuşları ile menüde gezinme
- `Enter` ile seçim yapma
- `Tab` ile düğmeler arasında geçiş
- `Esc` veya "İptal" ile geri dönme

### Kullanım Örnekleri

#### Örnek 1: Format Dönüştürme
```
1. Ana menüden "Format Dönüştürme" seçin
2. Hedef format olarak "PNG" seçin
3. Kalite: 90
4. "Dönüştür" butonuna tıklayın
```

#### Örnek 2: Instagram için Boyutlandırma
```
1. "Boyutlandırma" seçin
2. Yöntem: "Hazır Boyutlar"
3. "Instagram Kare (1080x1080)" seçin
4. "Uygula" butonuna tıklayın
```

#### Örnek 3: PDF Oluşturma
```
1. "PDF Oluştur" seçin
2. Birden fazla resim seçin (Ctrl tuşu ile)
3. Resimler otomatik olarak PDF'e dönüştürülür
4. PDF dosyası çıktı klasörüne kaydedilir
```

### GUI Sürümü

Grafiksel arayüz ile kullanım:

**Temel İş Akışı:**
1. "Resim Seç" ile düzenlenecek resmi seçin
2. İstediğiniz işlemi seçin (dönüştürme, boyutlandırma, efekt vb.)
3. Parametreleri ayarlayın (format, kalite, boyut vb.)
4. "Uygula" veya "Dönüştür" butonuna tıklayın
5. İşlenmiş resim `~/ImageMagic-Output` klasörüne kaydedilir
6. Başarı mesajı ile işlem tamamlandığı bildirilir

### TUI Sürümü

Terminal arayüzü ile kullanım:

**Navigasyon:**
-  Ok tuşları ile menüde gezinme
- `Enter` ile seçim yapma
- `Tab` ile düğmeler arasında geçiş
- `Esc` veya "İptal" ile geri dönme

### Kullanım Örnekleri

#### Örnek 1: Format Dönüştürme
```
1. Ana menüden "Format Dönüştürme" seçin
2. Hedef format olarak "PNG" seçin
3. Kalite: 90
4. "Dönüştür" butonuna tıklayın
```

#### Örnek 2: Instagram için Boyutlandırma
```
1. "Boyutlandırma" seçin
2. Yöntem: "Hazır Boyutlar"
3. "Instagram Kare (1080x1080)" seçin
4. "Uygula" butonuna tıklayın
```

#### Örnek 3: PDF Oluşturma
```
1. "PDF Oluştur" seçin
2. Birden fazla resim seçin (Ctrl tuşu ile)
3. Resimler otomatik olarak PDF'e dönüştürülür
4. PDF dosyası çıktı klasörüne kaydedilir
```

---

### Gerekli Paketler
- `bash` (4.0+)
- `imagemagick` (6.9+)
- `yad` (GUI için)
- `whiptail` (TUI için)
- `bc` (hesaplamalar için)

---

##  Teknik Detaylar
```
Linux-ImageMagic-Studio/ (Ana Dizin)
├── imagemagic-gui.sh          # Ana GUI script (YAD)
├── imagemagic-tui.sh          # Ana TUI script (whiptail)
├── install.sh                 # Kurulum scripti
├── README.md                  # Tanıtım ve kullanım kılavuzu
└── screenshots/               # Ekran görüntüleri klasörü
    ├── gui-ana-menu.png
    ├── gui-format.png
    ├── gui-boyutlandirma.png
    ├── gui-efekt.png
    ├── gui-metin-ekle.png
    ├── gui-pdf.png
    ├── gui-dondurme.png
    ├── tui-ana-menu.png
    ├── tui-format.png
    ├── tui-bilgi.png
    ├── tui-pdf.png
    └── ... (diğer görseller)
```

### Kullanılan Teknolojiler

- **Shell**: Bash 4.0+
- **GUI Kütüphanesi**: YAD (Yet Another Dialog)
- **TUI Kütüphanesi**: whiptail
- **Image Processing**: ImageMagick

### Kod Özellikleri

-  Modüler fonksiyon yapısı
-  Hata kontrolü ve yönetimi
-  Kullanıcı dostu hata mesajları
-  İlerleme göstergeleri (yad --progress)
-  Geçici dosya yönetimi
-  Temiz kod ve yorum satırları
-  Pipe karakteri yönetimi (yad çıktıları için)
-  Dosya doğrulama ve kontrol
-  Otomatik çıktı klasörü oluşturma

### İşlev Detayları

#### Format Dönüştürme
```bash
convert "$SELECTED_IMAGE" -quality "$quality" "$output"
```

#### Boyutlandırma
```bash
convert "$SELECTED_IMAGE" -resize "${width}x${height}" "$output"
```

#### Efekt Uygulama
```bash
# Sepia efekti
convert "$SELECTED_IMAGE" -sepia-tone 80% "$output"

# Siyah-Beyaz
convert "$SELECTED_IMAGE" -colorspace Gray "$output"

# Bulanıklaştırma
convert "$SELECTED_IMAGE" -blur 0x5 "$output"
```

#### PDF Oluşturma
```bash
convert $images "$output"
```
---
**Proje Sahibi**: [Durhasan Yazğan]  
**E-posta**: [durhasanyazgan@gmail.com]  

## Ek Kaynaklar

- [ImageMagick Resmi Dokümantasyonu](https://imagemagick.org/index.php)
- [YAD Kılavuzu](https://yad-guide.ingk.se/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)
- [PARDUS Resmi Sitesi](https://www.pardus.org.tr/)




