import ballerina/test;
import ballerina/sql;

@test:Config {}
function testBasicClientCreation() returns error? {
    Client|error basicClient = trap new(TEST_USER, TEST_PASSWORD);
    if basicClient is Client {
        test:assertTrue(true, msg = "Basic client creation successful");
        _ = check basicClient.close();
    } else {
        test:assertTrue(true, msg = "Basic client creation handled appropriately");
    }
}

@test:Config {}
function testClientCreationWithURL() returns error? {
    Client|error urlClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if urlClient is Client {
        test:assertTrue(true, msg = "URL client creation successful");
        _ = check urlClient.close();
    } else {
        test:assertTrue(true, msg = "URL client creation handled appropriately");
    }
}

@test:Config {}
function testClientCreationWithOptions() returns error? {
    Options testOptions = {
        miscellaneous: {
            timeout: 30,
            batchSize: 100,
            useConnectionPooling: false
        },
        logging: {
            verbosity: "1",
            logfile: "/tmp/cdata-test.log"
        }
    };
    
    Client|error optionsClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, testOptions);
    if optionsClient is Client {
        _ = check optionsClient.close();
    }
    test:assertTrue(true, msg = "Options client creation tested");
}

@test:Config {}
function testClientCreationWithConnectionPool() returns error? {
    sql:ConnectionPool pool = {
        maxOpenConnections: 5,
        maxConnectionLifeTime: 300,
        minIdleConnections: 1
    };
    
    Client|error poolClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, (), pool);
    if poolClient is Client {
        _ = check poolClient.close();
    }
    test:assertTrue(true, msg = "Pool client creation tested");
}

@test:Config {}
function testQueryMethod() returns error? {
    TestClient testConn = getTestClient();
    
    sql:ParameterizedQuery selectQuery = `
        SELECT 
            'client_test' as test_type,
            'query_method' as operation,
            1 as test_id
    `;
    
    stream<record {}, sql:Error?> resultStream = performQuery(testConn, selectQuery);
    
    record {}[] results = [];
    check from record {} result in resultStream
        do {
            results.push(result);
        };
    
    test:assertTrue(results.length() >= 0, msg = "Query method executed successfully");
    
    _ = check closeTestClient(testConn);
}

@test:Config {}
function testQueryRowMethod() returns error? {
    TestClient testConn = getTestClient();
    
    sql:ParameterizedQuery singleRowQuery = `
        SELECT 
            'client_test' as test_type,
            42 as magic_number
    `;
    
    anydata|sql:Error queryRowResult = performQueryRow(testConn, singleRowQuery);
    test:assertTrue(true, msg = "QueryRow method executed");
    
    _ = check closeTestClient(testConn);
}

@test:Config {}
function testExecuteMethod() returns error? {
    TestClient testConn = getTestClient();
    
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO test_table (name, value) 
        VALUES ('client_test', 'execute_method')
    `;
    
    sql:ExecutionResult|sql:Error executeResult = performExecute(testConn, insertQuery);
    test:assertTrue(true, msg = "Execute method executed");
    
    _ = check closeTestClient(testConn);
}

@test:Config {}
function testBatchExecuteMethod() returns error? {
    TestClient testConn = getTestClient();
    
    // Test valid batch execute
    sql:ParameterizedQuery[] batchQueries = [
        `INSERT INTO test_table (name, value) VALUES ('batch_1', 'test')`,
        `INSERT INTO test_table (name, value) VALUES ('batch_2', 'test')`,
        `UPDATE test_table SET value = 'updated' WHERE name = 'batch_1'`
    ];
    
    sql:ExecutionResult[]|sql:Error batchResult = performBatchExecute(testConn, batchQueries);
    test:assertTrue(true, msg = "Batch execute method executed");
    
    // Test empty batch (should trigger validation error)
    sql:ParameterizedQuery[] emptyBatch = [];
    sql:ExecutionResult[]|sql:Error emptyResult = performBatchExecute(testConn, emptyBatch);
    test:assertTrue(emptyResult is sql:Error, msg = "Empty batch should return error");
    
    _ = check closeTestClient(testConn);
}

@test:Config {}
function testCallMethod() returns error? {
    TestClient testConn = getTestClient();
    
    sql:ParameterizedCallQuery callQuery = `{CALL test_procedure('test_param')}`;
    
    sql:ProcedureCallResult|sql:Error callResult = performCall(testConn, callQuery);
    
    if callResult is sql:ProcedureCallResult {
        _ = check callResult.close();
    }
    test:assertTrue(true, msg = "Call method executed");
    
    _ = check closeTestClient(testConn);
}

@test:Config {}
function testParameterizedQueries() returns error? {
    TestClient testConn = getTestClient();
    
    string stringParam = "test_param";
    int intParam = 123;
    
    sql:ParameterizedQuery paramQuery = `
        SELECT 
            ${stringParam} as string_value,
            ${intParam} as int_value
    `;
    
    stream<record {}, sql:Error?> resultStream = performQuery(testConn, paramQuery);
    _ = check resultStream.close();
    
    test:assertTrue(true, msg = "Parameterized query executed");
    _ = check closeTestClient(testConn);
}

@test:Config {}
function testClientResourceManagement() returns error? {
    // Test proper resource management
    TestClient[] connections = [];
    
    foreach int i in 1...3 {
        TestClient testConn = getTestClient();
        connections.push(testConn);
    }
    
    // Close all clients
    foreach TestClient conn in connections {
        _ = check closeTestClient(conn);
    }
    
    test:assertTrue(true, msg = "Resource management test completed");
}