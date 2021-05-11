#!/bin/bash
#https://www.terraform.io/docs/providers/oci/guides/resource_discovery.html
#https://registry.terraform.io/providers/hashicorp/oci/latest/docs/guides/resource_discovery#supported-resources
cd /harvested > /dev/null

node /oci-harvester/compartments.js > compartments.json

# If no arguments are given, get the names of all compartments and iterate on them:
if [ $# -eq 0 ]
then
  numcompartments=0

  numcompartments=$(cat compartments.json | jq '.[].value | .name' | wc -l)

  echo Found $numcompartments compartments

  for i in $(jq -r ".[].value | .name" compartments.json)
  do
    if [ $i != "ManagedCompartmentForPaaS" ]; then
      echo PROCESSING COMPARTMENT $i ...
      mkdir -p $i
      cd $i
      terraform-provider-oci -parallelism=$TERRAFORM_PROVIDER_OCI_PARALLELISM -command=export -services=$TERRAFORM_PROVIDER_OCI_SERVICES -compartment_name=$i -generate_state=true -output_path=.
      if [ -f terraform.tfstate ]; then 
        cd - > /dev/null
      else
        cd - > /dev/null
        rm -rf $i
      fi
      echo DONE PROCESSING COMPARTMENT $i
    else
      echo SKIPPED PROCESSING COMPARTMENT $i
    fi
  done

# otherwise, loop the arguments given (compartment names separated by space):
else

  for i in "$@"
  do
    if [ $i != "ManagedCompartmentForPaaS" ]; then
      if  [[ $i == ocid1.* ]] ;
      then
        echo PROCESSING COMPARTMENT WITH OCID $i ...
        mkdir -p $i
        cd $i
        terraform-provider-oci -parallelism=$TERRAFORM_PROVIDER_OCI_PARALLELISM -command=export -services=$TERRAFORM_PROVIDER_OCI_SERVICES -compartment_id=$i -generate_state=true -output_path=.
        if [ -f terraform.tfstate ]; then 
          cd - > /dev/null
        else
          cd - > /dev/null
          rm -rf $i
        fi
      else
        echo PROCESSING COMPARTMENT $i ...
        mkdir -p $i
        cd $i
        terraform-provider-oci -parallelism=$TERRAFORM_PROVIDER_OCI_PARALLELISM -command=export -services=$TERRAFORM_PROVIDER_OCI_SERVICES -compartment_name=$i -generate_state=true -output_path=.
        if [ -f terraform.tfstate ]; then 
          cd - > /dev/null
        else
          cd - > /dev/null
          rm -rf $i
        fi
      fi

      if  [[ $i == ocid1.* ]] ;
      then
        echo DONE PROCESSING COMPARTMENT WITH OCID $i
      else
        echo DONE PROCESSING COMPARTMENT $i
      fi
    else
      if  [[ $i == ocid1.* ]] ;
      then
        echo SKIPPED PROCESSING COMPARTMENT WITH OCID $i
      else
        echo SKIPPED PROCESSING COMPARTMENT $i
      fi
    fi
  done  
fi
