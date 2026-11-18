# Pronóstico de consumo eléctrico · Proyecto final

**Computación Avanzada (ET0197) · Institución Universitaria Pascual Bravo**
Autor: **Yheferson Henao**

## 🎥 Video

**[▶ Ver el video de sustentación (máx. 5 min)] https://www.youtube.com/watch?v=5BsT9e8SSnU&feature=youtu.be

El video muestra la app funcionando de las dos formas: sin Docker (con `uvicorn`) y con Docker (`docker build` + `docker run`), con datos reales de InfluxDB.

---

## Qué hace

Servicio web que pronostica las próximas horas del **consumo eléctrico** (`Server` / `Consumo_total`, bucket `Consumo_elec` de InfluxDB) con un modelo **SARIMA** entrenado en Google Colab. La API está hecha con **FastAPI**, el frontend es una página con gráfica del histórico, el pronóstico y su intervalo de confianza, y todo se empaqueta en un contenedor **Docker**.

## Modelo

- SARIMA con ciclo diario (s = 24), entrenado con 30 días de datos horarios (720 h).
- Evaluación sobre las últimas 24 h frente a una línea base ingenua estacional:

| Métrica | SARIMA | Ingenua estacional |
|---|---|---|
| MAE | 29.394 | 69.623 |
| RMSE | 45.325 | 93.127 |
| MAPE | 8.96 % | 21.49 % |

- Verificación de exportación: `Diferencia máxima API vs. modelo original: 0.0`.
- Archivos: [`models/sarima_config.json`](models/sarima_config.json) y [`notebooks/entrenamiento_sarima_colab.ipynb`](notebooks/entrenamiento_sarima_colab.ipynb).

## Frontend

`frontend/index.html`: gráfica con histórico, pronóstico e intervalo de confianza, horas en **hora de Colombia (UTC−5)**, indicadores destacados (próxima hora, máximo esperado, promedio, último dato real), controles para elegir las horas a pronosticar y mensajes claros cuando la API responde con error. Soporta modo claro y oscuro.

## Estructura

```
.
├── app/                 API FastAPI (consulta InfluxDB, carga el modelo, pronostica)
├── frontend/index.html  Interfaz web
├── models/              sarima_config.json (modelo entrenado en Colab)
├── notebooks/           Notebook de entrenamiento ejecutado
├── scripts/             Utilidades (probar_conexion.py)
├── Dockerfile
├── .dockerignore
└── requirements.txt
```

## Cómo ejecutarlo

Las credenciales **nunca** van en el código ni en la imagen: se leen de variables de entorno (`INFLUX_URL`, `INFLUX_TOKEN`, `INFLUX_ORG`, `INFLUX_BUCKET`), por ejemplo como *Codespaces secrets*.

### Sin Docker

```bash
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Abrir el puerto 8000. Estado del servicio en `/api/salud` (debe decir `"modelo_demo": false`).

### Con Docker

```bash
docker build -t pronostico .
docker run --rm -p 8000:8000 \
  -e INFLUX_URL -e INFLUX_TOKEN -e INFLUX_ORG -e INFLUX_BUCKET \
  pronostico
```

En otra terminal, `docker ps` muestra el **CONTAINER ID**, que coincide con el campo `atendido_por` de `/api/salud`.

## Endpoints

| Endpoint | Descripción |
|---|---|
| `GET /api/prediccion?horas=12&historia=48&confianza=0.95` | Pronóstico + intervalo + histórico |
| `GET /api/historico?horas=48` | Solo el histórico |
| `GET /api/modelo` | Órdenes del SARIMA, métricas y fecha de entrenamiento |
| `GET /api/salud` | Estado del servicio y `atendido_por` |
