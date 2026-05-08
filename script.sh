#!/bin/bash

# Verifica Root
if [ "$EUID" -ne 0 ]; then
    echo "Execute este script como root."
    exit 1
fi

# ==========================================================================================#
# FUNÇÕES
# ==========================================================================================#

atualizar() {
    echo "Iniciando atualização do sistema..."
    if apt update && apt upgrade -y; then
        echo -e "\nAtualização Concluída com sucesso.\n"
    else
        echo -e "\nErro ao atualizar o sistema.\n"
    fi
}

reiniciar(){
    echo "O sistema irá reiniciar em 5 segundos..."
    sleep 5
    reboot
}

remover_programas() {
    if apt purge "$2"* -y && apt autoremove -y; then
        echo -e "$1 foi removido.\n"
    
    else
        echo -e "Erro: $1 não foi removido.\n"
    
    fi
}

sources_list() {
    while true;do
            echo ""
            echo "----- Sources List -----"
            echo "1. Sources.list padrão."
            echo "2. Converter para DEB822."
            echo "3. Voltar"

            read -p "Escolha a opção: " SOURCES
            case $SOURCES in

            1)
                    cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
EOF
      apt update ; apt dist-upgrade
      echo "Concluído!"
      ;;
            2)
                mv /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null
                
                cat <<EOF > /etc/apt/sources.list.d/debian.sources
Types: deb deb-src
URIs: https://deb.debian.org/debian
Suites: trixie trixie-updates
Components: main contrib non-free non-free-firmware
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb deb-src
URIs: https://security.debian.org/debian-security
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
                #apt modernize-sources
                apt update && apt dist-upgrade -y
                echo "Repositórios DEB822 configurados com sucesso!"
                ;;

            3)
                break
                ;;
            esac
        done
        ;;
}

drivers_nvidia(){
    while true; do
        echo "1. Jogos/Edição."
        echo "2. IA."
        echo "3. Voltar"
        read -p "Escolha a opção: " NVIDIA

        case $NVIDIA in
                1)
                    apt install --no-install-recommends dkms libdw-dev clang lld llvm build-essential linux-headers-amd64 pipewire-audio-client-libraries
                    wget https://developer.download.nvidia.com/compute/cuda/repos/debian13/x86_64/cuda-keyring_1.1-1_all.deb
                    dpkg -i cuda-keyring_1.1-1_all.deb
                    apt update
                    apt -y install nvidia-open
                    echo "Instalação Concluída!"
                    ;;
                
                2)
                    apt install --no-install-recommends dkms libdw-dev clang lld llvm build-essential linux-headers-amd64 pipewire-audio-client-libraries
                    wget https://developer.download.nvidia.com/compute/cuda/repos/debian13/x86_64/cuda-keyring_1.1-1_all.deb
                    dpkg -i cuda-keyring_1.1-1_all.deb
                    apt update
                    apt -y install cuda-drivers cuda-toolkit
                    echo "Instalação Concluída!"
                    ;;
                
                3) break;;
                esac
            done;;
}

configurar_swappines() {
    while true; do
            echo ""
            echo "------ Ajustar Swappiness -----"
            echo "1. Configurar para 10."
            echo "2. Verificar valor atual."
            echo "3. Voltar."

            read -p "Escolha a opção: " SWAP
            case $SWAP in
                1)
                    sysctl vm.swappiness=10
                    echo 'vm.swappiness=10' >> /etc/sysctl.conf
                    echo "Swappiness ajustado para 10!"
                    ;;
                2)
                    cat /proc/sys/vm/swappiness
                    ;;
                3)
                    break
                    ;;
                esac
            done
            ;;
}

configurar_flatpak() {
    while true;do
            echo "1. Kde"
            echo "2. Gnome."
            echo "3. Voltar."

            read -p  "Escolha a opção: " FLATPAK
            case $FLATPAK in

                1)
                    apt install flatpak
                    apt install plasma-discover-backend-flatpak
                    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                    echo "Será necessário reiniciar o aplicativo da loja para finalizar completamente."
                    ;;
                
                2)
                    apt install flatpak
                    apt install gnome-software-plugin-flatpak
                    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                    echo "Será necessário reiniciar o aplicativo da loja para finalizar completamente."
                    ;;
                
                3)
                    break
                    ;;
                esac
            done
            ;;
}

