#!/bin/bash

# Running silent:
export tenancy_name=$OCI_TENANCY_NAME
export tenancy_ocid=$OCI_TENANCY_OCID
export user_ocid=$OCI_USER_OCID
export region=$OCI_REGION

export key_path="/root/.oci"
export key_name=$OCI_TENANCY_NAME
#https://github.com/terraform-providers/terraform-provider-oci/issues/712
#export key_passphrase="hello"

export private_key_file="${key_path}/${key_name}.pem"
export public_key_file="${key_path}/${key_name}_public.pem"

#https://docs.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm#SDK_and_CLI_Configuration_File
#oci setup keys --key-name ${key_name} --output-dir ${key_path} --passphrase=${key_passphrase} --overwrite > ${key_path}/setupstatus.txt
#https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#apisigningkey_topic_How_to_Generate_an_API_Signing_Key_Console
openssl genrsa -out ${private_key_file} 2048
openssl rsa -pubout -in ${private_key_file} -out ${public_key_file}             

#public key fingerprint:
#export fingerprint=$(grep fingerprint ${key_path}/setupstatus.txt | cut -d ' ' -f4)
export fingerprint=$(openssl rsa -pubout -outform DER -in ${private_key_file} | openssl md5 -c | cut -d ' ' -f2)
echo $fingerprint

echo -e "[DEFAULT]\nuser=${user_ocid}\nfingerprint=${fingerprint}\nkey_file=${private_key_file}\ntenancy=${tenancy_ocid}\nregion=${region}" > /root/.oci/config
echo -e "region=${region}\ntenancy_ocid=${tenancy_ocid}\nuser_ocid=${user_ocid}\nfingerprint=${fingerprint}\nprivate_key_path=${private_key_file}\nprivate_key_password=${key_passphrase}" > /root/.oci/terraform.tfvars

echo "*********** oci config ***************"
cat /root/.oci/config

echo "*********** terraform.tfvars ***************"
cat /root/.oci/terraform.tfvars

echo "Public key PEM:"
echo https://docs.cloud.oracle.com/Content/API/Concepts/apisigningkey.htm#How2
cat ${public_key_file}
