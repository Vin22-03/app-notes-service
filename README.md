# 📝 Vin Notes App – CI/CD Capstone with DevSecOps | AWS | Jenkins | Docker | Terraform | Prometheus | Grafana

> 🚀 A full-stack Flask-based notes app deployed to **AWS ECS Fargate** using a fully automated **CI/CD pipeline** with **DevSecOps**, Infrastructure as Code, Monitoring, and Code Quality integration.

---
## 🛠️ My First End-to-End CI/CD DevOps Project

This project is **very special to me** — it's my **first complete CI/CD DevOps pipeline**, built with ❤️ and a LOT of learning.

Over **4–5 days**, I:
- 📦 Dockerized my Flask app
- 🧪 Integrated **unit testing**, **code quality scanning** (SonarQube), and **vulnerability analysis** (Trivy, Syft)
- 🚀 Set up a robust CI/CD flow using **Jenkins**, pushing images to **AWS ECR** and deploying on **ECS Fargate**
- 📈 Added real-time **monitoring** with **Prometheus** and **Grafana**
- ☁️ Collected logs with **CloudWatch**, and
- 📜 Provisioned everything with **Terraform**, even tried **CodeDeploy**!

 💬 I encountered many real-world DevOps challenges:
 - Debugging Jenkins permission issues
 - ECR push errors
 - ECS deployment loops
 - Prometheus not scraping metrics
 - Grafana showing “No data” 😫
 
 …and each bug taught me something valuable.

I didn't just learn tools — I learnt **resilience**, **problem-solving**, and **how DevOps really works in the real world.** 💡

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

### ✅ Final Page
![Final Page](https://github.com/Vin22-03/app-notes-service/blob/main/Screenshots/Final_page.png)

### ✅ Jenkins Pipeline View
![Jenkins Pipeline](https://github.com/Vin22-03/app-notes-service/blob/main/Screenshots/pipeline%20with%20sonarqube.png)

### ✅ SonarQube Report
![SonarQube](https://github.com/Vin22-03/app-notes-service/blob/main/Screenshots/Sonarqube.png)

### 📊 Grafana Dashboard
![Grafana Dashboard](https://github.com/Vin22-03/app-notes-service/blob/main/Screenshots/grafana_zoom.png)

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
## 👨‍💻 Author

Vinay Bhajantri
🛠️ Aspriring Cloud & DevOps Engineer 🚀
- 📍 [LinkedIn](www.linkedin.com/in/vinayvbhajantri)
-  📁[Portfolio](www.vincloudops.tech)
-  📦GitHub: @Vin22-03