configurar_firewall() {
    apt install ufw gufw -y
    ufw enable
    echo "Concluído!"

    sleep 3
}

habilitar_sudo() {
    if id "$USUARIO" &>/dev/null; then
        
        usermod -aG sudo "$USUARIO"
        echo "$USUARIO ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/90-$USUARIO"
        chmod 440 /etc/sudoers.d/90-$USUARIO
        echo "Usuário $USUARIO adicionado ao grupo sudo."
    else
        echo "Usuário $USUARIO não encontrado."
    fi
    sleep 5
}

ferramentas_utilitarios() {
    while true; do
        echo "1. Htop."
        echo "2. Neofetch."
        echo "3. Outras ferramentas (Decompactação, instalador de pacotes, etc...)."
        echo "4. Git"
        echo "5. Voltar"

        read -p "Escolha a opção: " FERRAMENTAS

        case $FERRAMENTAS in
            1) apt install htop -y;;
            2) apt install neofetch -y;;
            3) apt install gparted synaptic gdebi tilix arc arj cabextract lhasa p7zip p7zip-full p7zip-rar rar unrar unace unzip xz-utils zip -y;;
            4) apt install git -y;;
            5) break;;
        esac
    done
}

instalando_programas_flatpak() {
    while true; do
        echo "1. Spotify."
        echo "2. Discord."
        echo "3. Visual Studio Code."
        echo "4. Google Chrome."
        echo "5. OnlyOffice."
        echo "6. qBittorrent."
        echo "7. Steam."
        echo "8. Prism Launcher."
        echo "9. GNOME Boxes."
        echo "10. Voltar."

        read -p "Escolha a opção: " PROGRAMAS

        case $PROGRAMAS in
            1) flatpak install flathub com.spotify.Client -y;;
            2) flatpak install flathub com.discordapp.Discord -y;;
            3) flatpak install flathub com.visualstudio.code -y;;
            4) flatpak install flathub com.google.Chrome -y;;
            5) flatpak install flathub org.onlyoffice.desktopeditors -y;;
            6) flatpak install flathub org.qbittorrent.qBittorrent -y;;
            7) flatpak install flathub com.valvesoftware.Steam -y;;
            8) flatpak install flathub org.prismlauncher.PrismLauncher -y;;
            9) flatpak install flathub org.gnome.Boxes -y;;
            10) break;;
        esac
    done
}

instalando_docker() {
    apt install ca-certificates curl gnupg lsb-release -y
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update
    apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    echo "Instalação do Docker concluída!"

    sleep 4
}

# ==========================================================================================#
# SUBMENU
# ==========================================================================================#

menu_desinstalar_programas() {
    while true; do
        echo "----- Desinstalar Programas -----"
        echo "1. Desinstalar Gnome Games"
        echo "2. Desinstalar LibreOffice"
        echo "3. Desinstalar Firefox-esr"
        echo "4. Voltar"
        echo "---------------------------------"

        read -p "Escolha a opção: " REMOVER

        case $REMOVER in
            1) remover_programas "Gnome Games" "gnome-games";; 
                
            2) remover_programas "LibreOffice" "libreoffice";;
                
            3) remover_programas "Firefox-esr" "firefox-esr";;

            4) break;;
        esac
    done
}


# ==========================================================================================#
# MENU PRINCIPAL
# ==========================================================================================#

while true; do
    echo "----- Menu Principal -----"
    echo "1. Desinstalar programas padrão."
    echo "2. Divers Nvidia."
    echo "3. Configurar Sources List."
    echo "4. Configurar Swappiness."
    echo "5. Configurar Flatpak."
    echo "6. Configurar Firewall."
    echo "7. Configurar Sudo."
    echo "8. Ferramentas e utilitários."
    echo "9. Programas."
    echo "10. Instalar Docker."
    echo "97. Atualizar."
    echo "98. Reiniciar."
    echo "99. Sair."

    read -p "Opção: " OP

    case $OP in
        1) menu_desinstalar_programas;;
        2) drivers_nvidia;;
        3) sources_list;;
        4) configurar_swappines;;
        5) configurar_flatpak;;
        6) configurar_firewall;;
        7) habilitar_sudo;;
        8) ferramentas_utilitarios;;
        9) instalando_programas_flatpak;;
        10) instalando_docker;;
        97) atualizar;;
        98) reiniciar;;
        99) exit 0;;
    esac
done