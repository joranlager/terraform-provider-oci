# oci-harvester DOCKERFILE
# ----------------------------
# This Dockerfile creates a Docker image using Alpine, Node.js, OCI npm packages, Terraform and the Oracle Cloud Infrastructure (Terraform) Provider.
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# docker build -f Dockerfile -t joranlager/oci-harvester:latest .
# docker push joranlager/oci-harvester:latest

FROM alpine

MAINTAINER joran.lager@oracle.com

USER root

ARG TERRAFORM_VERSION=0.12.13
ARG OCI_PROVIDER_VERSION=4.23.0

RUN apk --update --no-cache add nodejs npm curl bash jq openssl && \
npm install -production oci-common oci-identity

RUN mkdir /terraform && \
    cd /terraform && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    curl https://releases.hashicorp.com/terraform-provider-oci/${OCI_PROVIDER_VERSION}/terraform-provider-oci_${OCI_PROVIDER_VERSION}_linux_amd64.zip -o terraform-provider-oci_${OCI_PROVIDER_VERSION}_linux_amd64.zip && \
    unzip terraform-provider-oci_${OCI_PROVIDER_VERSION}_linux_amd64.zip && \
    rm terraform-provider-oci_${OCI_PROVIDER_VERSION}_linux_amd64.zip && \
    ln -s $(ls /terraform/terraform) /usr/local/bin/terraform && \
    ln -s $(ls /terraform/terraform-provider-oci*) /usr/local/bin/terraform-provider-oci

COPY setup-oci.sh harvest.sh compartments.js compartments.sh /oci-harvester/

RUN chmod 755 /oci-harvester/setup-oci.sh /oci-harvester/harvest.sh /oci-harvester/compartments.sh && \
ln -s /oci-harvester/setup-oci.sh /usr/local/bin/setup-oci && \
ln -s /oci-harvester/harvest.sh /usr/local/bin/harvest && \
ln -s /oci-harvester/compartments.sh /usr/local/bin/compartments && \
mkdir /harvested

ENV TERRAFORM_PROVIDER_OCI_SERVICES=
ENV TERRAFORM_PROVIDER_OCI_PARALLELISM=1

WORKDIR /oci-harvester

CMD ["bash"]
