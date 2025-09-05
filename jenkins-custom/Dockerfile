FROM jenkins/jenkins:lts

USER root

# Set ARG to dynamically pass host Docker group GID during build
ARG DOCKER_GID=1001

# Update and install required packages
RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    docker.io \
    unzip wget curl jq \
    awscli \
    gnupg software-properties-common

# Install Terraform (1.6.6)
RUN wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip && \
    unzip terraform_1.6.6_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_1.6.6_linux_amd64.zip

# Upgrade pip and install Python packages
RUN pip3 install --upgrade pip --break-system-packages && \
    pip3 install pytest --break-system-packages

# 🔐 Install Trivy (vulnerability scanner)
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# 📦 Install Syft (SBOM generator)
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# 👇 This is the KEY PART to fix permission error
# Re-create docker group with same GID as host, and add jenkins user to it
RUN groupmod -g ${DOCKER_GID} docker || true && \
    usermod -aG docker jenkins

USER jenkins
