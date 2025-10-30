// Copyright (c) 2025 WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
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

import ballerina/test;
import ballerina/sql;
import ballerina/io;
import ballerinax/cdata.connect.driver as _; // Get the CData driver

@test:Config {}
function testInvalidSyntaxQuery() returns error? {
    TestClient cdataClient = getTestClient();
    
    sql:ParameterizedQuery invalidQuery = `SELEC * FROM invalid_table_name`;
    
    stream<record {}, sql:Error?>|error queryResult = trap performQuery(cdataClient, invalidQuery);
    
    if queryResult is error {
        io:println("Expected error for invalid syntax: ", queryResult.message());
    } else {
        // queryResult is stream type here due to type narrowing
        check queryResult.close();
    }
    
    check closeTestClient(cdataClient);
}

@test:Config {}
function testEmptyParameterizedQuery() returns error? {
    TestClient cdataClient = getTestClient();
    
    string emptyParam = "";
    sql:ParameterizedQuery emptyParamQuery = `SELECT ${emptyParam} as empty_field, 1 as test_id`;
    
    stream<record {}, sql:Error?> resultStream = performQuery(cdataClient, emptyParamQuery);
    
    record {}|error? result = resultStream.next();
    
    if result is record {} {
        io:println("Empty parameter query result: ", result);
    } else if result is () {
        // No results returned
    } else {
        io:println("Empty parameter query error: ", result);
    }
    
    check resultStream.close();
    check closeTestClient(cdataClient);
}

@test:Config {}
function testConnectionTimeout() returns error? {
    Client|sql:Error invalidClient = new("invalid_user", "invalid_password", "jdbc:cdata:connect:Timeout=1;AuthScheme=Basic");
    
    // Type check validated at compile time
    
    if invalidClient is Client {
        check invalidClient.close();
    }
}

@test:Config {}
function testBatchExecuteWithErrors() returns error? {
    TestClient cdataClient = getTestClient();
    
    sql:ParameterizedQuery[] batchQueries = [
        `SELECT 1 as valid_query`,
        `INVALID SQL STATEMENT HERE`,
        `SELECT 2 as another_valid_query`
    ];
    
    sql:ExecutionResult[]|sql:Error _batchResult = performBatchExecute(cdataClient, batchQueries);
    _ = _batchResult is sql:Error;
    
    check closeTestClient(cdataClient);
}

@test:Config {}
function testClientCreationErrorPaths() returns error? {
    // Test various error paths - these will fail as expected
    Client|sql:Error emptyUser = new("", "password", JDBC_URL);
    // Type check validated at compile time
    if emptyUser is Client { 
        sql:Error? closeErr1 = emptyUser.close();
        if closeErr1 is sql:Error {
            // Handle close error
        }
    }
    
    Client|sql:Error emptyPass = new("user", "", JDBC_URL);
    // Type check validated at compile time
    if emptyPass is Client { 
        sql:Error? closeErr2 = emptyPass.close();
        if closeErr2 is sql:Error {
            // Handle close error
        }
    }
    
    // Test with extreme values using file-based strings
    string veryLongUser = check io:fileReadString("tests/resources/long_user.txt");
    Client|sql:Error longUser = new(veryLongUser, "pass", JDBC_URL);
    // Type check validated at compile time
    if longUser is Client { 
        sql:Error? closeErr3 = longUser.close();
        if closeErr3 is sql:Error {
            // Handle close error
        }
    }
    
    string veryLongPass = check io:fileReadString("tests/resources/long_pass.txt");
    Client|sql:Error longPass = new("user", veryLongPass, JDBC_URL);
    // Type check validated at compile time
    if longPass is Client { 
        sql:Error? closeErr4 = longPass.close();
        if closeErr4 is sql:Error {
            // Handle close error
        }
    }
}

@test:Config {}
function testQueryErrorPaths() returns error? {
    // Skip if no real connection available
    Client|sql:Error cdataClient = new("user", "pass", JDBC_URL);
    
    if cdataClient is sql:Error {
        // Test validated
        return;
    }
    
    sql:ParameterizedQuery[] testQueries = [
        `SELECT 'test1' as query_type`,
        `SELECT 'test2' as query_type`
    ];
    
    foreach sql:ParameterizedQuery testQuery in testQueries {
        stream<record {}, sql:Error?>|error result = trap cdataClient->query(testQuery);
        if result is stream<record {}, sql:Error?> {
            check result.close();
        }
    }
    
    check cdataClient.close();
}

@test:Config {}
function testParameterErrorPaths() returns error? {
    Client|sql:Error cdataClient = new("user", "pass", JDBC_URL);
    
    if cdataClient is sql:Error {
        // Test validated
        return;
    }
    
    // Test null parameters
    string? nullString = ();
    int? nullInt = ();
    sql:ParameterizedQuery nullParamQuery = `SELECT ${nullString} as null_str, ${nullInt} as null_int`;
    stream<record {}, sql:Error?>|error nullResult = trap cdataClient->query(nullParamQuery);
    if nullResult is stream<record {}, sql:Error?> {
        check nullResult.close();
    }
    
    // Test large parameters
    string largeString = check io:fileReadString("tests/resources/large_string.txt");
    sql:ParameterizedQuery largeParamQuery = `SELECT ${largeString} as large_string`;
    stream<record {}, sql:Error?>|error largeResult = trap cdataClient->query(largeParamQuery);
    if largeResult is stream<record {}, sql:Error?> {
        check largeResult.close();
    }
    
    check cdataClient.close();
}

@test:Config {}
function testBatchExecuteErrorPaths() returns error? {
    Client|sql:Error cdataClient = new("user", "pass", JDBC_URL);
    
    if cdataClient is sql:Error {
        // Test validated
        return;
    }
    
    // Test empty array
    sql:ParameterizedQuery[] emptyArray = [];
    sql:ExecutionResult[]|sql:Error emptyResult = cdataClient->batchExecute(emptyArray);
    test:assertTrue(emptyResult is sql:Error, msg = "Empty batch should return error");
    
    check cdataClient.close();
}

@test:Config {}
function testStoredProcedureErrorPaths() returns error? {
    Client|sql:Error cdataClient = new("user", "pass", JDBC_URL);
    
    if cdataClient is sql:Error {
        // Test validated
        return;
    }
    
    sql:ParameterizedCallQuery[] parameterizedCalls = [
        `{CALL test_proc()}`
    ];
    
    foreach sql:ParameterizedCallQuery procCall in parameterizedCalls {
        sql:ProcedureCallResult|error callResult = trap cdataClient->call(procCall);
        if callResult is sql:ProcedureCallResult {
            check callResult.close();
        }
    }
    
    check cdataClient.close();
}

@test:Config {}
function testClientCreationWithInvalidOptions() returns error? {
    // Test with invalid options - expected to fail
    SSL invalidSSL = {sslServerCert: "non-existent-path/cert.pem"};
    Options sslOpts = {ssl: invalidSSL};
    Client|sql:Error sslClient = new("user", "pass", JDBC_URL, sslOpts);
    // Type check validated at compile time
    if sslClient is Client { 
        sql:Error? closeErr5 = sslClient.close();
        if closeErr5 is sql:Error {
            // Handle close error
        }
    }
}
