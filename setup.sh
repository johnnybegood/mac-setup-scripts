#!/bin/sh

# List of applications to install via brew
declare -a brewApps=("mas" "python" "git" "ykman" "nvm" "wget" "zsh" "zplug" "duti" "azure-cli" "openssl", "dotnet", "jandedobbeleer/oh-my-posh/oh-my-posh")

# List of applications to install via brew cask
declare -a brewCaskApps=("iterm2" "the-unarchiver" "1password" "firefox" "powershell" "docker" "visual-studio-code" "caffeine" "spotify" "postman" "wireshark" "font-fira-code" "vlc" "parallels" "yubico-authenticator")

# Global node packages to install
declare -a globalNodePackages=("npm@latest" "yarn")

# List of applications ids to install via Mac App Store
# 497799835 Xcode
declare -a masApps=("497799835")

# Log file
timestamp=$(date +%s)
logFile="./mac-setup-$timestamp.log"

# if true is passed in, things will reinstall
reinstall=$1

beginInstallation() {
  echo "Starting installation for $1..." | tee -a $logFile
}

installComplete() {
  echo "Installation complete for $1.\n\n\n" | tee -a $logFile
}

echo "Installing command line tools" | tee -a $logFile
xcode-select --install

# https://stackoverflow.com/a/26647594/77814
echo "Setting correct permissions on folders that brew needs acccess to."
sudo chown -R `whoami`:admin /usr/local/bin
sudo chown -R `whoami`:admin /usr/local/sbin
sudo chown -R `whoami`:admin /usr/local/share

# Install applications
echo "Installing applications. You may be prompted at certain points to provide your password." | tee -a $logFile

command -v brew >/dev/null 2>&1 || {
  beginInstallation "Homebrew"

  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  installComplete "Homebrew"
} | tee -a $logFile

for appName in "${brewApps[@]}"
do
  beginInstallation $appName | tee -a $logFile

  if [ $reinstall=true ]; then
    brew reinstall $appName | tee -a $logFile
  else
    brew install $appName | tee -a $logFile
  fi

  installComplete $appName | tee -a $logFile
done

for appName in "${brewCaskApps[@]}"
do
  beginInstallation $appName | tee -a $logFile

  if [ $reinstall=true ]; then
    brew reinstall $appName --cask | tee -a $logFile
  else
    brew install $appName --cask | tee -a $logFile
  fi

  installComplete $appName | tee -a $logFile
done

for appName in "${brewCaskApps[@]}"
do
  beginInstallation $appName | tee -a $logFile

  if [ $reinstall=true ]; then
    brew cask reinstall $appName | tee -a $logFile
  else
    brew cask install $appName | tee -a $logFile
  fi

  installComplete $appName | tee -a $logFile
done

beginInstallation "Setting up node.js" | tee -a $logFile

export NVM_DIR="$HOME/.nvm"
mkdir $NVM_DIR

[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm

echo "Installing LTS version of node."
nvm install --lts
nvm alias default "lts/*"
nvm use default
installComplete "Finished installing node.js." | tee -a $logFile

beginInstallation "Installing global node packages" | tee -a $logFile
npm i -g "${globalNodePackages[@]}" | tee -a $logFile
installComplete "Finished installing global node packages." | tee -a $logFile

for appId in "${masApps[@]}"
do
    beginInstallation $appId | tee -a $logFile

    mas info $appId | tee -a $logFile

    if [ $reinstall=true ]; then
        mas install $appId --force | tee -a $logFile
    else
        mas install $appId | tee -a $logFile
    fi

    installComplete $appName | tee -a $logFile
done

echo "Done installing applications" | tee -a $logFile
echo "\n\n\n" | tee -a $logFile
echo "Just a few final touches..." | tee -a $logFile

# Make zsh the default shell
echo "Making zsh the default shell" | tee -a $logFile

sudo dscl . -create /Users/$USER UserShell /bin/zsh | tee -a $logFile
echo which zsh | tee -a $logFile
dscl . -read /Users/$USER UserShell | tee -a $logFile
echo $SHELL | tee -a $logFile
chsh -s $(which zsh) | tee -a $logFile

echo "Installing oh-my-zsh" | tee -a $logFile
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" | tee -a $logFile

echo "Installing some plugins for zsh" | tee -a $logFile
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions | tee -a $logFile

echo "Creating .zshrc file" | tee -a $logFile
touch ~/.zshrc | tee -a $logFile
echo "export ZPLUG_HOME=/usr/local/opt/zplug
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
export GEM_HOME=$HOME/.gem
export NVM_LAZY_LOAD=true
export PATH=$HOME/.rbenv/shims:$GEM_HOME/bin:$HOME/.cargo/bin:$PATH
export ZSH=$HOME/.oh-my-zsh
export NVM_DIR=\"$HOME/.nvm\"
[ -s \"/usr/local/opt/nvm/nvm.sh\" ] && . \"/usr/local/opt/nvm/nvm.sh\"  # This loads nvm
[ -s \"/usr/local/opt/nvm/etc/bash_completion\" ] && . \"/usr/local/opt/nvm/etc/bash_completion\"  # This loads nvm bash_completion
ZSH_THEME="robbyrussell"
COMPLETION_WAITING_DOTS="true"
DEFAULT_USER=`whoami`
plugins=(
  git
  docker
  iterm2
  npm
  dotenv
  macos
  vscode
)
source $ZSH/oh-my-zsh.sh
source $ZPLUG_HOME/init.zsh
source <(_YKMAN_COMPLETE=source ykman | sudo tee /etc/bash_completion.d/ykman)

autoload bashcompinit
bashcompinit

alias rimraf='rm -rf'
alias flushdns='sudo killall -HUP mDNSResponder'
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"" > ~/.zshrc | tee -a $logFile

echo "Setting up powershell profile" | tee -a $logFile
touch ~/.config/powershell/profile.ps1 | tee -a $logFile
echo "oh-my-posh init pwsh --config /opt/homebrew/opt/oh-my-posh/themes/cloud-native-azure.omp.json | Invoke-Expression" > ~/.config/powershell/profile.ps1 | tee -a $logFile


echo "Finished setup \n\n\n"
echo "A setup log is available at $logFile."
echo "Some components require a reboot"