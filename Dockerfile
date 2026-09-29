# Stage 1 — Build React frontend
FROM node:22-alpine AS frontend
WORKDIR /app/web
COPY broadlinkmanager/web/package*.json ./
RUN npm install --no-fund --no-audit
COPY broadlinkmanager/web/ ./
RUN npm run build
# Vite outDir is '../dist' so output lands at /app/dist

# Stage 2 — Python runtime
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
      iputils-ping \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY broadlinkmanager/ /app/

COPY --from=frontend /app/dist /app/dist 

EXPOSE 7020 

CMD ["python", "broadlinkmanager.py"]
