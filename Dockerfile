# terraform-provider-oci DOCKERFILE
# ----------------------------
# This Dockerfile creates a Docker image using Alpine, Node.js, OCI npm packages, Terraform and the Oracle Cloud Infrastructure (Terraform) Provider.
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# docker build -f Dockerfile -t joranlager/terraform-provider-oci:latest .
# docker push joranlager/terraform-provider-oci:latest

FROM alpine:3.15.0

MAINTAINER joran.lager@oracle.com

USER root

ARG TERRAFORM_VERSION=1.1.7
ARG OCI_PROVIDER_VERSION=4.67.0

RUN apk --update --no-cache add nodejs npm curl bash jq openssl

RUN mkdir /terraform && \
    cd /terraform && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    curl https://releases.hashicorp.com/terraform-provider-oci/${OCI_PROVIDER_VERSION}/terraform-provider-oci_${OCI_PROVIDER_VERSION}_linux_amd64.zip -o terraform-provider-oci_${OCI_PROVIDER_VERSION}_linux_amd64.zip && \
    unzip terraform-provider-oci_${OCI_PROVIDER_VERSION}_linux_amd64.zip && \
    rm terraform-provider-oci_${OCI_PROVIDER_VERSION}_linux_amd64.zip && \
    ln -s $(ls /terraform/terraform) /usr/local/bin/terraform && \
    ln -s $(ls /terraform/terraform-provider-oci*) /usr/local/bin/terraform-provider-oci && \
    mkdir /terraform-provider-oci

WORKDIR /terraform-provider-oci

RUN npm install -production oci-common oci-identity

COPY setup-oci.sh harvest.sh compartments.js compartments.sh /terraform-provider-oci/

RUN chmod 755 /terraform-provider-oci/setup-oci.sh /terraform-provider-oci/harvest.sh /terraform-provider-oci/compartments.sh && \
ln -s /terraform-provider-oci/setup-oci.sh /usr/local/bin/setup-oci && \
ln -s /terraform-provider-oci/harvest.sh /usr/local/bin/harvest && \
ln -s /terraform-provider-oci/compartments.sh /usr/local/bin/compartments && \
mkdir /harvested

ENV TERRAFORM_PROVIDER_OCI_SERVICES=
ENV TERRAFORM_PROVIDER_OCI_PARALLELISM=1

WORKDIR /terraform-provider-oci

CMD ["bash"]
