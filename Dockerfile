FROM python:3.9.6-slim-buster

RUN mkdir /software
WORKDIR /software

# install common apt pakcages
RUN apt-get update
RUN apt-get install -y \
    # curl - required for Dockerfile script
    curl \
    # gnupg2 - required to run: apt-key add
    gnupg2 \
    # jq - is used in sur bash scripts
    jq

# install kubectl
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add -
RUN apt-get install apt-transport-https --yes
RUN echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
RUN apt-get update
RUN apt-get install helm

# install kubectl
ARG KUBECTL_VERSION=v1.21.0
RUN curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl

# install istioctl
ARG ISTIOCTL_VERSION=1.6.8
RUN curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIOCTL_VERSION TARGET_ARCH=x86_64 sh -
ARG ISTIO_HOME=/software/istio-$ISTIOCTL_VERSION
RUN echo "export ISTIO_HOME=$ISTIO_HOME" | tee -a ~/.bashrc \
    && echo "export PATH=$ISTIO_HOME/bin:$PATH" | tee -a ~/.bashrc

# install python packages
# COPY old/container /opt/
# RUN pip install -r /opt/requirements.txt

# add handy alias for interactive mode (for development purpose)
RUN echo "alias sur='/bin/bash /opt/image_sur.sh'" | tee -a ~/.bashrc


WORKDIR /opt

ENTRYPOINT ["/bin/bash", "/opt/image_sur.sh"]


