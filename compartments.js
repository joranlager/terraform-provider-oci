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

    // Create a request and dependent object(s).
    const listCompartmentsRequest = identity.requests.ListCompartmentsRequest = {
      compartmentId: tenancyId.tenancyId,
      limit: 42,
      accessLevel: identity.requests.ListCompartmentsRequest.AccessLevel.Any,
      compartmentIdInSubtree: true,
      sortBy: identity.requests.ListCompartmentsRequest.SortBy.Timecreated,
      sortOrder: identity.requests.ListCompartmentsRequest.SortOrder.Asc,
      //lifecycleState: identity.models.Compartment.LifecycleState.Deleted
      lifecycleState: identity.models.Compartment.LifecycleState.Active
    };

  // Create a service client
    const client = new identity.IdentityClient({ authenticationDetailsProvider: provider });

    // Create a request and dependent object(s).
    const getTenancyRequest = identity.requests.GetTenancyRequest = {
      tenancyId: tenancyId.tenancyId
    };

    // Send request to the Client.
    const getTenancyResponse = await client.getTenancy(getTenancyRequest);

    var rootCompartment = {value: {
        compartmentId: getTenancyResponse.tenancy.compartmentId,
        id: tenancyId.tenancyId,
        name: getTenancyResponse.tenancy.name,
        description: getTenancyResponse.tenancy.description,
        freeformTags: getTenancyResponse.tenancy.freeformTags,
        definedTags: getTenancyResponse.tenancy.definedTags,
        lifecycleState: getTenancyResponse.tenancy.lifecycleState
      }
    }

    // Eager load: https://github.com/oracle/oci-typescript-sdk/blob/master/examples/javascript/pagination.js
    const listCompartmentsResponse = await common.paginatedRecordsWithLimit(listCompartmentsRequest, req =>
      client.listCompartments(listCompartmentsRequest)
    );

    listCompartmentsResponse.push(rootCompartment)

    console.log(JSON.stringify(listCompartmentsResponse, null, 2));

  } catch (error) {
    console.log("listCompartments Failed with error  " + error);
  }
})();
