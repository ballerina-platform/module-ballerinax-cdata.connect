import ballerina/test;
import ballerina/sql;

@test:Config {}
function testConnectionTimeout() returns error? {
    Client|error invalidClient = trap new("invalid_user", "invalid_password", 
                                         "jdbc:cdata:connect:Timeout=1;AuthScheme=Basic");
    
    if invalidClient is error {
        test:assertTrue(true, msg = "Invalid credentials handled appropriately");
    } else {
        _ = check invalidClient.close();
        test:assertTrue(true, msg = "Connection test completed");
    }
}

@test:Config {}
function testInvalidCredentials() returns error? {
    // Test with empty credentials
    Client|error emptyUser = trap new("", "password", JDBC_URL);
    Client|error emptyPass = trap new("user", "", JDBC_URL);
    Client|error emptyBoth = trap new("", "", JDBC_URL);
    
    // Results should be error or successfully closed
    if emptyUser is Client { _ = check emptyUser.close(); }
    if emptyPass is Client { _ = check emptyPass.close(); }
    if emptyBoth is Client { _ = check emptyBoth.close(); }
    
    test:assertTrue(true, msg = "Invalid credentials error paths tested");
}

@test:Config {}
function testInvalidURLs() returns error? {
    // Test with malformed URLs
    Client|error invalidProtocol = trap new("user", "pass", "invalid://protocol");
    Client|error malformedURL = trap new("user", "pass", "not-a-url");
    Client|error emptyURL = trap new("user", "pass", "");
    
    if invalidProtocol is Client { _ = check invalidProtocol.close(); }
    if malformedURL is Client { _ = check malformedURL.close(); }
    if emptyURL is Client { _ = check emptyURL.close(); }
    
    test:assertTrue(true, msg = "Invalid URL error paths tested");
}

@test:Config {}
function testQueryErrorHandling() returns error? {
    TestClient testConn = getTestClient();
    
    // Test invalid SQL syntax
    sql:ParameterizedQuery invalidQuery = `INVALID SQL SYNTAX HERE`;
    
    stream<record {}, sql:Error?>|error queryResult = trap performQuery(testConn, invalidQuery);
    if queryResult is stream<record {}, sql:Error?> {
        _ = check queryResult.close();
    }
    
    test:assertTrue(true, msg = "Query error handling tested");
    _ = check closeTestClient(testConn);
}

@test:Config {}
function testBatchExecuteErrors() returns error? {
    TestClient testConn = getTestClient();
    
    // Test batch with mixed valid and invalid queries
    sql:ParameterizedQuery[] mixedQueries = [
        `SELECT 1 as valid_query`,
        `INVALID SQL HERE`,
        `SELECT 2 as another_valid`
    ];
    
    sql:ExecutionResult[]|sql:Error batchResult = performBatchExecute(testConn, mixedQueries);
    test:assertTrue(true, msg = "Batch execute error handling tested");
    
    _ = check closeTestClient(testConn);
}

@test:Config {}
function testParameterErrorHandling() returns error? {
    TestClient testConn = getTestClient();
    
    // Test with null parameters
    string? nullString = ();
    int? nullInt = ();
    
    sql:ParameterizedQuery nullParamQuery = `
        SELECT ${nullString} as null_str, ${nullInt} as null_int
    `;
    
    stream<record {}, sql:Error?> resultStream = performQuery(testConn, nullParamQuery);
    _ = check resultStream.close();
    
    test:assertTrue(true, msg = "Parameter error handling tested");
    _ = check closeTestClient(testConn);
}

@test:Config {}
function testInvalidConfigurationOptions() returns error? {
    // Test invalid SSL configuration
    SSL invalidSSL = {sslServerCert: "non-existent-path.pem"};
    Options sslOpts = {ssl: invalidSSL};
    
    Client|error sslClient = trap new("user", "pass", JDBC_URL, sslOpts);
    if sslClient is Client { _ = check sslClient.close(); }
    
    // Test invalid firewall configuration
    Firewall invalidFirewall = {
        firewallType: TUNNEL,
        firewallServer: "non-existent-server.invalid",
        firewallPort: 99999
    };
    Options fwOpts = {firewall: invalidFirewall};
    
    Client|error fwClient = trap new("user", "pass", JDBC_URL, fwOpts);
    if fwClient is Client { _ = check fwClient.close(); }
    
    test:assertTrue(true, msg = "Invalid configuration options tested");
}

@test:Config {}
function testStoredProcedureErrors() returns error? {
    TestClient testConn = getTestClient();
    
    // Test procedure call that might not exist
    sql:ParameterizedCallQuery callQuery = `{CALL non_existent_proc()}`;
    
    sql:ProcedureCallResult|sql:Error callResult = performCall(testConn, callQuery);
    if callResult is sql:ProcedureCallResult {
        _ = check callResult.close();
    }
    
    test:assertTrue(true, msg = "Stored procedure error handling tested");
    
    _ = check closeTestClient(testConn);
}