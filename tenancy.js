/**
 * Copyright (c) 2020, 2022 Oracle and/or its affiliates.  All rights reserved.
 * This software is dual-licensed to you under the Universal Permissive License (UPL) 1.0 as shown at https://oss.oracle.com/licenses/upl or Apache License 2.0 as shown at http://www.apache.org/licenses/LICENSE-2.0. You may choose either license.
 */

//https://docs.oracle.com/en-us/iaas/tools/typescript/1.15.0/globals.html
const common = require("oci-common");
const identity = require("oci-identity");

const provider = new common.ConfigFileAuthenticationDetailsProvider();

const tenancyId = {
  tenancyId: provider.getTenantId() || ""
};

(async () => {
  try {

  // Create a service client
    const client = new identity.IdentityClient({ authenticationDetailsProvider: provider });

    // Create a request and dependent object(s).
    const getTenancyRequest = identity.requests.GetTenancyRequest = {
      tenancyId: tenancyId.tenancyId
    };

    // Send request to the Client.
    const getTenancyResponse = await client.getTenancy(getTenancyRequest);

    console.log(JSON.stringify(getTenancyResponse, null, 2));

  } catch (error) {
    console.log("getTenancy Failed with error  " + error);
  }
})();
