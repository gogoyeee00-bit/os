#!/bin/bash
#
# =========================================================
#       BZ VPN STORE - PENGUNDUH MENU & NOTIFIKASI
#
#  Tugas: Mengunduh semua skrip menu dari repositori
#         dan mengirim notifikasi instalasi ke Telegram.
# =========================================================

# --- KONFIGURASI ---
REPO_URL="https://raw.githubusercontent.com/gogoyeee00-bit/os/main"

# --- FUNGSI BANTUAN & WARNA ---
Color_Off='\033[0m'
BGreen='\033[1;32m'
BYellow='\03-3[1;33m'

print_info() { echo -e "${BYellow}[INFO]${Color_Off} $1"; }
print_success() { echo -e "${BGreen}[SUKSES]${Color_Off} $1"; }

# --- FUNGSI UTAMA ---

function download_menus() {
    print_info "Memulai pengunduhan skrip menu dari repositori Anda..."
    
    # Daftar semua file menu yang akan diunduh
    # Pastikan semua nama file ini ada di dalam folder 'menu/' di GitHub Anda
    local menu_files=(
        "menu" "add-user" "del-user" "trial" "member" "cek-user" "restart"
        "speedtest" "info" "about" "auto-reboot" "limit-speed"
        "add-vmess" "del-vmess" "cek-vmess" "renew-vmess" "trial-vmess"
        "add-vless" "del-vless" "cek-vless" "renew-vless" "trial-vless"
        "add-trojan" "del-trojan" "cek-trojan" "renew-trojan" "trial-trojan"
        "add-ss" "del-ss" "cek-ss" "renew-ss" "trial-ss"
        "backup" "restore" "welcome"
    )
    
    # Lokasi penyimpanan skrip di VPS
    local destination_path="/usr/local/sbin"
    
    # Loop untuk mengunduh setiap file
    for file in "${menu_files[@]}"; do
        echo "  - Mengunduh: ${file}"
        wget -q -O "${destination_path}/${file}" "${REPO_URL}/menu/${file}"
        if [ $? -eq 0 ]; then
            chmod +x "${destination_path}/${file}"
        else
            echo "    -> Gagal mengunduh ${file}. File mungkin tidak ada di repositori."
        fi
    done
    
    print_success "Semua skrip menu telah diunduh."
}

function send_notification() {
    print_info "Mengirim notifikasi instalasi ke Telegram Anda..."

    # --- Informasi Notifikasi Telegram BZ VPN Store (SUDAH DIPERBARUI) ---
    CHATID="1322616518"
    KEY="6628300537:AAG5L9Eji8Oh9MxincYevyLaKwViaWFEQaA"
    URL="https://api.telegram.org/bot$KEY/sendMessage"
    
    # Mengambil informasi sistem untuk notifikasi
    local domain=$(cat /etc/xray/domain)
    local ISP=$(cat /etc/xray/isp 2>/dev/null || echo "N/A")
    local CITY=$(cat /etc/xray/city 2>/dev/null || echo "N/A")
    local TIME=$(date +'%Y-%m-%d %H:%M:%S')
    local MYIP=$(cat /etc/myipvps 2>/dev/null || curl -sS ipv4.icanhazip.com)

    # Mengambil nama pengguna yang dimasukkan saat instalasi
    local author_name=$(cat /etc/xray/username 2>/dev/null || echo "N/A")

    TEXT="
<code>✅ Instalasi BZ VPN Store Berhasil ✅</code>
<code>━━━━━━━━━━━━━━━━━━━━━━</code>
<code>PENGGUNA : </code><code>${author_name}</code>
<code>DOMAIN   : </code><code>${domain}</code>
<code>IP       : </code><code>${MYIP}</code>
<code>ISP      : </code><code>${ISP}, ${CITY}</code>
<code>WAKTU    : </code><code>${TIME} WIB</code>
<code>━━━━━━━━━━━━━━━━━━━━━━</code>
<i>Notifikasi dari Installer Script...</i>
"'&reply_markup={"inline_keyboard":[[{"text":"HUBUNGI SAYA","url":"https://t.me/anuybazoelk"}]]}'
    
    # Kirim notifikasi
    curl -s --max-time 10 -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" "$URL" >/dev/null
    
    print_success "Notifikasi berhasil dikirim."
}

# --- EKSEKUSI SKRIP ---
main() {
    download_menus
    send_notification
}

# Jalankan fungsi utama
main
