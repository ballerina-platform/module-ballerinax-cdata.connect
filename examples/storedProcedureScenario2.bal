// Copyright (c) 2022 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/sql;
import ballerinax/cdata.connect as cdata;  // Get the CData connector
import ballerinax/cdata.connect.driver as _;       // Get the CData driver

// Connection Configurations
configurable string user = ?;
configurable string password = ?;

// Initialize the CData client
cdata:Client cdataClient = check new (user, password);

public function main() returns error? {
    check getUserInformation();
    check queryAndConvertLead();
}

function getUserInformation() returns error? {
    io:println("Call stored procedure `GetUserInformation`.");
    sql:ParameterizedCallQuery getUserInfoQuery = `{EXEC Salesforce1.Salesforce.GetUserInformation}`;
    sql:ProcedureCallResult userInfoCall = check cdataClient->call(getUserInfoQuery);
    stream<record {}, sql:Error?>? userResult = userInfoCall.queryResult;

    if userResult is stream<record {}, sql:Error?> {
        check from record {} info in userResult do {
            io:println("User details: ", info);
        };
    }
    check userInfoCall.close();
}

function queryAndConvertLead() returns error? {
    io:println("\n=== Querying for available leads ===");

    // Query for leads that can be converted - using proper catalog.schema.table format
    sql:ParameterizedQuery leadQuery = `SELECT Id, FirstName, LastName, Company, Status, IsConverted FROM Salesforce1.Salesforce.Lead WHERE IsConverted = false LIMIT 5`;
    stream<record {}, sql:Error?> leadStream = cdataClient->query(leadQuery);

    string? availableLeadId = ();
    check from record {} lead in leadStream do {
        io:println("Available Lead: ", lead);
        if availableLeadId is () && lead["Id"] is string {
            availableLeadId = <string>lead["Id"];
        }
    };
    check leadStream.close();

    if availableLeadId is string {
        check convertLead(availableLeadId);
    } else {
        io:println("No convertible leads found in the system.");
    }
}

function convertLead(string leadId) returns error? {
    io:println("\n=== Converting Lead: ", leadId, " ===");
    string convertedStatus = "Closed - Converted";

    // Use the working method - query instead of call for stored procedure execution
    sql:ParameterizedQuery convertLeadQuery = `EXEC Salesforce1.Salesforce.ConvertLead leadId = ${leadId}, convertedStatus = ${convertedStatus}`;
    stream<record {}, sql:Error?> result = cdataClient->query(convertLeadQuery);
    io:println("Call stored procedure `ConvertLead` executed successfully.");

    check from record {} information in result do {
        io:println("Converted Lead details: ", information);
    };
    check result.close();
}
