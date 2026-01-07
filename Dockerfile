# Base image: Python 3.11 Slim (Debian based, smaller than full)
FROM python:3.11-slim

# Set working directory
WORKDIR /code

# Set env vars to optimize Python execution in containers
# Prevents Python from writing.pyc files
ENV PYTHONDONTWRITEBYTECODE 1
# Ensures logs are flushed immediately (Factor 11)
ENV PYTHONUNBUFFERED 1

# Install dependencies
# We copy ONLY requirements first to leverage Docker Layer Caching
COPY ./requirements.txt /code/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Copy the rest of the application
COPY ./app /code/app

# Create a non-root user for security (Best Practice)
# Running as root is a major security risk in production
RUN adduser --disabled-password --gecos '' appuser
USER appuser

# Expose port 8000
EXPOSE 8000

# Command to run the application using Uvicorn (ASGI server)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]