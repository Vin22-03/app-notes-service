FROM jenkins/jenkins:lts

USER root

# 🛠️ Install required tools
RUN apt-get update && \
    apt-get install -y docker.io curl unzip gnupg software-properties-common && \
    apt-get install -y python3 python3-pip

# 🔧 Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && \
    rm -rf awscliv2.zip aws

# 🔧 Install Terraform (without lsb_release)
ENV DEBIAN_FRONTEND=noninteractive
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    echo "deb [trusted=yes] https://apt.releases.hashicorp.com bullseye main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get install -y terraform

# 🧹 Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

USER jenkins
