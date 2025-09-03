#!/bin/bash
# =========================================================
#       BZ VPN STORE - AUTOSCRIPT INSTALLER (FINAL)
# =========================================================

# Menonaktifkan IPv6 untuk meningkatkan kompatibilitas beberapa layanan
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

# --- KONFIGURASI REPOSITORI (SUDAH DIARAHKAN KE REPO ANDA) ---
REPO_URL="https://raw.githubusercontent.com/gogoyeee00-bit/os/main/"

# --- FUNGSI BANTUAN & WARNA ---
clear
red='\e[1;31m'; green='\e[0;32m'; yell='\e[1;33m'; NC='\033[0m'
print_info() { echo -e "\n${yell}[INFO]${NC} $1"; }
print_success() { echo -e "${green}[SUKSES]${NC} $1"; }
print_error() { echo -e "${red}[ERROR]${NC} $1"; exit 1; }
check_status() {
    if [ $? -ne 0 ]; then
        print_error "$1"
    fi
}

# --- PEMERIKSAAN AWAL SISTEM ---
cd /root
if [ "${EUID}" -ne 0 ]; then print_error "Skrip ini harus dijalankan sebagai root."; fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then print_error "OpenVZ tidak didukung."; fi

# --- PERSIAPAN AWAL (DEPENDENSI DASAR) ---
print_info "Melakukan update sistem dan instalasi dependensi dasar..."
apt-get update -y >/dev/null 2>&1
apt-get install -y bzip2 gzip coreutils screen curl git
check_status "Gagal menginstal dependensi dasar."
mkdir -p /var/lib/ >/dev/null 2>&1
echo "IP=" > /var/lib/ipvps.conf
print_success "Persiapan awal selesai."

# --- BANNER & INPUT PENGGUNA ---
echo -e "$green  ____ ____ ____ _  _ ____ _  _    _  _ ____ _  _ ____ _  _ ____ $NC"
echo -e "$green  | __ |___ |__/ |\\/| |__| |\\ |    |\\/| |  | |\\ | |___ |\\/| |___ $NC"
echo -e "$green  |__] |___ |  \\ |  | |  | | \\|    |  | |__| | \\| |___ |  | |___ $NC"
echo -e "$green                                                                $NC"
echo -e "$green    ♥ TERIMA KASIH TELAH MEMAKAI SCRIPT BZ VPN STORE ♥$NC"
sleep 3; clear

function get_domain(){
    print_info "SETUP DOMAIN VPS"
    echo "----------------------------------------------------------"
    read -rp "Silakan masukkan domain Anda yang valid: " user_domain
    if [ -z "$user_domain" ]; then
        print_error "Domain tidak boleh kosong."
    fi
    
    # Simpan domain ke beberapa lokasi yang dibutuhkan oleh skrip komponen
    mkdir -p /etc/xray
    echo "$user_domain" > /etc/xray/domain
    echo "$user_domain" > /root/domain
    echo "IP=$user_domain" > /var/lib/ipvps.conf
    print_success "Domain telah diatur ke: $user_domain"
    sleep 2; clear
}

function install_components(){
    print_info "Memulai instalasi semua komponen skrip..."
    
    # Definisikan semua langkah instalasi secara berurutan
    local steps=(
        "Menjalankan persiapan tools|${REPO_URL}tools.sh"
        "Menginstal SSH & OpenVPN|${REPO_URL}install/ssh-vpn.sh"
        "Menginstal Xray Core|${REPO_URL}install/ins-xray.sh"
        "Menginstal Websocket|${REPO_URL}sshws/insshws.sh"
        "Menginstal Menu Backup & Restore|${REPO_URL}install/set-br.sh"
        "Mengunduh Menu Tambahan & Mengirim Notifikasi|${REPO_URL}menu/update.sh"
        "Menginstal SlowDNS|${REPO_URL}slowdns/installsl.sh"
    )
    
    # Eksekusi setiap langkah
    for step in "${steps[@]}"; do
        IFS='|' read -r description url <<< "$step"
        
        print_info "$description..."
        local filename=$(basename "$url")
        
        # Unduh, berikan izin, dan jalankan. Hentikan jika ada error.
        wget -q -O "$filename" "$url"
        check_status "Gagal mengunduh $filename dari $url"
        
        chmod +x "$filename"
        
        # Jalankan skrip dan hentikan jika gagal
        if ! ./"$filename"; then
            print_error "Terjadi kesalahan saat menjalankan: $description"
        fi
    done
    
    print_success "Semua komponen berhasil diinstal."
}

# --- EKSEKUSI UTAMA ---
start_time=$(date +%s)
get_domain
install_components

# --- FINALISASI ---
print_info "Melakukan finalisasi dan pembersihan..."
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
history -c
rm -f /root/*.sh

# Hitung waktu instalasi
end_time=$(date +%s)
secs_to_human() {
    local T=$1; local M=$((T/60%60)); local S=$((T%60))
    printf 'Waktu Instalasi: %d menit, %d detik\n' $M $S
}
secs_to_human "$((end_time - start_time))"

print_info "Instalasi selesai. Server akan direboot dalam 5 detik."
sleep 5
reboot
