FROM python:3.12.3 AS builder
WORKDIR /app
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser
COPY ./app/requirements.txt .
RUN pip3 install --user --no-cache-dir -r requirements.txt


FROM python:3.12.3-slim
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PATH="/home/appuser/.local/bin:$PATH"
WORKDIR /app
COPY --from=builder /root/.local /home/appuser/.local
COPY ./app .
RUN addgroup --system --gid 1001 appuser \
    && adduser --system --uid 1001 --gid 1001 --no-create-home --home /home/appuser appuser \
    && chown -R appuser:appuser .
USER appuser
EXPOSE 5000
CMD [ "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000" ]

