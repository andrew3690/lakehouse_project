#!/bin/bash

MODE=$1

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

function log() {
    echo -e "${GREEN}[AndrewPC Manager]${NC} $1"
}

case "$MODE" in
    "dev")
        echo -e "${YELLOW}>>>ATIVANDO MODO DESENVOLVEDOR (DATA & SOFTWARE)${NC}"
        
        # 1. VS Code (Para desenvolvimento geral)
        log "Iniciando VS Code Web (Porta 8443)..."
        sudo systemctl start code-server@$USER
        
        # 2. Jupyter Lakehouse (Databricks Clone - Porta 8888)
        # Este serviço já carrega: Spark, Delta Lake, MinIO Configs e Python 3.12
        log "Iniciando Jupyter com Spark Cluster Configs (Porta 8888)..."
        sudo systemctl start jupyter-lakehouse
        
        # 3. CloudBeaver (Visualizador de Banco - Porta 8978)
        log "Iniciando Catalog Explorer (Docker)..."
        docker start catalog_explorer
        
        # 4. Cluster Físico (Workers Android)
        log "Convocando Workers Android via Ansible..."
        cd ~/ansible-cluster && ansible-playbook -i inventory manage_modes_termux.yml -e "mode=developer"
        
        echo -e "${BLUE}===============================================${NC}"
        echo -e "${BLUE}   AMBIENTE DE DESENVOLVIMENTO ATIVO           ${NC}"
        echo -e "${BLUE}===============================================${NC}"
        echo -e "VS Code:       http://192.168.15.9:8443"
        echo -e "Jupyter Lab:   http://192.168.15.9:8888"
        echo -e "Catalog (DB):  http://192.168.15.9:8978"
        echo -e "Spark Master:  http://192.168.15.9:8080"
        echo -e "${BLUE}===============================================${NC}"
        ;;

    "media" | "server")
        echo -e "${YELLOW}>>> ATIVANDO MODO SERVIDOR / MEDIA (ECONOMIA)${NC}"
        
        log "Parando VS Code..."
        sudo systemctl stop code-server@$USER
        
        log "Parando Jupyter Lab..."
        sudo systemctl stop jupyter-lakehouse
        
        log "Pausando Catalog Explorer..."
        docker stop catalog_explorer
        
        log "Liberando Workers Android (Kill Spark)..."
        cd ~/ansible-cluster && ansible-playbook -i inventory manage_modes_termux.yml -e "mode=none"
        
        log "MODO MEDIA ATIVO! Apenas serviços essenciais (MinIO/Postgres) rodando."
        ;;
        
    *)
        echo "Uso: mode-dev | mode-media"
        exit 1
        ;;
esac
