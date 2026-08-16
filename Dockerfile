FROM python:3.12.3-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY ./app/requirements.txt .
RUN python3 -m pip install --upgrade pip \
    && pip3 install --no-cache-dir -r requirements.txt

# Этап 2: Финальный образ
FROM python:3.12.3-slim

LABEL maintainer="dimuvar11@gmail.com"
LABEL version="1.0"
LABEL description="FastAPI simple application"

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin 

ENV LOG_LEVEL=INFO \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PATH="/root/.local/bin:$PATH"

WORKDIR /app
COPY ./app .

RUN groupadd -r appuser \
    && useradd -r -g appuser -m -s /bin/bash appuser \
    && chown -R appuser:appuser .
USER appuser

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

EXPOSE 5000

CMD [ "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000" ]
