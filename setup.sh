#!/bin/sh

# List of applications to install via brew
declare -a brewApps=("mas" "python" "git" "nvm" "wget" "zsh" "zplug" "duti" "azure-cli" "jmeter" "openssl" "cocoapods" "dnscrypt-proxy")

# List of applications to install via brew cask
declare -a brewCaskApps=("micro-snitch" "little-snitch" "iterm2" "the-unarchiver" "1password" "firefox" "dotnet" "powershell" "docker" "visual-studio-code" "caffeine" "sketch" "axure-rp" "fritzing" "spotify" "dbeaver-community" "balenaetcher" "airserver" "visual-studio" "microsoft-office" "notion" "microsoft-team" "fromscratch" "owasp-zap" "google-chrome" "postman" "wireshark" "zoomus" "font-fira-code" "vlc" "parallels" "yubico-authenticator")

# Global node packages to install
declare -a globalNodePackages=("npm@latest" "yarn")

# Visual Studio Code extensions to install
declare -a codeExtensions=("auchenberg.vscode-browser-preview" "bencoleman.armview" "coolbear.systemd-unit-file" "cssho.vscode-svgviewer" "davidmarek.jsonpath-extract" "dbaeumer.vscode-eslint" "digital-molecules.service-bus-explorer" "DotJoshJohnson.xml" "dweizhe.docthis-customize-tags" "eamodio.gitlens" "EditorConfig.EditorConfig" "eg2.vscode-npm-script" "emilast.LogFileHighlighter" "fabianlauer.vs-code-xml-format" "felipecaputo.git-project-manager" "firefox-devtools.vscode-firefox-debug" "formulahendry.dotnet-test-explorer" "HookyQR.beautify" "k--kato.docomment" "mechatroner.rainbow-csv" "mermade.openapi-lint" "mkaufman.HTMLHint" "mkxml.vscode-filesize" "mohsen1.prettify-json" "ms-azure-devops.azure-pipelines" "ms-azuretools.vscode-apimanagement" "ms-azuretools.vscode-azurestorage" "ms-azuretools.vscode-cosmosdb" "ms-azuretools.vscode-docker" "ms-dotnettools.csharp" "ms-mssql.mssql" "ms-vscode.azure-account" "ms-vscode.azurecli" "ms-vscode.mono-debug" "ms-vscode.powershell" "ms-vsliveshare.vsliveshare" "ms-vsts.team" "msazurermtools.azurerm-vscode-tools" "msjsdiag.debugger-for-chrome" "philosowaffle.openapi-designer" "quicktype.quicktype" "redhat.vscode-yaml" "Shan.code-settings-sync" "VisualStudioExptTeam.vscodeintellicode" "vscode-icons-team.vscode-icons" "yzhang.markdown-all-in-one")

# List of applications ids to install via Mac App Store
# 441258766 Magnet
# 497799835 Xcode
# 1039633667 Irvue
# 1250306151 Shotty
declare -a masApps=("441258766" "497799835" "1039633667" "1250306151")

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

  beginInstallation "Homebrew Cask"
  brew tap caskroom/cask
  installComplete "Homebrew Cask"
} | tee -a $logFile

echo "Setting up some brew tap stuff for fonts and some applications" | tee -a $logFile
brew tap homebrew/cask-versions | tee -a $logFile
brew tap homebrew/cask-fonts | tee -a $logFile
echo "Finished setting up some brew tap stuff for fonts and some applications" | tee -a $logFile

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
    brew cask reinstall $appName | tee -a $logFile
  else
    brew cask install $appName | tee -a $logFile
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
  osx
  vscode
  zsh-nvm
)
source $ZSH/oh-my-zsh.sh
source $ZPLUG_HOME/init.zsh

autoload bashcompinit
bashcompinit

alias rimraf='rm -rf'
alias flushdns='sudo killall -HUP mDNSResponder'
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"" > ~/.zshrc | tee -a $logFile

echo "Installing some extensions for Visual Studio Code" | tee -a $logFile
for extension in "${codeExtensions[@]}"
do
    beginInstallation $extension | tee -a $logFile

    /usr/local/bin/code --install-extension $extension | tee -a $logFile

    installComplete $extension | tee -a $logFile
done

echo "Securing machine,  manual interaction is required" | tee -a $logFile
sudo pip install stronghold | tee -a $logFile
sudo stronghold | tee -a $logFile

echo "Updating host file" | tee -a $logFile
curl https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts | sudo tee -a /etc/hosts

echo "Verifying new host file size" | tee -a $logFile
wc -l /etc/hosts | tee -a $logFile

echo "Finished setup \n\n\n"
echo "A setup log is available at $logFile."
echo "Some components require a reboot"