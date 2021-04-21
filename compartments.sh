#!/bin/bash
node /oci-harvester/compartments.js | jq '.[].value | .name + " (" + .description + ") OCID: " + .id'
