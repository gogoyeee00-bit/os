
---

### File #2: `setup.sh` (Final)

Salin seluruh kode di bawah ini dan gunakan untuk menggantikan isi file `setup.sh` di repositori `gogoyeee00-bit/os` Anda.

```bash
#!/bin/bash
# =========================================================
#       BZ VPN STORE - AUTOSCRIPT INSTALLER
# =========================================================
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

# --- KONFIGURASI REPOSITORI (SUDAH DIARAHKAN KE REPO ANDA) ---
REPO_URL="https://raw.githubusercontent.com/gogoyeee00-bit/os/main/"
LICENSE_REPO="gogoyeee00-bit/izinvps"

# --- FUNGSI BANTUAN & WARNA ---
clear
red='\e[1;31m'; green='\e[0;32m'; yell='\e[1;33m'; NC='\033[0m'
print_info() { echo -e "\n${yell}[INFO]${NC} $1"; }
print_success() { echo -e "${green}[SUKSES]${NC} $1"; }
print_error() { echo -e "${red}[ERROR]${NC} $1"; exit 1; }
check_status() { if [ $? -ne 0 ]; then print_error "$1"; fi }

# --- PEMERIKSAAN AWAL ---
cd /root
if [ "${EUID}" -ne 0 ]; then print_error "Skrip ini harus dijalankan sebagai root."; fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then print_error "OpenVZ tidak didukung."; fi

# --- BANNER & INPUT PENGGUNA ---
echo -e "$green    ♥ TERIMA KASIH TELAH MEMAKAI SCRIPT BZ VPN STORE ♥$NC"
sleep 3; clear

function get_domain(){
    print_info "SETUP DOMAIN VPS"
    echo "----------------------------------------------------------"
    read -rp "Silakan masukkan domain Anda yang valid: " user_domain
    if [ -z "$user_domain" ]; then
        print_error "Domain tidak boleh kosong."
    fi
    
    # Simpan domain
    mkdir -p /etc/xray
    echo "$user_domain" > /etc/xray/domain
    echo "IP=$user_domain" > /var/lib/ipvps.conf
    print_success "Domain telah diatur ke: $user_domain"
    sleep 2; clear
}

function install_components(){
    print_info "Memulai instalasi komponen..."
    
    # Definisikan semua langkah instalasi
    local steps=(
        "Menginstal SSH & OpenVPN|${REPO_URL}install/ssh-vpn.sh"
        "Menginstal Xray Core|${REPO_URL}install/ins-xray.sh"
        "Menginstal Websocket|${REPO_URL}sshws/insshws.sh"
        "Menginstal Menu Backup|${REPO_URL}install/set-br.sh"
        "Mengunduh Menu Tambahan & Notifikasi|${REPO_URL}menu/update.sh"
        "Menginstal SlowDNS|${REPO_URL}slowdns/installsl.sh"
    )
    
    # Jalankan setiap langkah
    for step in "${steps[@]}"; do
        # Pisahkan deskripsi dan URL
        IFS='|' read -r description url <<< "$step"
        
        print_info "$description..."
        # Unduh dan jalankan, hentikan jika ada error
        wget -qO- "$url" | bash
        check_status "Gagal pada langkah: $description"
    done
    
    print_success "Semua komponen berhasil diinstal."
}

# --- EKSEKUSI UTAMA ---
start=$(date +%s)
get_domain
install_components

# --- FINALISASI ---
print_info "Melakukan finalisasi dan pembersihan..."
history -c
rm -f /root/*.sh
secs_to_human() {
    local T=$1
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    (( D > 0 )) && printf 'Waktu Instalasi: %d hari, %d jam, %d menit, %d detik\n' $D $H $M $S
    (( H > 0 )) && printf 'Waktu Instalasi: %d jam, %d menit, %d detik\n' $H $M $S
    (( M > 0 )) && printf 'Waktu Instalasi: %d menit, %d detik\n' $M $S
    (( S > 0 )) && printf 'Waktu Instalasi: %d detik\n' $S
}
secs_to_human "$(($(date +%s) - ${start}))"

print_info "Instalasi selesai. Server akan direboot dalam 5 detik."
sleep 5
reboot
