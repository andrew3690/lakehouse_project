# Baseado na imagem que já funciona no seu ambiente
FROM anddevs/spark-master:3.5.0

USER root

# --- 1. Definir o Mapa do Tesouro (Variáveis de Ambiente) ---
# Aqui corrigimos aquele problema do "path não encontrado" para sempre
ENV SPARK_HOME="/usr/local/lib/python3.12/site-packages/pyspark"
ENV PATH="${SPARK_HOME}/bin:${PATH}"

# --- 2. Instalar Ferramentas Básicas ---
RUN apt-get update && apt-get install -y curl wget && rm -rf /var/lib/apt/lists/*

# --- 3. Baixar os Drivers (Postgres + AWS S3) ---
# Baixamos direto na pasta de Jars do Spark
WORKDIR ${SPARK_HOME}/jars

# Postgres
RUN curl -O https://repo1.maven.org/maven2/org/postgresql/postgresql/42.6.0/postgresql-42.6.0.jar

# AWS S3 / Hadoop
RUN curl -O https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar \
    && curl -O https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar

# --- 4. Finalização ---
WORKDIR /root
# O entrypoint original da imagem é mantido
