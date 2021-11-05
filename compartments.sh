#!/bin/bash
node /terraform-provider-oci/compartments.js | jq '.[].value | .name + " (" + .description + ") OCID: " + .id'
