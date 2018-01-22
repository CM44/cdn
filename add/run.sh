#!/bin/bash

export SS_CONF="/usr/local/conf/ss_config.json"
export KCPTUN_SS_CONF="/usr/local/conf/kcptun_ss_config.json"
export XKCPTUN_SS_CONF="/usr/local/conf/xkcptun_ss_config.json"
export V2RAY_CONF="/usr/local/conf/v2ray_config.json"

export ALL_PWD=${ALL_PWD:-password}                                  #"pwd": "password",
# ======= SS CONFIG ======
export SS_SERVER_ADDR=${SS_SERVER_ADDR:-0.0.0.0}                     #"server": "0.0.0.0",
export SS_SERVER_PORT=${SS_SERVER_PORT:-8388}                        #"server_port": 8388,
export SS_PASSWORD=${SS_PASSWORD:-${ALL_PWD}}                        #"password":"${ALL_PWD}",
export SS_METHOD=${SS_METHOD:-aes-128-cfb}                           #"method":"aes-128-cfb",
export SS_TIMEOUT=${SS_TIMEOUT:-300}                                 #"timeout":300,
export SS_DNS_ADDR=${SS_DNS_ADDR:-8.8.8.8}                           #-d "8.8.8.8",
export SS_UDP=${SS_UDP:-true}                                        #-u support,
export SS_ONETIME_AUTH=${SS_ONETIME_AUTH:-false}                     #-A support false,
export SS_FAST_OPEN=${SS_FAST_OPEN:-true}                            #--fast-open support,
# ======= KCPTUN CONFIG ======
export KCPTUN_SS_LISTEN=${KCPTUN_SS_LISTEN:-29900}                   #"listen": ":29900"
export KCPTUN_KEY=${KCPTUN_KEY:-${ALL_PWD}}                          #"key": "${ALL_PWD}",
export KCPTUN_CRYPT=${KCPTUN_CRYPT:-none}                            #"crypt": "none",
export KCPTUN_MODE=${KCPTUN_MODE:-fast}                              #"mode": "fast",
# ======= XKCPTUN CONFIG ======
export XKCPTUN_SS_LISTEN=${XKCPTUN_SS_LISTEN:-29901}                 #"listen": ":29901"
export XKCPTUN_KEY=${XKCPTUN_KEY:-${ALL_PWD}}                        #"key": "${ALL_PWD}",
export XKCPTUN_CRYPT=${XKCPTUN_CRYPT:-none}                          #"crypt": "none",
export XKCPTUN_MODE=${XKCPTUN_MODE:-fast}                            #"mode": "fast",
# ======= V2RAY CONFIG ======
export V2RAY_SS_LISTEN=${V2RAY_SS_LISTEN:-29902}                    #"listen": ":29902"
export V2RAY_SS_METHOD=${V2RAY_SS_METHOD:-aes-128-cfb}              #"method":"aes-128-cfb",
export V2RAY_SS_PASSWORD=${V2RAY_SS_PASSWORD:-${ALL_PWD}}           #"password":"${ALL_PWD}",
export V2RAY_SS_UDP=${V2RAY_SS_UDP:-true}                           #udp support,
export V2RAY_VMESS_LISTEN=${V2RAY_VMESS_LISTEN:-29903}              #"listen": ":29903",
export V2RAY_VMESS_KCP_LISTEN=${V2RAY_VMESS_KCP_LISTEN:-29904}      #"listen": ":29904",
export V2RAY_VMESS_ID1=${V2RAY_VMESS_ID1:-1}
export V2RAY_VMESS_ID2=${V2RAY_VMESS_ID2:-2}


