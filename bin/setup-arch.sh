!/bin/bash

# Arch Linux System Post-Installation Setup Script

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

printf_info() {
  echo -e "${YELLOW}[INFO]${NC} $1"
}
printf_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}
printf_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

if ! command -v pacman &>/dev/null; then
  printf_error "This script must be run on an Arch Linux system."
  exit 1
fi

install_packages() {
  printf_info "Installing packages: $*"

  sudo pacman -S --noconfirm --needed "$@" >/dev/null 2>&1

  if [ $? -eq 0 ]; then
    printf_success "Installed packages: $*"
  else
    printf_error "Failed to install packages: $*"
    exit 1
  fi
}

enable_service() {
  local service_name=$1
  printf_info "Enabling service: $service_name"

  sudo systemctl enable "$service_name" >/dev/null 2>&1
  sudo systemctl start "$service_name" >/dev/null 2>&1

  if [ $? -eq 0 ]; then
    printf_success "Enabled service: $service_name"
  else
    printf_error "Failed to enable service: $service_name"
    exit 1
  fi
}

main() {
  setup_locale
  network
  install_yay
  cpu_microcode
  essential_packages
  gpu_drivers
  display_manager
  desktop_environment
  setup_shell
  audio
  fonts
  dev_tools
  bluetooth
}

main "$@"
