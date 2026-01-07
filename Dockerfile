# Stage 1: Builder
FROM python:3.11-slim AS builder

WORKDIR /code

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /code/requirements.txt
RUN pip install --no-cache-dir --user -r /code/requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

WORKDIR /code

# Copy only the installed packages from the builder stage
COPY --from=builder /root/.local /home/appuser/.local
COPY ./app /code/app

ENV PATH=/home/appuser/.local/bin:$PATH
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN adduser --disabled-password --gecos '' appuser
RUN chown -R appuser:appuser /code
USER appuser

EXPOSE 8000

# Command to run the application using Uvicorn (ASGI server)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]