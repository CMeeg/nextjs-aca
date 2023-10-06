FROM mcr.microsoft.com/devcontainers/javascript-node:18-bullseye

# Install PowerShell
# https://learn.microsoft.com/en-us/powershell/scripting/install/install-debian?view=powershell-7.3#installation-via-direct-download
RUN PWSH_VERSION="7.3.7" \
    && wget https://github.com/PowerShell/PowerShell/releases/download/v${PWSH_VERSION}/powershell_${PWSH_VERSION}-1.deb_amd64.deb \
    && dpkg -i powershell_${PWSH_VERSION}-1.deb_amd64.deb \
    && rm powershell_${PWSH_VERSION}-1.deb_amd64.deb

# Install and configure Oh My Posh
# https://ohmyposh.dev/docs/installation/linux
# https://ohmyposh.dev/docs/installation/fonts
# https://ohmyposh.dev/docs/installation/prompt
# https://ohmyposh.dev/docs/installation/customize
# https://ohmyposh.dev/docs/themes
RUN JB_MONO_VERSION="3.0.2" \
    && PROFILE="/home/node/.config/powershell/Microsoft.PowerShell_profile.ps1" \
    && curl -s https://ohmyposh.dev/install.sh | bash -s \
    && apt install unzip \
    && wget https://github.com/ryanoasis/nerd-fonts/releases/download/v${JB_MONO_VERSION}/JetBrainsMono.zip \
    && unzip JetBrainsMono.zip -d /usr/share/fonts/truetype/JetBrainsMono \
    && rm JetBrainsMono.zip \
    && fc-cache -f -v \
    && mkdir -p "$(dirname "${PROFILE}")" && touch "${PROFILE}" \
    && echo 'oh-my-posh init pwsh --config "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/amro.omp.json" | Invoke-Expression' >> ${PROFILE}
