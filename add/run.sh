#!/bin/bash
export KCPTUN_SS_CONF="/usr/local/conf/kcptun_ss_config.json"
export SS_CONF="/usr/local/conf/ss_config.json"
# ======= SS CONFIG ======
export SS_SERVER_ADDR=${SS_SERVER_ADDR:-0.0.0.0}                     #"server": "0.0.0.0",
export SS_SERVER_PORT=${SS_SERVER_PORT:-8388}                        #"server_port": 8388,
export SS_PASSWORD=${SS_PASSWORD:-iampassword}                       #"password":"iampassword",
export SS_METHOD=${SS_METHOD:-aes-128-cfb}                           #"method":"aes-128-cfb",
export SS_TIMEOUT=${SS_TIMEOUT:-300}                                 #"timeout":300,
export SS_DNS_ADDR=${SS_DNS_ADDR:-8.8.8.8}                           #-d "8.8.8.8",
export SS_UDP=${SS_UDP:-true}                                        #-u support,
export SS_ONETIME_AUTH=${SS_ONETIME_AUTH:-false}                     #-A support false,
export SS_FAST_OPEN=${SS_FAST_OPEN:-true}                            #--fast-open support,
# ======= KCPTUN CONFIG ======
export KCPTUN_SS_LISTEN=${KCPTUN_SS_LISTEN:-29900}                   #"listen": ":29900"
export KCPTUN_KEY=${KCPTUN_KEY:-iampassword}                         #"key": "iampassword",
export KCPTUN_CRYPT=${KCPTUN_CRYPT:-aes}                             #"crypt": "aes",
export KCPTUN_MODE=${KCPTUN_MODE:-fast2}                             #"mode": "fast2",


[ ! -f ${SS_CONF} ] && cat > ${SS_CONF}<<-EOF
{
    "server":"${SS_SERVER_ADDR}",
    "server_port":${SS_SERVER_PORT},
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"${SS_PASSWORD}",
    "timeout":${SS_TIMEOUT},
    "method":"${SS_METHOD}"
}
EOF
if [[ "${SS_UDP}" = "true" ]]; then
    export SS_UDP_FLAG="-u "
else
    export SS_UDP_FLAG=""
fi
if [[ "${SS_ONETIME_AUTH}" = "true" ]]; then
    export SS_ONETIME_AUTH_FLAG="-A "
else
    export SS_ONETIME_AUTH_FLAG=""
fi
if [[ "${SS_FAST_OPEN}" = "true" ]]; then
    export SS_FAST_OPEN_FLAG="--fast-open"
else
    export SS_FAST_OPEN_FLAG=""
fi


[ ! -f ${KCPTUN_SS_CONF} ] && cat > ${KCPTUN_SS_CONF}<<-EOF
{
    "listen": ":${KCPTUN_SS_LISTEN}",
    "target": "127.0.0.1:${SS_SERVER_PORT}",
    "key": "${KCPTUN_KEY}",
    "crypt": "${KCPTUN_CRYPT}",
    "mode": "${KCPTUN_MODE}"
}
EOF


echo "Starting Shadowsocks-libev..."
nohup ss-server -c ${SS_CONF} -d "${SS_DNS_ADDR}" ${SS_UDP_FLAG}${SS_ONETIME_AUTH_FLAG}${SS_FAST_OPEN_FLAG} >/dev/null 2>&1 &
#exec ss-server -c ${SS_CONF} -d "${SS_DNS_ADDR}" ${SS_UDP_FLAG}${SS_ONETIME_AUTH_FLAG}${SS_FAST_OPEN_FLAG}

echo "Starting Kcptun for Shadowsocks-libev..."
nohup kcp-server -c ${KCPTUN_SS_CONF} >/dev/null 2>&1 &
#exec kcp-server -c ${KCPTUN_SS_CONF}

