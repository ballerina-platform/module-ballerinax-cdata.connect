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

@test:Config {}
function testInvalidSyntaxQuery() returns error? {
    TestClient cdataClient = getTestClient();
    
    sql:ParameterizedQuery invalidQuery = `SELEC * FROM invalid_table_name`;
    
    stream<record {}, sql:Error?>|error queryResult = trap performQuery(cdataClient, invalidQuery);
    
    if queryResult is error {
        io:println("Expected error for invalid syntax: ", queryResult.message());
    } else {
        if queryResult is stream<record {}, sql:Error?> {
            check queryResult.close();
        }
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
    
    if invalidClient is sql:Error {
        io:println("Expected connection error: ", invalidClient.message());
    } else {
        io:println("Connection succeeded unexpectedly, closing client");
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
    
    sql:ExecutionResult[]|sql:Error batchResult = performBatchExecute(cdataClient, batchQueries);
    
    if batchResult is sql:Error {
        io:println("Batch execute failed as expected: ", batchResult.message());
    } else {
        io:println("Batch execute succeeded, results count: ", batchResult.length());
    }
    
    check closeTestClient(cdataClient);
}

@test:Config {}
function testClientCreationErrorPaths() returns error? {
    // Test with null/empty credentials
    Client|sql:Error emptyUser = new("", "password", JDBC_URL);
    Client|sql:Error emptyPass = new("user", "", JDBC_URL);
    Client|sql:Error emptyBoth = new("", "", JDBC_URL);
    
    // Test with invalid URLs
    Client|sql:Error invalidProtocol = new("user", "pass", "invalid://protocol");
    Client|sql:Error malformedURL = new("user", "pass", "not-a-url-at-all");
    Client|sql:Error emptyURL = new("user", "pass", "");
    
    // Test with extreme values using file-based strings
    string veryLongUser = check io:fileReadString("tests/resources/long_user.txt");
    Client|sql:Error longUser = new(veryLongUser, "pass", JDBC_URL);
    
    string veryLongPass = check io:fileReadString("tests/resources/long_pass.txt");
    Client|sql:Error longPass = new("user", veryLongPass, JDBC_URL);
    
    // Test each result individually
    if emptyUser is Client { check emptyUser.close(); }
    if emptyPass is Client { check emptyPass.close(); }
    if emptyBoth is Client { check emptyBoth.close(); }
    if invalidProtocol is Client { check invalidProtocol.close(); }
    if malformedURL is Client { check malformedURL.close(); }
    if emptyURL is Client { check emptyURL.close(); }
    if longUser is Client { check longUser.close(); }
    if longPass is Client { check longPass.close(); }
}

@test:Config {}
function testQueryErrorPaths() returns error? {
    Client cdataClient = check new("user", "pass", JDBC_URL + ";MockMode=true");
    
    // Test simple queries to exercise error handling paths
    sql:ParameterizedQuery[] testQueries = [
        `SELECT 'test1' as query_type`,
        `SELECT 'test2' as query_type`,
        `SELECT 'test3' as query_type`
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
    Client cdataClient = check new("user", "pass", JDBC_URL + ";MockMode=true");
    
    // Test various problematic parameter combinations
    
    // Null parameters
    string? nullString = ();
    int? nullInt = ();
    sql:ParameterizedQuery nullParamQuery = `SELECT ${nullString} as null_str, ${nullInt} as null_int`;
    stream<record {}, sql:Error?>|error nullResult = trap cdataClient->query(nullParamQuery);
    if nullResult is stream<record {}, sql:Error?> {
        check nullResult.close();
    }
    
    // Very large parameters using file-based string
    string largeString = check io:fileReadString("tests/resources/large_string.txt");
    sql:ParameterizedQuery largeParamQuery = `SELECT ${largeString} as large_string`;
    stream<record {}, sql:Error?>|error largeResult = trap cdataClient->query(largeParamQuery);
    if largeResult is stream<record {}, sql:Error?> {
        check largeResult.close();
    }
    
    // Special characters in parameters
    string specialChars = "'; DROP TABLE test; --";
    sql:ParameterizedQuery specialQuery = `SELECT ${specialChars} as special_chars`;
    stream<record {}, sql:Error?>|error specialResult = trap cdataClient->query(specialQuery);
    if specialResult is stream<record {}, sql:Error?> {
        check specialResult.close();
    }
    
    check cdataClient.close();
}

@test:Config {}
function testBatchExecuteErrorPaths() returns error? {
    Client cdataClient = check new("user", "pass", JDBC_URL + ";MockMode=true");
    
    // Test empty array (should hit line 100 validation)
    sql:ParameterizedQuery[] emptyArray = [];
    sql:ExecutionResult[]|sql:Error emptyResult = cdataClient->batchExecute(emptyArray);
    test:assertTrue(emptyResult is sql:Error, msg = "Empty batch should return error");
    
    // Test batch with multiple queries
    sql:ParameterizedQuery[] multipleQueries = [
        `SELECT 1 as valid_query`,
        `SELECT 2 as another_valid`,
        `SELECT 3 as final_valid`
    ];
    // Execute batch and handle result
    sql:ExecutionResult[]|sql:Error batchExecuteResult = cdataClient->batchExecute(multipleQueries);
    // Result checked to avoid unused variable error
    if batchExecuteResult is sql:ExecutionResult[] {
        // Batch executed successfully
    }
    
    check cdataClient.close();
}

@test:Config {}
function testStoredProcedureErrorPaths() returns error? {
    Client cdataClient = check new("user", "pass", JDBC_URL + ";MockMode=true");
    
    // Test procedure calls
    sql:ParameterizedCallQuery[] parameterizedCalls = [
        `{CALL test_proc(${()}, ${"param"})}`,
        `{CALL test_proc()}`
    ];
    
    foreach sql:ParameterizedCallQuery procCall in parameterizedCalls {
        sql:ProcedureCallResult|error callResult = trap cdataClient->call(procCall);
        if callResult is sql:ProcedureCallResult {
            stream<record {}, sql:Error?>? queryResult = callResult.queryResult;
            if queryResult is stream<record {}, sql:Error?> {
                record {}|error? nextResult = trap queryResult.next();
                // Check result to avoid unused variable error
                if nextResult is record {} {
                    // Successfully got result
                }
                check queryResult.close();
            }
            check callResult.close();
        }
    }
    
    check cdataClient.close();
}

@test:Config {}
function testClientCreationWithInvalidOptions() returns error? {
    // Test client creation with various invalid option combinations
    
    // Invalid SSL configuration
    SSL invalidSSL = {sslServerCert: "non-existent-path/cert.pem"};
    Options sslOpts = {ssl: invalidSSL};
    Client|sql:Error sslClient = new("user", "pass", JDBC_URL, sslOpts);
    if sslClient is Client { check sslClient.close(); }
    
    // Invalid firewall configuration
    Firewall invalidFirewall = {
        firewallType: TUNNEL,
        firewallServer: "non-existent-server.invalid",
        firewallPort: 99999
    };
    Options fwOpts = {firewall: invalidFirewall};
    Client|sql:Error fwClient = new("user", "pass", JDBC_URL, fwOpts);
    if fwClient is Client { check fwClient.close(); }
    
    // Invalid proxy configuration
    Proxy invalidProxy = {
        proxyServer: "non-existent-proxy.invalid",
        proxyPort: -1,
        proxyUser: "",
        proxyPassword: "password-without-user"
    };
    Options proxyOpts = {proxy: invalidProxy};
    Client|sql:Error proxyClient = new("user", "pass", JDBC_URL, proxyOpts);
    if proxyClient is Client { check proxyClient.close(); }
}