[ ! -f ${V2RAY_CONF} ] && cat > ${V2RAY_CONF}<<-EOF
{
    "log": {
        "access": "/var/log/v2ray/access.log",
        "error": "/var/log/v2ray/error.log",
        "loglevel": "error"
    },
    "inbound": {
        "protocol": "shadowsocks",
        "port": ${V2RAY_SS_LISTEN},
        "settings": {
            "method": "${V2RAY_SS_METHOD}",
            "password": "${V2RAY_SS_PASSWORD}",
            "udp": ${V2RAY_SS_UDP},
            "level": 1
        }
    },
    "outbound": {
        "protocol": "freedom",
        "settings": {}
    },
    "inboundDetour": [
        {
            "port": ${V2RAY_VMESS_LISTEN},
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "${V2RAY_VMESS_ID1}",
                        "level": 1,
                        "alterId": 64
                    },
                    {
                        "id": "${V2RAY_VMESS_ID2}",
                        "level": 1,
                        "alterId": 128
                    }
                ]
            }
        },
        {
            "port": ${V2RAY_VMESS_KCP_LISTEN},
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "${V2RAY_VMESS_ID1}",
                        "level": 1,
                        "alterId": 64
                    },
                    {
                        "id": "${V2RAY_VMESS_ID2}",
                        "level": 1,
                        "alterId": 128
                    }
                ]
            },
            "streamSettings": {
                "network": "kcp",
                "kcpSettings": {
                    "mtu": 1350,
                    "tti": 50,
                    "uplinkCapacity": 100,
                    "downlinkCapacity": 100,
                    "congestion": false,
                    "readBufferSize": 2,
                    "writeBufferSize": 2,
                    "header": {
                      "type": "wechat-video"
                    }
                  }
            }
        }
    ],
    "outboundDetour": [
        {
            "protocol": "blackhole",
            "settings": {},
            "tag": "blocked"
        }
    ],
    "routing": {
        "strategy": "rules",
        "settings": {
            "rules": [
                {
                    "type": "field",
                    "ip": [
                        "0.0.0.0/8",
                        "10.0.0.0/8",
                        "100.64.0.0/10",
                        "127.0.0.0/8",
                        "169.254.0.0/16",
                        "172.16.0.0/12",
                        "192.0.0.0/24",
                        "192.0.2.0/24",
                        "192.168.0.0/16",
                        "198.18.0.0/15",
                        "198.51.100.0/24",
                        "203.0.113.0/24",
                        "::1/128",
                        "fc00::/7",
                        "fe80::/10"
                    ],
                    "outboundTag": "blocked"
                }
            ]
        }
    }
}
EOF

if [ ! -f "/usr/bin/v2ray/v2ray" ]; then
    mkdir /var/log/v2ray/
    mkdir /usr/bin/v2ray/
    cd /usr/bin/v2ray/
    wget https://storage.googleapis.com/v2ray-docker/v2ray
    wget https://storage.googleapis.com/v2ray-docker/v2ctl
    wget https://storage.googleapis.com/v2ray-docker/geoip.dat
    wget https://storage.googleapis.com/v2ray-docker/geosite.dat
    chmod +x ./v2ctl
    chmod +x ./v2ray
    cd /
fi


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
    "mode": "${KCPTUN_MODE}",
    "mtu": 1350,
    "sndwnd": 2048,
    "rcvwnd": 2048,
    "nocomp": true
}
EOF


export MY_ETH=`ifconfig | grep Ethernet | awk '{print $1}'`
[ ! -f ${XKCPTUN_SS_CONF} ] && cat > ${XKCPTUN_SS_CONF}<<-EOF
{
  "localinterface": "${MY_ETH}",
  "localport": ${XKCPTUN_SS_LISTEN},
  "remoteaddr": "127.0.0.1",
  "remoteport": ${SS_SERVER_PORT},
  "key": "${XKCPTUN_KEY}",
  "crypt": "${XKCPTUN_CRYPT}",
  "mode": "${XKCPTUN_MODE}",
  "mtu": 1350,
  "sndwnd": 2048,
  "rcvwnd": 2048,
  "nodelay": 0
}
EOF


if [ "${AUTHORIZED_KEYS}x" != "x" ]; then
    echo ${AUTHORIZED_KEYS} > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi

echo "Starting v2ray..."
nohup /usr/bin/v2ray/v2ray -config=${V2RAY_CONF} >/dev/null 2>&1 &

echo "Starting ss..."
nohup ss-server -c ${SS_CONF} -d "${SS_DNS_ADDR}" ${SS_UDP_FLAG}${SS_ONETIME_AUTH_FLAG}${SS_FAST_OPEN_FLAG} >/dev/null 2>&1 &

echo "Starting Kcp..."
nohup kcp-server -c ${KCPTUN_SS_CONF} >/dev/null 2>&1 &

echo "Starting xKcp..."
exec xkcp_server -c ${XKCPTUN_SS_CONF} -d 0
