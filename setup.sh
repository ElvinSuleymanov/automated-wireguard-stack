#!/bin/bash

# Just colors
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    YELLOW='\033[1;33m'
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    NC='\033[0m'
    echo -e "${CYAN}${BOLD}=================================================="
    echo -e "   🛡️  WIREGUARD STACK AUTOMATION UTILITY   "
    echo -e "==================================================${NC}"
# Change Defaults (Recommended)
    IP_WG="172.29.144.10"
    IP_UNBOUND="172.29.144.20"
    IP_PIHOLE="172.29.144.30"
    IP_NGINX="172.29.144.40"
    IP_AUTH="172.29.144.50"

# Checks whether docker installed or not 
    error() {
        echo -e "\n❌ ERROR: $1\n" >&2
        exit 1
    }

    check_command() {
        command -v "$1" >/dev/null 2>&1 || error "$1 is not installed.

    Please install it first:

    Docker:
    https://docs.docker.com/engine/install/

    Docker Compose:
    https://docs.docker.com/compose/install/"
    }

    echo "🔎 Checking system dependencies..."

    check_command docker

    if ! docker compose version >/dev/null 2>&1 && ! command -v docker-compose >/dev/null 2>&1; then
        error "Docker Compose is not installed.

    Install it from:
    https://docs.docker.com/compose/install/"
    fi

    echo "✅ Docker and Docker Compose are installed."


# Distro detection (gonna use it in further versions)
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "Running on: $ID"
    fi

# Timezone Detection
    DETECTED_TZ=$(timedatectl 2>/dev/null | grep "Time zone" | awk '{print $3}')
    if [ -z "$DETECTED_TZ" ]; then
        DETECTED_TZ=$(cat /etc/timezone 2>/dev/null || echo "UTC")
    fi
    echo "Detected Timezone: $DETECTED_TZ"

    ENV_FILE=".env"
    REUSE_ENV=false


# Try to fetch public ip either enter it manually if something wrong
    FETCHED_IP=$(curl -s --max-time 5 https://ifconfig.me/ || echo "")
    SUGGESTED_IP="${PUBLIC_IP:-$FETCHED_IP}"

    while true; do
        read -p "Is ${BOLD}${SUGGESTED_IP}${NC} your WireGuard server IP? (y/n): " yn
        case $yn in
            [Yy]* ) PUBLIC_IP="$SUGGESTED_IP"; break;;
            [Nn]* ) read -p "Enter your WireGuard server IP address: " PUBLIC_IP; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
# Composing containers
    docker compose up -d
# Other variables
    SERVER_PUBLIC_KEY = $(docker exec wireguard wg show wg0 public-key)
    WEBPASSWORD=$(openssl rand -base64 12) #Pi-hole UI password
    REGISTRATION_TOKEN=$(openssl rand -hex 32)


# Writing to .env file

 cat <<-EOF > "$ENV_FILE"
	WEBPASSWORD=$WEBPASSWORD
	TIMEZONE=$DETECTED_TZ
	IP_UNBOUND=$IP_UNBOUND
	IP_PIHOLE=$IP_PIHOLE
	IP_WIREGUARD=$IP_WIREGUARD
	PUBLIC_IP=$PUBLIC_IP
	WIREGUARD_PUBLIC_PORT=$USER_PORT
	REGISTRATION_TOKEN=$REGISTRATION_TOKEN
	SERVER_PUBLIC_KEY=$SERVER_PUBLIC_KEY
	EOF

# Check if anything wrong
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}${BOLD}✅ Stack is up and running!${NC}"
        docker compose ps
    else
        echo -e "\n${RED}${BOLD}❌ docker compose failed. Check logs with: docker compose logs${NC}"
        exit 1
    fi


# Client scripts generation
    mkdir -p ./scripts

    cat << EOF > setupclient.ps1
    if ((Get-Command wireguard -ErrorAction SilentlyContinue) -or (Get-Command wg -ErrorAction SilentlyContinue)) {
        Write-Output "WireGuard CLI is accessible."
    } else {
        Write-Output "Binary not found in PATH."
    }
    EOF

    cat << EOF > /scripts/setupclient.sh
    #!/bin/bash
    echo hello
    EOF

    chmod +x ./scripts/*
