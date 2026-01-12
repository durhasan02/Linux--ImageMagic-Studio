#!/bin/bash

echo "======================================"
echo "ImageMagic Studio - Kurulum"
echo "======================================"
echo ""

# Bağımlılıkları kontrol et
echo "[1/3] Bağımlılıklar kontrol ediliyor..."

MISSING=""
command -v convert >/dev/null 2>&1 || MISSING="$MISSING imagemagick"
command -v yad >/dev/null 2>&1 || MISSING="$MISSING yad"
command -v whiptail >/dev/null 2>&1 || MISSING="$MISSING whiptail"
command -v bc >/dev/null 2>&1 || MISSING="$MISSING bc"

if [ -n "$MISSING" ]; then
    echo "Eksik paketler:$MISSING"
    echo ""
    read -p "Kurmak ister misiniz? (e/h): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Ee]$ ]]; then
        sudo apt update
        sudo apt install -y $MISSING
    else
        echo "Kurulum iptal edildi."
        exit 1
    fi
else
    echo "✓ Tüm bağımlılıklar kurulu"
fi

# Çıktı klasörü oluştur
echo ""
echo "[2/3] Çıktı klasörü oluşturuluyor..."
mkdir -p "$HOME/ImageMagic-Output"
echo "✓ Klasör hazır: $HOME/ImageMagic-Output"

# Scriptleri çalıştırılabilir yap
echo ""
echo "[3/3] Scriptler hazırlanıyor..."
chmod +x imagemagic-gui.sh
chmod +x imagemagic-tui.sh
echo "✓ Scriptler hazır"

# Bitti
echo ""
echo "======================================"
echo "KURULUM TAMAMLANDI!"
echo "======================================"
echo ""
echo "Kullanım:"
echo "  GUI: ./imagemagic-gui.sh"
echo "  TUI: ./imagemagic-tui.sh"
echo ""