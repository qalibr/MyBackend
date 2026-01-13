# Azure FastAPI Cloud Learning Project

## About The Project

This project was created to explore cloud computing fundamentals and Infrastructure as Code (IaC) principles. The goal was to build a modern, containerized backend service and deploy it to Microsoft Azure using automated workflows.

It demonstrates a "GitOps" approach where infrastructure changes and application deployment are handled through code and CI/CD pipelines.

## Tech Stack

* **Language:** Python 3.11
* **Framework:** FastAPI
* **Infrastructure as Code:** Terraform
* **Cloud Provider:** Microsoft Azure (Norway East Region)
* **Containerization:** Docker (Multi-stage builds)
* **Orchestration:** Azure Container Apps (Serverless Kubernetes)
* **CI/CD:** GitHub Actions

## Architecture & Infrastructure

The infrastructure is defined entirely in Terraform (`terraform/main.tf`) and consists of the following Azure resources:

1. **Resource Group:** `rg-student-backend-norway` hosting all resources.
2. **Azure Container Registry (ACR):** Stores the Docker images for the application.
3. **Log Analytics Workspace:** Centralized logging for the environment.
4. **Container Apps Environment:** The managed environment hosting the microservices.
5. **Container App:** The FastAPI instance with the following configurations:
    * **Resources:** 0.25 CPU, 0.5Gi Memory.
    * **Scaling:** Minimum 1 replica to prevent cold starts (previously optimized to save costs).
    * **Health Checks:** Configured Liveness and Readiness probes on port 8000.

## Project Structure

```text
.
├── .github/workflows/   # CI/CD pipeline definition
├── app/                 # Python source code
│   ├── core/            # Config and settings
│   └── main.py          # Application entry point and endpoints
├── terraform/           # Infrastructure as Code files
├── Dockerfile           # Multi-stage Docker build instructions
└── requirements.txt     # Python dependencies
```

## How To Get Started

### 1. Local development

```sh
git clone <https://github.com/qalibr/MyBackend.git>
cd MyBackend
```

### 2. Set up Python Environment

```sh
python -m venv .venv
```

Next, activate the environment. The command depends on your shell:

* **On Windows (PowerShell):**

    ```powershell
    .\.venv\Scripts\Activate.ps1
    ```

* **On macOS & Linux (bash/zsh):**

    ```sh
    source .venv/bin/activate
    ```

Finally, install the dependencies:

```sh
pip install -r requirements.txt
```

### 3. Run the App

```sh
uvicorn app.main:app --reload
```

The API will be available at ``http://localhost:8000``.

## Infrastructure Deployment (Terraform)

You need <https://developer.hashicorp.com/terraform/install>.

(Look into <https://scoop.sh/> to make your life easier.)

### 1. Navigate to the terraform directory

```sh
cd terraform
```

### 2. Initialize Terraform

```sh
terraform init
```

### 3. Create a ``terraform.tfvars`` file (never commit this) with your Azure credentials

```sh
subscription_id = "your-sub-id"
client_id       = "your-sp-app-id"
client_secret   = "your-sp-password"
tenant_id       = "your-tenant-id"
acr_name        = "unique_acr_name"
```

### 4. Apply the infrastructure

```sh
terraform apply
```

## CI/CD Pipeline

The project uses GitHub Actions (``.github/workflows/deploy.yml``) to automate deployment.

### Triggers

* Push to the ``main`` branch.

### Workflow Steps

Build: Check out code, set up Docker Buildx, and build the image.

Push: Push the container image to the Azure Container Registry.

Deploy: Update the Azure Container App with the new image revision.

### Required GitHub Secrets

To make the pipeline work, the following secrets are configured in your GitHub repository settings.

``AZURE_CREDENTIALS``: JSON output from ``az ad sp create-for-rbac``.

``ACR_LOGIN_SERVER``: The URL of your registry (e.g., ``myregistry.azurecr.io``).

``ACR_USERNAME`` & ``ACR_PASSWORD``: Admin credentials for the registry.

### API Endpoints

``GET /``: Returns the project name, environment status, and operational message.

``GET /health``: Health check endpoint used by Azure Load Balancer.

``GET /docs``: Interactive Swagger UI documentation.
