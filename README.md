# Hello World ML Engineering Project

A production-ready machine learning infrastructure project demonstrating modern MLOps practices with AWS, Kubernetes, and Infrastructure as Code.

## 🏗️ Architecture

### Infrastructure Components

**AWS Services:**
- **EKS (Elastic Kubernetes Service)**: Managed Kubernetes cluster for container orchestration
- **ECR (Elastic Container Registry)**: Private Docker image repository
- **VPC**: Isolated network with public/private subnets across 2 availability zones
- **S3**: Terraform state storage with versioning
- **DynamoDB**: Terraform state locking
- **Load Balancer**: Routes external traffic to application

**Kubernetes Resources:**
- **Deployment**: Manages application pods with rolling updates
- **Service**: LoadBalancer type exposing the application externally
- **Pods**: Running containerized FastAPI application

### Network Architecture

```
VPC: 10.0.0.0/16
├── Availability Zone us-east-1a
│   ├── Public Subnet (10.0.101.0/24)
│   │   └── NAT Gateway
│   └── Private Subnet (10.0.1.0/24)
│       └── EKS Worker Nodes
└── Availability Zone us-east-1b
    ├── Public Subnet (10.0.102.0/24)
    └── Private Subnet (10.0.2.0/24)
        └── EKS Worker Nodes
```

---

## 🚀 Application

**Technology Stack:**
- **Language**: Python 3.11
- **Framework**: FastAPI
- **Server**: Uvicorn (ASGI)
- **Container**: Docker
- **Orchestration**: Kubernetes

**Endpoints:**
- `GET /` - Hello world with timestamp and version
- `GET /health` - Health check endpoint
- `GET /docs` - Interactive API documentation (Swagger UI)

---

## 🔄 CI/CD Pipeline

### Infrastructure Pipeline (Terraform)

**Trigger:** Changes to `terraform/**` files

**Workflow:**
1. **Terraform Plan** (on PR or push)
   - Validates Terraform syntax
   - Shows infrastructure changes
   - No actual modifications

2. **Terraform Apply** (on push to main)
   - Applies infrastructure changes
   - Updates EKS, VPC, or other AWS resources
   - State stored in S3, locked via DynamoDB

### Application Pipeline

**Trigger:** Changes to `app/**`, `Dockerfile`, or `k8s-aws/**`

**Workflow:**
1. **Test**
   - Runs pytest suite
   - Validates code changes

2. **Build**
   - Builds Docker image
   - Tags with git commit SHA
   - Pushes to ECR

3. **Deploy**
   - Updates Kubernetes deployment
   - Performs rolling update (zero downtime)
   - Runs smoke tests
   - Verifies health endpoint

---

## 📁 Project Structure

```
hello-world-ml/
├── app/                          # Python application
│   ├── main.py                   # FastAPI application
│   ├── requirements.txt          # Python dependencies
│   └── test_main.py              # Unit tests
├── terraform/                    # Infrastructure as Code
│   ├── vars/
│   │   ├── dev.tfvars            # Dev environment config
│   │   └── prod.tfvars           # Prod environment config
│   ├── main.tf                   # Provider and backend config
│   ├── variables.tf              # Variable definitions
│   ├── vpc.tf                    # VPC networking
│   ├── eks.tf                    # Kubernetes cluster
│   ├── ecr.tf                    # Container registry
│   └── outputs.tf                # Terraform outputs
├── k8s-aws/                      # Kubernetes manifests
│   ├── deployment.yaml           # Application deployment
│   └── service.yaml              # LoadBalancer service
├── .github/workflows/            # CI/CD pipelines
│   ├── terraform.yaml            # Infrastructure automation
│   └── deploy-app.yaml           # Application deployment
├── Dockerfile                    # Container definition
└── README.md                     # This file
```

---

## 🛠️ Local Development

### Prerequisites
- Python 3.11+
- Docker Desktop
- AWS CLI configured
- kubectl
- Terraform

### Run Locally

```bash
# Install dependencies
cd app
python -m venv venv
source venv/bin/activate  # On Windows: .\venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Run application
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Visit http://localhost:8000
```

### Run Tests

```bash
cd app
pip install pytest pytest-cov httpx
pytest --cov
```

### Build Docker Image

```bash
docker build -t hello-world-ml:latest .
docker run -p 8000:8000 hello-world-ml:latest
```

---

## ☁️ Deployment

### Initial Infrastructure Setup

1. **Configure AWS credentials:**
   ```bash
   aws configure
   ```

2. **Deploy infrastructure:**
   ```bash
   cd terraform
   terraform init \
     -backend-config="bucket=hello-world-ml-tf-state-<account-id>" \
     -backend-config="key=dev/terraform.tfstate" \
     -backend-config="region=us-east-1" \
     -backend-config="dynamodb_table=hello-world-ml-tf-locks"
   
   terraform apply -var-file=vars/dev.tfvars
   ```

3. **Configure kubectl:**
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name hello-world-ml-dev
   ```

4. **Deploy application:**
   ```bash
   cd ../k8s-aws
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```

### Automated Deployment (CI/CD)

**For infrastructure changes:**
1. Edit files in `terraform/` directory
2. Commit and push to main branch
3. GitHub Actions automatically applies changes

**For application changes:**
1. Edit files in `app/` directory
2. Commit and push to main branch
3. GitHub Actions tests, builds, and deploys automatically

---

## 🔐 Security

**Practices Implemented:**
- Private subnets for worker nodes (not directly accessible from internet)
- NAT Gateway for secure outbound internet access
- AWS Secrets Manager for sensitive data (credentials stored in GitHub Secrets)
- Terraform state encryption at rest (S3 server-side encryption)
- Container image scanning enabled in ECR
- Resource tagging for cost tracking and governance

---

## 📊 Monitoring & Operations

### View Running Pods
```bash
kubectl get pods
```

### Check Pod Logs
```bash
kubectl logs -l app=hello-world-ml
```

### Scale Application
```bash
# Edit terraform/vars/dev.tfvars
desired_node_count = 2  # or any number

# Apply via CI/CD or manually
terraform apply -var-file=vars/dev.tfvars
```

### Get Load Balancer URL
```bash
kubectl get service hello-world-ml-service
```

