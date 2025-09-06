# 📝 Vin Notes App – CI/CD Capstone with DevSecOps | AWS | Jenkins | Docker | Terraform | Prometheus | Grafana

> 🚀 A full-stack Flask-based notes app deployed to **AWS ECS Fargate** using a fully automated **CI/CD pipeline** with **DevSecOps**, Infrastructure as Code, Monitoring, and Code Quality integration.

---

## 🧠 Project Overview

This project simulates a **real-world cloud-native deployment workflow** from GitHub → Jenkins → AWS infrastructure. It showcases complete DevOps skills including:

- ✅ CI/CD Pipeline (Jenkins Declarative)
- 🐳 Docker Build & ECR Push
- 📦 ECS Fargate Deployment
- 🏗️ Terraform Infra Provisioning
- 🧪 Pytest Unit Testing
- 📊 Prometheus + Grafana Monitoring
- 🔐 Trivy Scan (Security)
- 🔍 SonarQube Analysis (Code Quality)
- 📦 SBOM (Software Bill of Materials)
- 🟢 Blue/Green Deployment via CodeDeploy
- ✅ ECS Service Verification

---

---

## 🧪 Features Performed in Pipeline

| Stage                         | Tool / Description                        |
|------------------------------|-------------------------------------------|
| ✔️ Checkout SCM              | GitHub source fetch                       |
| 🧪 Run Tests                 | Pytest for API unit testing               |
| 🔐 Trivy Scan                | Container vulnerability scan              |
| 🧾 Generate SBOM             | Software Bill of Materials (CycloneDX)    |
| 🔍 SonarQube Analysis        | Code quality, maintainability, security   |
| 🐳 Build Docker Image        | Flask app Dockerized                      |
| 📦 Push to AWS ECR           | Private image registry                    |
| ⚙️ Terraform Deploy Infra    | ECS Cluster, Task, ALB, Target Group       |
| 🔁 CodeDeploy Blue/Green     | Deployment to new ECS version             |
| ✅ ECS Service Verification  | Health check verification                 |

---

## 📊 Monitoring Dashboard

📍 **Prometheus** scrapes metrics exposed at `/metrics` endpoint  
📍 **Grafana** displays:

- 🔁 Request rate
- 📉 Response time
- 🔁 Request method
- 🚨 HTTP 5xx errors
- 🐍 Flask-specific metrics

---

## ☁️ AWS Resources Provisioned

- ✅ VPC, Subnets, Security Groups
- ✅ ECS Fargate Cluster & Services
- ✅ ALB with Target Group
- ✅ ECR Repositories
- ✅ S3 (Terraform backend)
- ✅ CodeDeploy App + Deployment Group

Provisioned using **Terraform** with modular structure and remote state in S3.

---

## 📷 Screenshots

### ✅ Jenkins Pipeline View
![Jenkins Pipeline](./screenshots/pipeline.png)

### ✅ SonarQube Report
![SonarQube](./screenshots/sonarqube.png)

### 📊 Grafana Dashboard
![Grafana Dashboard](./screenshots/grafana.png)

---

## 🛡️ DevSecOps Integration

| Tool        | Purpose                                |
|-------------|-----------------------------------------|
| **Trivy**   | Vulnerability scanning of Docker image  |
| **SonarQube**| Code smells, bugs, and hotspots        |
| **SBOM**    | Tracks components and licenses          |

---

## 🚀 How to Run (Locally or Cloud)

### 1️⃣ Start Jenkins (via Docker)
```bash
docker-compose up -d
```
2️⃣ Trigger CI/CD pipeline
```
Push code to GitHub → Jenkins Webhook triggers full pipeline
```
3️⃣ Access Services
```
Flask App → http://<ALB-DNS>

Prometheus → http://localhost:9090

Grafana → http://localhost:3000

SonarQube → http://localhost:9000
```
📌 Tech Stack
```
Backend: Flask + Python

CI/CD: Jenkins (Freestyle/Declarative)

Containers: Docker + ECR

IaC: Terraform

Cloud: AWS (ECS Fargate, ALB, CodeDeploy)

Monitoring: Prometheus + Grafana

Security: Trivy + SBOM

Quality: SonarQube
```
👨‍💻 Author
```
Vinay Bhajantri (aka VinCloudOps)
🛠️ From UPSC to Cloud & DevOps Engineer 🚀
📍 LinkedIn

📁 Portfolio

📦 GitHub: @Vin22-03
```

