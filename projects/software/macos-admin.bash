#!/usr/bin/env bash
#
# install neuroimaging software on adminstered macOS
# 
# also see 
#   https://macos.gadgethacks.com/how-to/open-third-party-apps-from-unidentified-developers-macos-0158095/
#   system preferences -> Security & Privacy -> "Open Anyway"
# 20240531WF - init

ADMIN_ACCOUNT=Oacadmin
USER_ACCOUNT="${1:-$ADMIN_ACCOUNT}"; shift

# packages to get from the internet
# 20240531: using arm versions (instead of intel/x64)
DMGS=(
  https://download1.rstudio.org/electron/macos/RStudio-2024.04.1-748.dmg
)

ZIPS=(
   https://github.com/frankyeh/DSI-Studio/releases/download/2024.05.22/dsi_studio_macos-13_qt6.zip
)
PKG=(
   https://github.com/XQuartz/XQuartz/releases/download/XQuartz-2.8.5/XQuartz-2.8.5.pkg
   https://cran.rstudio.com/bin/macosx/big-sur-arm64/base/R-4.4.0-arm64.pkg
)
# packages to get from homebrew
BREWPKGS=(
  git python
  gfortran libxml++ openblas lapack # compile R package
  netpbm # afni
)

install_dmg(){
 dmg=${1?-.dmg file}; shift
 dmg_name=${1?-path inside dmg mount}

 hdiutil mount "$dmg"
 # todo: test if already exists
 cp -r /Volumes/"$dmg_name"/*.app /Applications/
 hdiutil ymount "$dmg_name"
}

install_homebrew(){
   # homebrew. todo must be done as $ADMIN_ACCOUNT
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   source ~/.zprofile # get brew in path
   brew install "${BREWPKGS[@]}"
}

install_vagrant(){ # for singularity
   brew cask install virtualbox && \
    brew cask install vagrant && \
    brew cask install vagrant-manager

   local VM=sylabs/singularity-3.0-ubuntu-bionic64 
   vagrant init $VM && \
    vagrant up && \
    vagrant ssh
}

# afni is install into home directory of the main user
install_afni(){
   cd $HOME
   curl -O https://afni.nimh.nih.gov/pub/dist/bin/misc/@update.afni.binaries
   tcsh @update.afni.binaries -package macos_10.12_local -do_extras
}

# export functions so sudo can use them
export -f install_homebrew install_dmg install_afni


# use 'DRYRUN=1 ./macos-admin.bash' to just show what would happen instead of doing it
[ -v DRYRUN ] && DRYRUN=echo || DRYRUN=

# need root to run
[ $(id -u) -gt 1 ] && echo "run script with sudo! like: 'sudo $0'" && exit 1

# passwordless sudo for admin
# todo: add -i for inplace mod
$DRYRUN sed '$s,$,\n%wheel  ALL=(ALL) NOPASSWD: ALL,' /etc/sudoers

$DRYRUN xcode-select --install
$DRYRUN sudo -u $ADMIN_ACCOUNT install_homebrew
$DRYRUN sudo -u $ADMIN_ACCOUNT install_vagrant

$DRYRUN sudo -u $USER_ACCOUNT install_afni

# afni r packages
$DRYRUN sudo -u $USER_ACCOUNT /Users/$USER_ACCOUNT/abin/rPkgsInstall -pkgs ALL
