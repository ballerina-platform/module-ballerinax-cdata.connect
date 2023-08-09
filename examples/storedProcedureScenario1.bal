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
// KIND, either express or implied.  See the License for the
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

    // Stored Procedures
    
    sql:ParameterizedCallQuery sqlQuery = `{CALL Salesforce1.Salesforce.GetUserInformation()}`;
    sql:ProcedureCallResult retCall = check cdataClient->call(sqlQuery);
    io:println("Call stored procedure `GetUserInformation`.");

    stream<record {}, sql:Error?>? result = retCall.queryResult;
    if result is stream<record {}, sql:Error?> {
        stream<record {}, sql:Error?> informationStream = <stream<record {}, sql:Error?>>result;
        check from record {} information in informationStream
            do {
                io:println("User details: ", information);
            };
    }

    check retCall.close();
    
}
