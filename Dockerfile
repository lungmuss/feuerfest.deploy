FROM python:3.9-slim-buster

ARG BUILD_DATE
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="feuerfest.deploy" \
      org.label-schema.description="Installs pip3, Terraform, Ansible, Age and Sops." \
      org.label-schema.vcs-url="https://github.com/lungmuss/feuerfest.deploy" \
      org.label-schema.schema-version="1.0"

# Build Arguments for software versions
ARG TERRAFORM_VERSION=1.4.6
ARG ANSIBLE_VERSION=2.14.5
ARG SOPS_VERSION=3.7.3
ARG AGE_VERSION=1.0.0

# Set Environment Variables
ENV DEBIAN_FRONTEND noninteractive
ENV TERRAFORM_VERSION ${TERRAFORM_VERSION}
ENV ANSIBLE_VERSION ${ANSIBLE_VERSION}
ENV SOPS_VERSION ${SOPS_VERSION}
ENV AGE_VERSION ${AGE_VERSION}

# Install dependencies
RUN apt-get update && \
    apt-get install -y openssh-client procps git-core

# Upgrade pip and install Ansible
RUN pip3 install --upgrade pip && pip3 install ansible-core==${ANSIBLE_VERSION} 
# Install Terraform
RUN apt-get install -y unzip curl && \
    curl -O https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
# Not using requirements.txt for clarity
RUN ansible-galaxy collection install kubernetes.core && \
      ansible-galaxy collection install ansible.posix && \
      ansible-galaxy collection install community.general && \
      ansible-galaxy collection install community.sops && \
      ansible-galaxy collection install community.postgresql

# Install SOPS
RUN curl -L -o sops.deb https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops_${SOPS_VERSION}_amd64.deb && \
    dpkg -i sops.deb && rm sops.deb

# Install Age
RUN apt-get install -y wget && \
    wget https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-amd64.tar.gz && \
    tar -xf age-v${AGE_VERSION}-linux-amd64.tar.gz && \
    mv age/age /usr/local/bin/ && \
    rm -r age age-v${AGE_VERSION}-linux-amd64.tar.gz

# Clean up APT when done
RUN apt-get clean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

CMD [ "/bin/bash" ]
