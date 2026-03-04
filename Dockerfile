# ======= Stage 1 - builder =======
FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install system dependencies for building wheels
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements packages
COPY requirements.txt .

# Install dependencies into /install
RUN pip install --upgrade pip
RUN pip install --prefix=/install -r requirements.txt

# ======= Stage 2 - production =======
FROM python:3.12-slim AS production

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install runtine dependencies only (no build-essential/compilers)
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy only the installed dependencies from builder
COPY --from=builder /install /usr/local

# Copy application code
COPY . .

# Create non-root user and switch to it
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser
USER appuser

# Expose port
EXPOSE 8000

# Command to run the application using gunicorn
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]