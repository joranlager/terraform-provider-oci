# Oracle OCI Harvester - oci-harvester

## Getting the oci-harvester Container Image

### Pulling the oci-harvester Container Image
*Please note that it is recommended to pull the Container Image every now and then to make sure to get the latest fixes and features.*

```
docker pull joranlager/oci-harvester
```

## Running the oci-harvester Container Image

### Create the directory to contain state and diagrams for the given tenant
```
mkdir -p ~/oci-harvester/mytenancy/harvested
```

### Create the file tenancy.env
```
cat << EOF > ~/oci-harvester/mytenancy/tenancy.env
OCI_TENANCY_NAME=nose
OCI_TENANCY_OCID=ocid1.tenancy.oc1..aaaaaaaaflk52fndnkps3byra
OCI_USER_OCID=ocid1.user.oc1..aaaaaaaanufsmqwgjxpxhda
OCI_REGION=eu-frankfurt-1
EOF
```

### Run the oci-harvester in interactive modus

#### Running on Unix / Linux based host
```
cd ~/oci-harvester/mytenancy
docker run -it --rm --mount type=bind,source="$(pwd)",target=/root/.oci --mount type=bind,source="$(pwd)/harvested",target=/harvested --env-file tenancy.env joranlager/oci-harvester /bin/bash
```

#### Running on Windows based host
```
cd oci-harvester\mytenancy
docker run -it --rm --mount type=bind,source="%cd%",target=/root/.oci --mount type=bind,source="%cd%\harvested",target=/harvested --env-file tenancy.env joranlager/oci-harvester /bin/bash
```

#### Creating and setting the required certificate and key to access OCI
*Please note that running the setup-oci will create PEM files for the certificates in the mounted host directory.
Please ensure that these files are stored safely. Subsequent running of the Docker image as defined above DOES NOT require running the setup-oci again, unless you have altered API Keys in your tenant related to this.*

For inital setup of the OCI CLI credentials / certificate of if you need to re-configure, run the setup-oci command in the container shell.
This will overwrite existing certificate and private key so make sure that is the intention.
```
setup-oci
```
Running the script will show the configuration created including the public key in PEM format.
That content must be added as public authentication key for the given user:
1. Log in to the Oracle Cloud using a browser (https://console.eu-frankfurt-1.oraclecloud.com)
2. Navigate to Profile -> <user>, then select Resources -> API Keys and Add Public Key.
3. Paste the public key in PEM format and push Add button.

#### List compartments testing the client setup
```
compartments
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

## Storing the generated diagrams in Oracle Object Storage
This will only be available when using the Oracle Linux 7 based Docker image.
The tag is ol7.

```
oci os bucket create --name bucket-terraform --compartment-id ocid1.compartment.oc1..aaaaaaaanywgss2v63u7mjiu4rb2ea
oci os object bulk-upload -ns nose -bn bucket-terraform --src-dir /harvested
```

## Building the Docker image

```
docker build -f Dockerfile -t joranlager/oci-harvester:latest .
docker push joranlager/oci-harvester:latest
```