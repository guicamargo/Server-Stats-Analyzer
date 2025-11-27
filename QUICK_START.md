# 🚀 Guia Rápido - Server Stats Analyzer

## Início Rápido (3 passos)

### 1️⃣ Preparar o Script

```bash
# Criar diretório
mkdir ~/server-stats-project
cd ~/server-stats-project

# Copiar o script que você criou
# server-stats.sh
```

### 2️⃣ Executar Localmente

```bash
# Tornar executável
chmod +x server-stats.sh

# Executar
./server-stats.sh
```

### 3️⃣ Testar com Docker (Opcional)

```bash
# Build
docker compose build

# Executar
docker compose run --rm test-server ./server-stats.sh

# OU para rodar os testes abaixo no docker 
docker compose run --rm test-server bash
```

---

## 🧪 Cenários de Teste

### Teste 1: Análise Normal
```bash
./server-stats.sh
```

### Teste 2: Com Stress de CPU
```bash
# Iniciar stress (2 threads por 30 segundos)
stress-ng --cpu 2 --timeout 30s &

# Aguardar 3 segundos
sleep 3

# Executar análise
./server-stats.sh
```

**Resultado esperado:**
- CPU Usage vai aumentar significativamente
- Processos `stress-ng` aparecerão no Top 5 CPU

### Teste 3: Com Stress de Memória
```bash
# Iniciar stress (200MB por 30 segundos)
stress-ng --vm 1 --vm-bytes 200M --timeout 30s &

# Aguardar 3 segundos
sleep 3

# Executar análise
./server-stats.sh
```

**Resultado esperado:**
- Used Memory aumenta ~200MB
- Processo `stress-ng` aparece no Top 5 Memory

### Teste 4: Stress Combinado
```bash
# CPU + Memória
stress-ng --cpu 2 --vm 1 --vm-bytes 200M --timeout 30s &
sleep 3
./server-stats.sh
```

### Teste 5: Múltiplos Processos
```bash
# Criar 20 processos em background
for i in {1..20}; do
    sleep 1000 &
done

# Executar análise
./server-stats.sh

# Você verá os 20 processos sleep nas listagens
```

---

## 📊 Comandos Úteis

### Monitoramento Contínuo
```bash
# Atualizar a cada 5 segundos
watch -n 5 ./server-stats.sh

# Atualizar a cada 10 segundos
watch -n 10 ./server-stats.sh
```

### Salvar Relatório com Timestamp
```bash
./server-stats.sh > report-$(date +%Y%m%d-%H%M%S).txt
```

### Comparar Antes/Depois
```bash
# Capturar estado inicial
./server-stats.sh > before.txt

# Fazer mudanças no sistema...

# Capturar estado final
./server-stats.sh > after.txt

# Comparar
diff before.txt after.txt
```

### Executar com Privilégios
```bash
sudo ./server-stats.sh
```

### Filtrar Seções Específicas
```bash
# Apenas CPU
./server-stats.sh | grep -A 3 "CPU USAGE"

# Apenas Memória
./server-stats.sh | grep -A 4 "MEMORY USAGE"

# Apenas Top Processes
./server-stats.sh | grep -A 6 "TOP 5 PROCESSES"
```

---

## 🐳 Usando com Docker

### Build e Run
```bash
# Build da imagem
docker-compose build

# Executar análise
docker-compose run --rm test-server ./server-stats.sh
```

### Shell Interativo
```bash
# Entrar no container
docker-compose run --rm test-server bash

# Dentro do container, você pode:
./server-stats.sh                              # Executar análise
stress-ng --cpu 2 --timeout 30s &             # Aplicar stress
ps aux                                         # Ver processos
top                                            # Monitor interativo
exit                                           # Sair
```

### Testar Cenários no Docker
```bash
docker-compose run --rm test-server bash
# Agora dentro do container:

# Teste 1: Normal
./server-stats.sh

# Teste 2: Com stress
stress-ng --cpu 4 --timeout 20s &
sleep 3
./server-stats.sh

# Teste 3: Memória
stress-ng --vm 2 --vm-bytes 100M --timeout 20s &
sleep 3
./server-stats.sh
```

---

## 🔍 Interpretando Resultados

