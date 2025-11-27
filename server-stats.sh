#!/bin/bash
clear
echo "╔═══════════════════════════════════════╗"
echo "║   SERVER PERFORMANCE STATS ANALYZER   ║"
echo "╔═══════════════════════════════════════╝"
echo ""
echo "Analysis Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Hostname: $(hostname)"

echo ""
echo "========================================"
echo "SYSTEM INFORMATION"
echo "========================================"

# OS Version
OS_NAME=$(grep "PRETTY_NAME" /etc/os-release | cut -d'"' -f2)
echo "Operating System: $OS_NAME"

# System Uptime
UPTIME=$(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')
echo "System Uptime: $UPTIME"

# Load Average
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | xargs)
echo "Load Average (1m, 5m, 15m): $LOAD_AVG"

# CPU Cores
CPU_CORES=$(nproc)
echo "CPU Core's: $CPU_CORES"

# Logged Users
LOGGED_USERS=$(who | wc -l)
echo "Logged in Users: $LOGGED_USERS"

echo ""
echo "========================================"
echo "CPU USAGE"
echo "========================================"

# Pegar CPU idle (ajustado para português)
CPU_IDLE=$(top -bn1 | grep "%CPU(s)" | awk '{print $8}' | sed 's/ id//' | tr ',' '.')

# Calcular CPU usado (100 - idle)
CPU_USED=$(awk "BEGIN {printf \"%.1f\", 100 - $CPU_IDLE}" | tr ',' '.')

echo "Total CPU Usage: ${CPU_USED}%"
echo "CPU Idle: ${CPU_IDLE}%"
echo "CPU Cores: $CPU_CORES"

echo ""
echo "========================================"
echo "MEMORY USAGE (RAM)"
echo "========================================"

# Pegar valores em formato humano (Gi, Mi, etc)
TOTAL_MEM=$(free -h | awk '/^Mem.:/ {print $2}')
USED_MEM=$(free -h | awk '/^Mem.:/ {print $3}')
FREE_MEM=$(free -h | awk '/^Mem.:/ {print $4}')
AVAILABLE_MEM=$(free -h | awk '/^Mem.:/ {print $7}')

# Calcular percentual de uso (sem -h para fazer calculo)
MEM_PERCENT=$(free | awk '/^Mem.:/ {printf "%.1f", ($3/$2) * 100}' | tr ',' '.')

# Mostrar informacoes
echo "Total Memory: $TOTAL_MEM"
echo "Used Memory: $USED_MEM (${MEM_PERCENT}%)"
echo "Free Memory: $FREE_MEM"
echo "Available Memory: $AVAILABLE_MEM"

echo ""
echo "========================================"
echo "DISK USAGE"
echo "========================================"

# Pegar informacoes da particao raiz (/)
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_FREE=$(df -h / | awk 'NR==2 {print $4}')
DISK_PERCENT=$(df -h / | awk 'NR==2 {print $5}')

echo "Total Disk Space: $DISK_TOTAL"
echo "Used Disk Space: $DISK_USED ($DISK_PERCENT)"
echo "Free Disk Space: $DISK_FREE"

# Mostrar todos os filesystems montados (opcional)
echo ""
echo "All Mounted Filesystems:"
df -h --output=source,size,used,avail,pcent,target | grep -v "tmpfs\|devtmpfs\|loop"

echo ""
echo "========================================"
echo "TOP 5 PROCESSES BY CPU USAGE"
echo "========================================"

echo -e "PID\t\tCPU%\tMEM%\tCOMMAND"
ps aux --sort=-%cpu | awk 'NR>1 {printf "%-10s\t%.1f%%\t%.1f%%\t%s\n", $2, $3, $4, $11}' | tr ',' '.' | head -5
echo ""
echo "========================================"
echo "TOP 5 PROCESSES BY MEMORY USAGE"
echo "========================================"

echo -e "PID\t\tCPU%\tMEM%\tCOMMAND"
ps aux --sort=-%mem | awk 'NR>1 {printf "%-10s\t%.1f%%\t%.1f%%\t%s\n", $2, $3, $4, $11}' | tr ',' '.' | head -5

echo ""
echo "========================================"
echo "NETWORK STATISTICS"
echo "========================================"

# Conexoes estabelecidas
ESTABLISHED_CONN=$(ss -tan 2>/dev/null | grep ESTAB | wc -l || netstat -an 2>/dev/null | grep ESTABLISHED | wc -l)
echo "Established Connections: $ESTABLISHED_CONN"

# Portas em listening
LISTENING_PORTS=$(ss -tuln 2>/dev/null | grep LISTEN | wc -l || netstat -tuln 2>/dev/null | grep LISTEN | wc -l)
echo "Listening Ports: $LISTENING_PORTS"

echo ""
echo "========================================"
echo "Analysis completed successfully!"
echo "========================================"
echo ""