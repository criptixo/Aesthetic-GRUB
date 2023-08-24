#!/bin/bash

THEME_DIR='/usr/share/grub/themes'
THEME_NAME=''

function echo_title() {     echo -ne "\033[1;44;37m${*}\033[0m\n"; }
function echo_caption() {   echo -ne "\033[0;1;44m${*}\033[0m\n"; }
function echo_bold() {      echo -ne "\033[0;1;34m${*}\033[0m\n"; }
function echo_danger() {    echo -ne "\033[0;31m${*}\033[0m\n"; }
function echo_success() {   echo -ne "\033[0;32m${*}\033[0m\n"; }
function echo_warning() {   echo -ne "\033[0;33m${*}\033[0m\n"; }
function echo_secondary() { echo -ne "\033[0;34m${*}\033[0m\n"; }
function echo_info() {      echo -ne "\033[0;35m${*}\033[0m\n"; }
function echo_primary() {   echo -ne "\033[0;36m${*}\033[0m\n"; }
function echo_error() {     echo -ne "\033[0;1;31mError:\033[0;31m\t${*}\033[0m\n"; }
function echo_label() {     echo -ne "\033[0;1;32m${*}:\033[0m\t"; }
function echo_prompt() {    echo -ne "\033[0;36m${*}\033[0m "; }

function splash() {
    local hr
    hr=" **$(printf "%${#1}s" | tr ' ' '*')** "
    echo_title "${hr}"
    echo_title " * $1 * "
    echo_title "${hr}"
    echo
}

function check_root() {
    # Checking for root access and proceed if it is present
    ROOT_UID=0
    if [[ ! "${UID}" -eq "${ROOT_UID}" ]]; then
        # Error message
        echo_error 'Run me as root.'
        echo_info 'try sudo ./install.sh'
        exit 1
    fi
}

function select_theme() {

    cd ./themes
    declare -a dirs
        i=1
        for d in */
        do
            dirs[i++]="${d%/}"
        done

    echo_warning "\nI found  the following template(s) in the themes directory:"

    echo "0 | Abort program"
    for((i=1;i<=${#dirs[@]};i++))
        do
            echo $i "| ${dirs[i]}"
        done

    echo_prompt "\nPlease Enter the number of the theme you want to install: "

    read i

    THEME_NAME="${dirs[$i]}"

    if [[ i -le 0 ]]; then
        echo_warning "\nRunning was interrupted by User. Abort run..."
        exit 1
    fi

}

function selected_theme() {
    # Check if valid theme nummer selected
    if [[ ! -e "${THEME_NAME}" ]]; then
        echo_error "${wrong_selected}"

        exit 1
    fi
}

function set_timeout(){
    # Waiting for user to enter Grub Timeout between 1 and 99

    echo_prompt "$\nPlease enter Grub Timeout in seconds (recommended 3-10 sec): "

    read GRUB_TIMEOUT

    format='^[0-9]{1,2}$'

    if [[ ! $GRUB_TIMEOUT =~ $format ]]; then

        echo_error "\nThe specified format is incorrect. Only numbers between 1 and 99 are allowed. Abort run..."

       exit 1
    fi

    if [[ $GRUB_TIMEOUT -le 0 ]]; then

        echo_error "$\nThe specified format is incorrect. Only numbers between 1 and 99 are allowed. Abort run..."

        exit 1
    fi
}

function backup() {
    # Backup grub config
    echo_info 'cp -an /etc/default/grub /etc/default/grub.bak'
    cp -an /etc/default/grub /etc/default/grub.bak
}

function install_theme() {
    # create themes directory if not exists
    if [[ ! -d "${THEME_DIR}/${THEME_NAME}" ]]; then
        # Copy theme
        echo_primary "${installing_theme}"

        echo_info "mkdir -p \"${THEME_DIR}/${THEME_NAME}\""
        mkdir -p "${THEME_DIR}/${THEME_NAME}"

        echo_info "cp -a ./\"${THEME_NAME}\"/* \"${THEME_DIR}/${THEME_NAME}\""
        cp -a "${THEME_NAME}"/* "${THEME_DIR}/${THEME_NAME}"
    fi
}

function config_grub() {
    echo_primary "Installing selected theme..."
    # remove default grub style if any
    echo_info "sed -i '/GRUB_TIMEOUT_STYLE=/d' /etc/default/grub"
    sed -i '/GRUB_TIMEOUT_STYLE=/d' /etc/default/grub

    echo_info "echo 'GRUB_TIMEOUT_STYLE=\"menu\"' >> /etc/default/grub"
    echo 'GRUB_TIMEOUT_STYLE="menu"' >> /etc/default/grub

    #--------------------------------------------------

    echo_primary "Setting grub timeout to given time"
    # remove default timeout if any
    echo_info "sed -i '/GRUB_TIMEOUT=/d' /etc/default/grub"
    sed -i '/GRUB_TIMEOUT=/d' /etc/default/grub

    echo_info "echo 'GRUB_TIMEOUT=\""${GRUB_TIMEOUT}"\"' >> /etc/default/grub"
    echo "GRUB_TIMEOUT=\"${GRUB_TIMEOUT}\"" >> /etc/default/grub

    #--------------------------------------------------

    echo_primary "Set the selected theme as default"
    # remove theme if any
    echo_info "sed -i '/GRUB_THEME=/d' /etc/default/grub"
    sed -i '/GRUB_THEME=/d' /etc/default/grub

    echo_info "echo \"GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"\" >> /etc/default/grub"
    echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub
}

function update_grub() {
    # Update grub config
    echo_primary "Updating grub config..."
    if [[ -x "$(command -v update-grub)" ]]; then
        echo_info 'update-grub'
        update-grub

    elif [[ -x "$(command -v grub-mkconfig)" ]]; then
        echo_info 'grub-mkconfig -o /boot/grub/grub.cfg'
        grub-mkconfig -o /boot/grub/grub.cfg

    elif [[ -x "$(command -v grub2-mkconfig)" ]]; then
        if [[ -x "$(command -v zypper)" ]]; then
            echo_info 'grub2-mkconfig -o /boot/grub2/grub.cfg'
            grub2-mkconfig -o /boot/grub2/grub.cfg

        elif [[ -x "$(command -v dnf)" ]]; then
            echo_info 'grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg'
            grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
        fi
    fi
}

function main() {
    splash 'Aesthetic-GRUB'

    check_root

    select_theme

    selected_theme

    set_timeout

    install_theme

    config_grub

    update_grub

    echo_success "All done !"
}

main