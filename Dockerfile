FROM docker-hub-remote.arf.tesla.cn/jenkins/agent:4.9-1-jdk11

USER root
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
RUN sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
RUN apt-get update && apt-get install -y \
    curl \
    openssh-client \
    wget \
    git \
    apt-transport-https \
    ca-certificates \
    netbase \
    make \
    jq \
    gettext \
    python3-pip \
    python3-setuptools \
    make \
    gcc \
    g++ \
    libc6-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# rust
# RUN curl https://sh.rustup.rs -sSf > ./rustup.sh && chmod 755 ./rustup.sh && ./rustup.sh -y

# kubectl
RUN export DEBIAN_FRONTEND=noninteractive
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod 755 kubectl && \
    mv kubectl /usr/local/bin/kubectl && \
    rm -rf /var/lib/apt/lists/*

# docker
RUN curl -sSL https://get.docker.com/ | sh 

# RUN pip3 config set global.index-url https://arf.tesla.cn/artifactory/api/pypi/pypi-proxy/simple
RUN pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/
RUN pip3 install --upgrade pip
RUN pip3 install docker-compose

# helm
RUN wget https://mirrors.huaweicloud.com/helm/v3.8.0/helm-v3.8.0-linux-amd64.tar.gz && tar zxvf helm-v3.8.0-linux-amd64.tar.gz && \
    chmod 755 linux-amd64/helm && mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf helm-v3.8.0-linux-amd64.tar.gz && rm -rf linux-amd64

# jenkins agent
COPY ./jenkins-agent /usr/local/bin/jenkins-agent
RUN chmod +x /usr/local/bin/jenkins-agent &&\
    ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave

# Fuze CLI
RUN curl https://artifactory.teslamotors.com/artifactory/list/pe-fuze-generic-local/latest/fuze_linux_amd64 -o /usr/local/bin/fuze && chmod 755 /usr/local/bin/fuze

# Helm Diff
RUN mkdir -p /root/.local/share/helm/plugins
ADD ./helm-diff-linux-amd64.tgz /root/.local/share/helm/plugins/

# JASC CLI
RUN curl https://devops.tesla.cn/jascli/downloads/jasc-amd64-linux -o /usr/local/bin/jasc && chmod 755 /usr/local/bin/jasc

RUN mkdir /app
WORKDIR /app

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]
