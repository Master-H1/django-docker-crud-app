FROM python:3.12-slim

# Prevent creating .pyc files
ENV PYTHONDONTWRITEBYTECODE 1
# Prevent Python from buffering stdout and stderr
ENV PYTHONUNBUFFERED 1

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt --no-cache-dir

COPY . /app/

# Expose the port
EXPOSE 8000

# Run the server
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
