#!/bin/bash

# Grub2 Theme

ROOT_UID=0
THEME_DIR="/usr/share/grub/themes"
THEME_NAME=Xenlism-Arch

MAX_DELAY=20                                        # max delay for user to enter root password

#COLORS
CDEF=" \033[0m"                                     # default color
b_CCIN=" \033[1;36m"                                # bold info color
b_CGSC=" \033[1;32m"                                # bold success color
b_CRER=" \033[1;31m"                                # bold error color
b_CWAR=" \033[1;33m"                                # bold warning color

# echo like ...  with  flag type  and display message  colors
prompt () {
  case ${1} in
    "-s"|"--success")
      shift
      echo -e "${b_CGSC}$*${CDEF}";;          # print success message
    "-e"|"--error")
      shift
      echo -e "${b_CRER}$*${CDEF}";;          # print error message
    "-w"|"--warning")
      shift
      echo -e "${b_CWAR}$*${CDEF}";;          # print warning message
    "-i"|"--info")
      shift
      echo -e "${b_CCIN}$*${CDEF}";;          # print info message
    *)
    echo -e "$@"
    ;;
  esac
}

# Welcome message
prompt -s "\n\t*************************\n\t*  ${THEME_NAME} - Grub2 Theme  *\n\t*************************"

# Check command availability
function has_command() {
  command -v "$1" > /dev/null
}

prompt -w "\nChecking for root access...\n"

# Checking for root access and proceed if it is present
if [ "$UID" -eq "$ROOT_UID" ]; then

  # Create themes directory if not exists
  prompt -i "\nChecking for the existence of themes directory...\n"
  [[ -d "${THEME_DIR:?}/${THEME_NAME}" ]] && rm -rf "${THEME_DIR:?}/${THEME_NAME}"
  mkdir -p "${THEME_DIR}/${THEME_NAME}"

  # Copy theme
  prompt -i "\nInstalling ${THEME_NAME} theme...\n"

  cp -a ${THEME_NAME}/* ${THEME_DIR}/${THEME_NAME}

  # Set theme
  prompt -i "\nSetting ${THEME_NAME} as default...\n"

  # Backup grub config
  cp -an /etc/default/grub /etc/default/grub.bak

  grep "GRUB_THEME=" /etc/default/grub >/dev/null 2>&1 && sed -i '/GRUB_THEME=/d' /etc/default/grub

  echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub

  # Update grub config
  echo -e "Updating grub config..."
  if has_command update-grub; then
    update-grub
  elif has_command grub-mkconfig; then
    grub-mkconfig -o /boot/grub/grub.cfg
  elif has_command grub2-mkconfig; then
    if has_command zypper; then
      grub2-mkconfig -o /boot/grub2/grub.cfg
    elif has_command dnf; then
      grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
    fi
  fi

  # Success message
  prompt -s "\n\t          ***************\n\t          *  All done!  *\n\t          ***************\n"

else

  # Error message
  prompt -e "\n [ Error! ] -> Run me as root "

  # persisted execution of the script as root
  read -r -p "[ trusted ] specify the root password : " -t"${MAX_DELAY}" -s
  if [[ -n "$REPLY" ]]; then
    sudo -S <<< "$REPLY" "$0"
  else
    prompt  "\n Operation canceled  Bye"
    exit 1
  fi
fi
