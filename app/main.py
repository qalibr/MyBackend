from fastapi import FastAPI
from app.core.config import settings

app = FastAPI(title=settings.PROJECT_NAME)

@app.get("/")
def root():
    return {
        "message": f"Welcome to {settings.PROJECT_NAME}!",
        "environment": settings.ENV_NAME,
        "status": "Operational"
    }

@app.get("/health")
def health_check():
    """
    Health check endpoint for Azure Load Balancer.
    """
    return {"status": "healthy"}