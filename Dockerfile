# Base com Python 3.12
FROM python:3.12-slim-bookworm

# Instalar Java 17 (Obrigatório para o Spark) e utilitários
RUN apt-get update && \
    apt-get install -y openjdk-17-jre-headless procps ssh iproute2 curl && \
    rm -rf /var/lib/apt/lists/*

# Definir variáveis de ambiente do Spark
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV SPARK_HOME=/usr/local/lib/python3.12/site-packages/pyspark

# Copiar dependências e instalar
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install jupyterlab

# Copiar o resto do projeto
COPY . .

# Expor a porta do Jupyter
EXPOSE 8888

# Comando de inicialização
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]
