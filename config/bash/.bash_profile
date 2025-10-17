# shellcheck shell=bash
#
# ~/.bash_profile
#

# Load profile settings
# shellcheck disable=SC1090
[[ -f ~/.profile ]] && . ~/.profile

# Load bashrc for interactive settings
# shellcheck disable=SC1090
[[ -f ~/.bashrc ]] && . ~/.bashrc