### CPU Usage
- **< 30%**: Saudável, sistema ocioso
- **30-70%**: Normal sob carga de trabalho
- **70-90%**: Alta utilização, monitorar
- **> 90%**: Crítico, investigar processos

### Memory Usage
- **< 60%**: Saudável
- **60-80%**: Normal
- **80-90%**: Alta, considerar upgrade
- **> 90%**: Crítico, risco de OOM (Out of Memory)

### Disk Usage
- **< 70%**: Saudável
- **70-85%**: Começar limpeza
- **85-95%**: Urgente, limpar agora
- **> 95%**: Crítico, sistema pode travar

### Load Average
- **< Número de CPUs**: Saudável
- **= Número de CPUs**: Sistema saturado
- **> Número de CPUs**: Sobrecarregado

**Exemplo:** Se você tem 16 cores:
- Load de 8.0 = 50% de uso (OK)
- Load de 16.0 = 100% de uso (saturado)
- Load de 32.0 = 200% de uso (sobrecarregado!)

---

## 🐛 Solução de Problemas

### Erro: "Permission denied"
```bash
chmod +x server-stats.sh
```

### Erro: "Command not found" (top, free, df, etc)
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y procps coreutils

# Fedora/RHEL
sudo dnf install -y procps-ng coreutils
```

### Erro: stress-ng não instalado
```bash
# Ubuntu/Debian
sudo apt-get install -y stress-ng

# Fedora/RHEL
sudo dnf install -y stress-ng
```

### Docker não inicia
```bash
# Verificar status
sudo systemctl status docker

# Iniciar Docker
sudo systemctl start docker

# Rebuild
docker-compose build --no-cache
```

### Script não funciona em sistemas não-portugueses
O script foi adaptado para sistemas em português. Para inglês, ajuste:

```bash
# Linha 44: Trocar "%CPU(s)" por "Cpu(s)"
CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | sed 's/id//' | tr ',' '.')

# Linhas 59-62: Trocar "Mem.:" por "Mem:"
TOTAL_MEM=$(free -h | awk '/^Mem:/ {print $2}')
```

---

## 💡 Dicas

### 1. Criar Alias
```bash
# Adicionar ao ~/.bashrc
alias serverstats='/caminho/para/server-stats.sh'

# Recarregar
source ~/.bashrc

# Usar
serverstats
```

### 2. Histórico de Métricas
```bash
# Coletar a cada hora
while true; do
    echo "=== $(date) ===" >> stats-history.log
    ./server-stats.sh >> stats-history.log
    echo "" >> stats-history.log
    sleep 3600
done
```

---

## 📚 Comandos de Stress Explicados

### `stress-ng --cpu 2 --timeout 30s &`
- `--cpu 2`: Usar 2 threads de CPU
- `--timeout 30s`: Por 30 segundos
- `&`: Executar em background

### `stress-ng --vm 1 --vm-bytes 200M --timeout 30s &`
- `--vm 1`: 1 worker de memória
- `--vm-bytes 200M`: Alocar 200MB
- `--timeout 30s`: Por 30 segundos
- `&`: Executar em background

### Combinações Úteis
```bash
# Leve (não afeta muito)
stress-ng --cpu 1 --timeout 30s &

# Médio (visível no script)
stress-ng --cpu 2 --vm 1 --vm-bytes 500M --timeout 30s &

# Pesado (bem visível)
stress-ng --cpu 4 --vm 2 --vm-bytes 1G --timeout 30s &
```

---

## 🎯 Casos de Uso

### 1. Debug de Aplicação Lenta
```bash
./server-stats.sh
# Identificar processo com alto CPU/memória no Top 5
# Investigar o PID específico
```

### 2. Teste Antes de Deploy
```bash
./server-stats.sh > pre-deploy.txt
# Fazer deploy
./server-stats.sh > post-deploy.txt
diff pre-deploy.txt post-deploy.txt
```

### 3. Monitoramento de Produção
```bash
watch -n 10 './server-stats.sh | grep -E "CPU|Memory|Disk"'
```

### 4. Documentação de Incidentes
```bash
mkdir incident-$(date +%Y%m%d)
./server-stats.sh > incident-$(date +%Y%m%d)/analysis.txt
```



---

**Desenvolvido por [guicamargo](https://github.com/guicamargo) - Projeto de Aprendizado DevOps/SRE**
