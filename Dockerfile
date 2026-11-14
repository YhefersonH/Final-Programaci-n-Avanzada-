# 1. Imagen base oficial de Python 3.12, versión liviana
FROM python:3.12-slim

# 2. Carpeta de trabajo dentro del contenedor
WORKDIR /app

# 3. Primero SOLO requirements.txt: así Docker reutiliza la caché de las
#    dependencias si solo cambia el código (el build tarda segundos)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Ahora sí, las carpetas que necesita la app
COPY app/ app/
COPY frontend/ frontend/
COPY models/ models/

# 5. Puerto en el que escucha la app
EXPOSE 8000

# 6. Arranque: host 0.0.0.0 para que sea accesible desde fuera del contenedor
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]