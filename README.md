# Containerized Terraform Provider for OCI - terraform-provider-oci

This Container Image is based on Alpine and contains Node.js, [OCI npm packages](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/typescriptsdk.htm), Terraform and the [Oracle Cloud Infrastructure (Terraform) Provider](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraform.htm) along with some basic (bash) helper scripts.
This Container Image is using Terraform version 1.1.7 and OCI Provider version 4.67.0.

## Getting the terraform-provider-oci Container Image

### Pulling the terraform-provider-oci Container Image
*Please note that it is recommended to pull the Container Image every now and then to make sure to get the latest fixes and features.*

```
docker pull joranlager/terraform-provider-oci
```
```
podman pull joranlager/terraform-provider-oci
```

## Running the terraform-provider-oci Container Image

### Create the directory to contain the Terraform configuration and state files for the given tenant's compartments
```
mkdir -p ~/terraform-provider-oci/mytenancy/harvested
```

### Create the file tenancy.env
```
cat << EOF > ~/terraform-provider-oci/mytenancy/tenancy.env
OCI_TENANCY_NAME=nose
OCI_TENANCY_OCID=ocid1.tenancy.oc1..aaaaaaaaflk52fndnkps3byra
OCI_USER_OCID=ocid1.user.oc1..aaaaaaaanufsmqwgjxpxhda
OCI_REGION=eu-frankfurt-1
EOF
```

### Run the terraform-provider-oci in interactive modus

#### Running on Unix / Linux based host
```
cd ~/terraform-provider-oci/mytenancy
docker run -it --rm --mount type=bind,source="$(pwd)",target=/root/.oci --mount type=bind,source="$(pwd)/harvested",target=/harvested --env-file tenancy.env joranlager/terraform-provider-oci /bin/bash
```
```
cd ~/terraform-provider-oci/mytenancy
podman run -it --rm --mount type=bind,source="$(pwd)",target=/root/.oci --mount type=bind,source="$(pwd)/harvested",target=/harvested --env-file tenancy.env joranlager/terraform-provider-oci /bin/bash
```

#### Running on Windows based host
```
cd terraform-provider-oci\mytenancy
docker run -it --rm --mount type=bind,source="%cd%",target=/root/.oci --mount type=bind,source="%cd%\harvested",target=/harvested --env-file tenancy.env joranlager/terraform-provider-oci /bin/bash
```

#### Creating and setting the required certificate and key to access OCI
*Please note that running the setup-oci will create PEM files for the certificates in the mounted host directory.
Please ensure that these files are stored safely. Subsequent running of the Docker image as defined above DOES NOT require running the setup-oci again, unless you have altered API Keys in your tenant related to this.*

For inital setup of the OCI CLI credentials / certificate or if you need to re-configure, run the setup-oci command in the container shell.
This will overwrite existing certificate and private key so please make sure that is the intention.
```
setup-oci
```
Running the script will show the configuration created including the public key in PEM format.
That content must be added as public authentication key for the given user:
1. Log in to the Oracle Cloud using a browser (e.g. https://console.eu-frankfurt-1.oraclecloud.com - where eu-frankfurt-1 is your OCI_REGION (https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm))
2. Navigate to Profile -> <user>, then select Resources -> API Keys and Add Public Key.
3. Paste the public key in PEM format and push Add button.

#### List compartments testing the client setup
```
compartments
```

#### Configure Oracle Cloud Infrastructure Provider parallelism and services to discover
Setting these environment variables are optional - default values will ensure to discover all services and use a parallelism of 1.
```
export TERRAFORM_PROVIDER_OCI_SERVICES=core,load_balancer
export TERRAFORM_PROVIDER_OCI_PARALLELISM=4
```
These environment variables can also be set in the tenancy.env file to set your own defaults if required by adding the following lines to that file:
```
TERRAFORM_PROVIDER_OCI_SERVICES=core,load_balancer
TERRAFORM_PROVIDER_OCI_PARALLELISM=4
```

#### Harvesting compartments in the tenant
Please note that OCIDs and compartment names can be used interchangeably.

Harvest Terraform configuration and state for given compartments in a tenancy by name separated by space:
```
harvest acompartmentname anothercompartment
ls -latr /harvested
```

Harvest Terraform configuration and state for all compartments in a tenancy:
```
harvest
ls -latr /harvested
```

#### Using the harvested Terraform configuration and state
From within the bash shell in the interactive modus, you can use terraform commands to perform relevant actions:
```
cd /harvested/acompartmentname
vi load_balancer.tf
terraform plan
```

## Storing the harvested Terraform files in Oracle Object Storage
This will only be available when using the upcoming Oracle Linux based Container Image.
The tag will be ol (joranlager/terraform-provider-oci:ol)

```
oci os bucket create --name bucket-terraform --compartment-id ocid1.compartment.oc1..aaaaaaaanywgss2v63u7mjiu4rb2ea
oci os object bulk-upload -ns nose -bn bucket-terraform --src-dir /harvested
```

## Building the Docker image

```
docker build -f Dockerfile -t joranlager/terraform-provider-oci:latest .
docker push joranlager/terraform-provider-oci:latest
```
```
podman build -f Dockerfile -t joranlager/terraform-provider-oci:latest .
podman push joranlager/terraform-provider-oci:latest
```
