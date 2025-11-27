# Server Stats Analyzer

Script para análise de performance de servidores Linux desenvolvido do zero como projeto de aprendizado.

## 📋 Funcionalidades

### Requisitos Básicos ✅
- ✅ **Total CPU usage** - Uso total de CPU e idle
- ✅ **Total memory usage** - Total, usado, livre e disponível com percentual
- ✅ **Total disk usage** - Total, usado e livre com percentual  
- ✅ **Top 5 processos por CPU** - PID, CPU%, MEM% e comando
- ✅ **Top 5 processos por memória** - PID, CPU%, MEM% e comando

### Funcionalidades Extras ⭐
- ✅ Versão do Sistema Operacional
- ✅ Uptime do sistema
- ✅ Load average (1m, 5m, 15m)
- ✅ Número de cores de CPU
- ✅ Usuários logados
- ✅ Estatísticas de rede (conexões estabelecidas e portas listening)
- ✅ Todos os filesystems montados
- ✅ Compatibilidade com sistemas em português

## 🚀 Como Usar

### Opção 1: Executar Diretamente no Linux

```bash
# 1. Dar permissão de execução
chmod +x server-stats.sh

# 2. Executar
./server-stats.sh
```

### Opção 2: Testar com Docker (Recomendado para Testes)

```bash
# 1. Build da imagem
docker-compose build

# 2. Executar o container
docker-compose run --rm test-server

# 3. Dentro do container, executar o script
./server-stats.sh
```

## 🧪 Testando com Stress

### Teste de CPU
```bash
stress-ng --cpu 2 --timeout 30s &
sleep 3
./server-stats.sh
```

### Teste de Memória
```bash
stress-ng --vm 1 --vm-bytes 200M --timeout 30s &
sleep 3
./server-stats.sh
```

### Teste Combinado
```bash
stress-ng --cpu 2 --vm 1 --vm-bytes 200M --timeout 30s &
sleep 3
./server-stats.sh
```

## 📊 Exemplo de Saída

```
╔═══════════════════════════════════════╗
║   SERVER PERFORMANCE STATS ANALYZER   ║
╔═══════════════════════════════════════╝

Analysis Date: 2025-11-26 20:39:33
Hostname: gui-Dell-G15-5530

========================================
SYSTEM INFORMATION
========================================
Operating System: Ubuntu 24.04.3 LTS
System Uptime:  2:09
Load Average (1m, 5m, 15m): 0.96, 1.01, 0.94
CPU Core's: 16
Logged in Users: 2

========================================
CPU USAGE
========================================
Total CPU Usage: 1.7%
CPU Idle: 98.3%
CPU Cores: 16

========================================
MEMORY USAGE (RAM)
========================================
Total Memory: 15Gi
Used Memory: 4.3Gi (28.0%)
Free Memory: 4.0Gi
Available Memory: 11Gi

========================================
DISK USAGE
========================================
Total Disk Space: 476G
Used Disk Space: 47G (10%)
Free Disk Space: 426G
```

## 🔧 Dependências

- `top` - monitoramento de CPU
- `free` - informações de memória
- `df` - uso de disco
- `ps` - lista de processos
- `uptime` - uptime e load average
- `who` - usuários logados
- `ss` ou `netstat` - estatísticas de rede
- `awk`, `grep`, `sed`, `cut` - processamento de texto

## 💡 Comandos Úteis

### Monitoramento Contínuo
```bash
watch -n 5 ./server-stats.sh
```

### Salvar Relatório
```bash
./server-stats.sh > report-$(date +%Y%m%d-%H%M%S).txt
```

### Comparar Antes/Depois
```bash
./server-stats.sh > before.txt
# Fazer mudanças...
./server-stats.sh > after.txt
diff before.txt after.txt
```

## 📚 O Que Você Aprende

- ✅ Comandos de monitoramento Linux
- ✅ Bash scripting
- ✅ Processamento de texto com awk, grep, sed
- ✅ Análise de performance de sistemas
- ✅ Docker para testes
- ✅ DevOps práticas

## 👤 Autor

Desenvolvido por **[guicamargo](https://github.com/guicamargo)**
Projeto de aprendizado DevOps/SRE - Novembro 2025