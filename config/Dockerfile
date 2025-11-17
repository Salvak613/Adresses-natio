FROM postgres:15

# Installer curl pour télécharger les fichiers CSV
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copier le script shell et urls.txt dans l'image
COPY config/download-all.sh /usr/local/bin/download-all.sh
COPY config/urls.txt /usr/local/bin/urls.txt

# Convertir les fins de ligne CRLF en LF (Windows -> Linux)
RUN sed -i 's/\r$//' /usr/local/bin/download-all.sh && \
    sed -i 's/\r$//' /usr/local/bin/urls.txt && \
    chmod +x /usr/local/bin/download-all.sh
