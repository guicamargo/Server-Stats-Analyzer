FROM ubuntu:22.04

# Evitar prompts interativos durante instalação
ENV DEBIAN_FRONTEND=noninteractive

# Instalar somente as ferramentas necessárias
RUN apt-get update && apt-get install -y \
    procps \
    bc \
    net-tools \
    iproute2 \
    htop \
    stress-ng \
    vim \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Criar diretório de trabalho
WORKDIR /scripts

# Copiar o script
COPY server-stats.sh /scripts/server-stats.sh

# Dar permissão de execução
RUN chmod +x /scripts/server-stats.sh

# Criar alguns processos em background para simular carga
RUN echo '#!/bin/bash\n\
stress-ng --cpu 2 --timeout 300s --quiet &\n\
stress-ng --vm 1 --vm-bytes 50M --timeout 300s --quiet &\n\
sleep infinity' > /scripts/simulate-load.sh && \
    chmod +x /scripts/simulate-load.sh

# Comando padrão
CMD ["/bin/bash"]
