#!/bin/bash

CYAN='\033[0;36m'
BOLD='\033[1m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}=================================================="
echo -e "   🛡️  WIREGUARD STACK AUTOMATION UTILITY"
echo -e "==================================================${NC}"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Running on: $ID"
fi

DETECTED_TZ=$(timedatectl 2>/dev/null | grep "Time zone" | awk '{print $3}')
if [ -z "$DETECTED_TZ" ]; then
    DETECTED_TZ=$(cat /etc/timezone 2>/dev/null || echo "UTC")
fi
echo "Detected Timezone: $DETECTED_TZ"

ENV_FILE=".env"
REUSE_ENV=false

if [ -f "$ENV_FILE" ]; then
    echo -e "\n${YELLOW}⚠️  An existing .env file was found.${NC}"
    read -p "Reuse existing values as defaults? (y/n) [y]: " reuse
    reuse=${reuse:-y}
    if [[ "$reuse" =~ ^[Yy]$ ]]; then
        set -a; source "$ENV_FILE"; set +a
        REUSE_ENV=true
        echo -e "${GREEN}✔ Existing values loaded as defaults.${NC}"
    fi
fi

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

read -p "Enter WireGuard Public Port [${WIREGUARD_PUBLIC_PORT:-51820}]: " USER_PORT
USER_PORT=${USER_PORT:-${WIREGUARD_PUBLIC_PORT:-51820}}

read -p "Enter WireGuard container IP [${IP_WIREGUARD:-172.20.0.40}]: " input
IP_WIREGUARD=${input:-${IP_WIREGUARD:-172.20.0.40}}

read -p "Enter Unbound container IP [${IP_UNBOUND:-172.20.0.20}]: " input
IP_UNBOUND=${input:-${IP_UNBOUND:-172.20.0.20}}

read -p "Enter Pi-hole server IP [${IP_PIHOLE:-172.20.0.30}]: " input
IP_PIHOLE=${input:-${IP_PIHOLE:-172.20.0.30}}

if [ "$REUSE_ENV" = true ] && [ -n "$WEBPASSWORD" ]; then
    read -p "Keep existing Pi-hole web password? (y/n) [y]: " keep_pw
    keep_pw=${keep_pw:-y}
    if [[ ! "$keep_pw" =~ ^[Yy]$ ]]; then
        WEBPASSWORD=$(openssl rand -base64 12)
        echo -e "New password: ${BOLD}${WEBPASSWORD}${NC}"
    else
        echo -e "Keeping existing password: ${BOLD}${WEBPASSWORD}${NC}"
    fi
else
    WEBPASSWORD=$(openssl rand -base64 12)
    echo -e "Your password is: ${BOLD}${WEBPASSWORD}${NC}"
fi

cat <<EOF > "$ENV_FILE"
WEBPASSWORD=$WEBPASSWORD
TIMEZONE=$DETECTED_TZ
IP_UNBOUND=$IP_UNBOUND
IP_PIHOLE=$IP_PIHOLE
IP_WIREGUARD=$IP_WIREGUARD
PUBLIC_IP=$PUBLIC_IP
WIREGUARD_PUBLIC_PORT=$USER_PORT
EOF

echo -e "${CYAN}✔ Variables written to .env${NC}"
chmod 600 "$ENV_FILE"

if docker compose ps --quiet 2>/dev/null | grep -q .; then
    echo -e "\n${YELLOW}⚠️  Running containers detected. Bringing stack down first...${NC}"
    docker compose down
    echo -e "${GREEN}✔ Stack stopped.${NC}"
fi

echo -e "\n${CYAN}${BOLD}Starting WireGuard stack...${NC}"
docker compose up -d

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}${BOLD}✅ Stack is up and running!${NC}"
    docker compose ps
else
    echo -e "\n${RED}${BOLD}❌ docker compose failed. Check logs with: docker compose logs${NC}"
    exit 1
fi


