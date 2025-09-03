FROM jenkins/jenkins:lts

USER root

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

# Add Jenkins user to Docker group
RUN usermod -aG docker jenkins

USER jenkins
