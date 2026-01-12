#!/bin/bash

MODE=$1

# --- CONFIGURAÇÕES DE CAMINHOS (O segredo da automação) ---
PROJECT_ROOT="$HOME/lakehouse_project"
K8S_FILES="$PROJECT_ROOT/kubernets_files"
ANSIBLE_DIR="$PROJECT_ROOT/infrastructure/android-cluster"
VENV_ACTIVATE="$PROJECT_ROOT/venv_312/bin/activate"

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
        echo -e "${YELLOW}>>> ATIVANDO MODO DESENVOLVEDOR (LAKEHOUSE HÍBRIDO)${NC}"

        # 1. VS Code (Mantemos o nativo pois é leve)
        log "Iniciando VS Code Web (Porta 8443)..."
        if systemctl is-active --quiet code-server@$USER; then
            echo "VS Code já está rodando."
        else
            sudo systemctl start code-server@$USER
        fi

        # 2. Infraestrutura Kubernetes (Master + Jupyter + DBs)
        log "Subindo Cluster Kubernetes (Spark Master, Jupyter, MinIO, Postgres)..."
        # Garante que as configs e secrets entrem primeiro
        kubectl apply -f "$K8S_FILES/lakehouse-secrets.yaml"
        kubectl apply -f "$K8S_FILES/spark-config.yaml"
        # Aplica todo o resto
        kubectl apply -f "$K8S_FILES/"
        
        log "Aguardando estabilização do Master (10s)..."
        sleep 10

        # 3. Cluster Físico (Workers Android)
        log "Convocando Workers Android via Ansible (Venv)..."
        
        if [ -f "$VENV_ACTIVATE" ]; then
            source "$VENV_ACTIVATE"
            # Ignora verificação de chave SSH para ser mais rápido e não travar
            cd "$ANSIBLE_DIR"
            ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory start_workers.yml
        else
            echo -e "${RED}ERRO: Venv não encontrado em $VENV_ACTIVATE${NC}"
        fi

        echo -e "${BLUE}===============================================${NC}"
        echo -e "${BLUE}   AMBIENTE LAKEHOUSE HÍBRIDO ATIVO            ${NC}"
        echo -e "${BLUE}===============================================${NC}"
        echo -e "VS Code:       http://192.168.15.9:8443"
        echo -e "Jupyter Lab:   http://192.168.15.9:8888  (Token: vazio)"
        echo -e "Spark Master:  http://192.168.15.9:31939 (Check Workers!)"
        echo -e "MinIO Console: http://192.168.15.9:32406 (Login: admin)"
        echo -e "${BLUE}===============================================${NC}"
        ;;

    "media" | "server")
        echo -e "${YELLOW}>>> ATIVANDO MODO SERVIDOR / MEDIA (ECONOMIA)${NC}"

        # 1. Parar VS Code
        log "Parando VS Code..."
        sudo systemctl stop code-server@$USER

        # 2. Parar Workers Android (Liberar RAM dos Celulares)
        log "Desligando Workers nos Celulares (Pkill Java)..."
        if [ -f "$VENV_ACTIVATE" ]; then
            source "$VENV_ACTIVATE"
            cd "$ANSIBLE_DIR"
            # Manda comando para matar o Spark sem precisar de playbook complexo
            ansible -i inventory cluster_nodes -m shell -a "pkill -f 'org.apache.spark.deploy.worker.Worker' || true"
        else
            log "${RED}Falha ao desligar celulares: Venv offline.${NC}"
        fi

        # 3. Parar Computação Pesada no PC (Kubernetes)
        log "Derrubando Jupyter e Spark Master..."
        kubectl delete -f "$K8S_FILES/jupyter-lakehouse.yaml" --ignore-not-found
        kubectl delete -f "$K8S_FILES/spark-master.yaml" --ignore-not-found
        
        # Opcional: Derrubar Worker Local se existir
        kubectl delete -f "$K8S_FILES/spark-worker.yaml" --ignore-not-found

        log "MODO MEDIA ATIVO! Apenas Banco de Dados e Storage (MinIO/Postgres) mantidos."
        ;;

    *)
        echo "Uso: $0 {dev|media}"
        exit 1
        ;;
esac
