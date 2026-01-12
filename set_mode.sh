#!/bin/bash

MODE=$1

# Função para escalar deployments
scale_app() {
    APP=$1
    REPLICAS=$2
    echo "Ajustando $APP para $REPLICAS réplicas..."
    kubectl scale deployment $APP --replicas=$REPLICAS > /dev/null 2>&1
}

if [ "$MODE" == "dev" ]; then
    echo "🔵 ATIVANDO MODO DESENVOLVIMENTO (Data Engineering)"
    echo "---------------------------------------------------"
    # Ligar Ferramentas de Dev
    scale_app spark-master 1
    scale_app spark-worker-local 1
    scale_app jupyter-lakehouse 1
    scale_app vscode-server 1
    scale_app cloudbeaver 1
    
    # Manter Banco de Dados (Crawler Support)
    scale_app metastore-db 1
    
    # Desligar Entretenimento (Economia de RAM)
    scale_app minecraft 0
    scale_app zomboid 0
    scale_app terraria 0
    scale_app jellyfin 0
    # Opcional: Desligar torrent se precisar de muita banda/cpu para Spark
    scale_app qbittorrent 0 

elif [ "$MODE" == "media" ]; then
    echo "🟢 ATIVANDO MODO MEDIA & GAMES"
    echo "---------------------------------------------------"
    # Ligar Entretenimento
    scale_app minecraft 1
    scale_app jellyfin 1
    scale_app qbittorrent 1
    # scale_app zomboid 1  # Descomente se for jogar
    # scale_app terraria 1 # Descomente se for jogar
    
    # Desligar Dev Pesado (Libera CPU/RAM)
    scale_app spark-master 0
    scale_app spark-worker-local 0
    scale_app jupyter-lakehouse 0
    scale_app vscode-server 0
    scale_app cloudbeaver 0
    
    # Manter Banco de Dados (Você pediu para manter em pé)
    scale_app metastore-db 1

elif [ "$MODE" == "all" ]; then
    echo "🔥 ATIVANDO TUDO (Cuidado com a RAM!)"
    scale_app spark-master 1
    scale_app spark-worker-local 1
    scale_app jupyter-lakehouse 1
    scale_app minecraft 1
    scale_app jellyfin 1
    scale_app metastore-db 1
    scale_app vscode-server 1
    
else
    echo "Uso: ./set_mode.sh [dev | media | all]"
fi

echo "✅ Modo $MODE aplicado com sucesso!"
echo "Use 'kubectl get pods' para verificar o status."
