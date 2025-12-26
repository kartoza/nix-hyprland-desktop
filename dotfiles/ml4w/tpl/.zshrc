#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#
# -----------------------------------------------------
# ML4W zshrc loader
# -----------------------------------------------------

# DON'T CHANGE THIS FILE

# You can define your custom configuration by adding
# files in /etc/xdg/zshrc
# or by creating a folder /etc/xdg/zshrc/custom
# with you own zshrc configuration
# -----------------------------------------------------

if [ -d /etc/xdg/zshrc/custom ]; then
    for f in /etc/xdg/zshrc/custom/*; do source $f; done
else
    for f in /etc/xdg/zshrc/*; do source $f; done
fi