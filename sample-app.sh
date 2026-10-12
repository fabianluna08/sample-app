#!/bin/bash
# sample-app.sh: empaqueta la app Flask en una imagen Docker y ejecuta el contenedor
set -e
PUERTO=5050

# 1. Limpiar ejecuciones anteriores
docker rm -f samplerunning 2>/dev/null || true
rm -rf tempdir

# 2. Copiar la app y los archivos del sitio a un directorio de trabajo
mkdir -p tempdir/templates tempdir/static
cp sample_app.py tempdir/.
cp -r templates/* tempdir/templates/.
cp -r static/* tempdir/static/.

# 3. Generar el Dockerfile
cat > tempdir/Dockerfile <<DOCKERFILE
FROM python:3.12-slim
RUN pip install --no-cache-dir flask
RUN useradd --create-home appuser
COPY ./static /home/myapp/static/
COPY ./templates /home/myapp/templates/
COPY sample_app.py /home/myapp/
USER appuser
EXPOSE ${PUERTO}
CMD ["python3", "/home/myapp/sample_app.py"]
DOCKERFILE

# 4. Construir la imagen y ejecutar el contenedor
cd tempdir
docker build -t sampleapp .
docker run -t -d -p ${PUERTO}:${PUERTO} --name samplerunning sampleapp
docker ps -a
