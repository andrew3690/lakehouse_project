#!/bin/bash

# 1. Definir caminhos básicos do projeto
export USER_HOME="$HOME"
export PROJECT_DIR="$USER_HOME/lakehouse_project"
export SPARK_HOME="$USER_HOME/spark"

# 2. CARREGAR SEGREDOS (O Segredo da Segurança)
# Se existir o arquivo .env, carrega as variáveis para a memória
if [ -f "$PROJECT_DIR/.env" ]; then
    set -a # Ativa exportação automática
    source "$PROJECT_DIR/.env"
    set +a
else
    echo "ERRO: Arquivo .env não encontrado! Crie um baseando-se no .env.example"
    exit 1
fi

# 3. Validar se as variáveis críticas existem
if [ -z "$SPARK_MASTER_HOST" ]; then
    echo "ERRO: Variáveis de ambiente não carregadas. Verifique seu .env"
    exit 1
fi

# 4. Configurar PySpark com as variáveis do .env
export PYSPARK_DRIVER_PYTHON="$DRIVER_JUPYTER_PATH"
export PYSPARK_PYTHON="$WORKER_PYTHON_PATH"

export PYSPARK_DRIVER_PYTHON_OPTS="lab --ip=0.0.0.0 --port=8888 --no-browser --notebook-dir=$PROJECT_DIR"

echo ">>> Iniciando Lakehouse ..."
echo ">>> Master: spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT"

# 5. Iniciar Spark (Usando variáveis, sem hardcode!)
$SPARK_HOME/bin/pyspark \
--master "spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT" \
--conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" \
--conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog" \
--conf "spark.executor.memory=512m" \
--conf "spark.executor.cores=2"
