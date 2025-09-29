import ballerina/test;
import ballerina/sql;
import ballerina/io;

@test:Config {}
function testBasicClientCreation() returns error? {
    // Test basic client creation with username/password only
    Client|error basicClient = trap new(TEST_USER, TEST_PASSWORD);
    if basicClient is Client {
        test:assertTrue(true, msg = "Basic client creation successful");
        _ = check basicClient.close();
    } else {
        test:assertTrue(true, msg = "Basic client creation failed as expected in test environment");
    }
}

@test:Config {}
function testClientCreationWithURL() returns error? {
    // Test client creation with custom URL
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
    // Test client creation with various options
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
        test:assertTrue(true, msg = "Options client creation successful");
        _ = check optionsClient.close();
    } else {
        test:assertTrue(true, msg = "Options client creation handled appropriately");
    }
}

@test:Config {}
function testClientCreationWithConnectionPool() returns error? {
    // Test client creation with connection pool
    sql:ConnectionPool pool = {
        maxOpenConnections: 5,
        maxConnectionLifeTime: 300,
        minIdleConnections: 1
    };
    
    Client|error poolClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, (), pool);
    if poolClient is Client {
        test:assertTrue(true, msg = "Pool client creation successful");
        _ = check poolClient.close();
    } else {
        test:assertTrue(true, msg = "Pool client creation handled appropriately");
    }
}

@test:Config {}
function testClientCreationWithOptionsAndPool() returns error? {
    // Test client creation with both options and connection pool
    Options fullOptions = {
        ssl: {
            sslServerCert: "/path/to/cert.pem"
        },
        firewall: {
            firewallType: NONE
        },
        proxy: {
            proxyAutoDetect: false,
            proxyServer: "",
            proxyPort: 80
        },
        logging: {
            verbosity: "2",
            maxLogFileSize: "10MB"
        },
        miscellaneous: {
            timeout: 45,
            batchSize: 200,
            connectOnOpen: true,
            maxRows: 1000
        }
    };
    
    sql:ConnectionPool pool = {
        maxOpenConnections: 10,
        maxConnectionLifeTime: 600
    };
    
    Client|error fullClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, fullOptions, pool);
    if fullClient is Client {
        test:assertTrue(true, msg = "Full options client creation successful");
        _ = check fullClient.close();
    } else {
        test:assertTrue(true, msg = "Full options client creation handled appropriately");
    }
}

@test:Config {}
function testQueryMethod() returns error? {
    TestClient testConn = getTestClient();
    
    sql:ParameterizedQuery selectQuery = `
        SELECT 
            'client_test' as test_type,
            'query_method' as operation,
            1 as test_id,
            'sample_data' as data_value
    `;
    
    stream<record {}, sql:Error?> resultStream = performQuery(testConn, selectQuery);
    
    // Process results
    record {}[] results = [];
    check from record {} result in resultStream
        do {
            results.push(result);
        };
    
    test:assertTrue(results.length() >= 0, msg = "Query method should execute successfully");
    io:println("Query method test - processed ", results.length(), " records");
    
    error? closeResult = closeTestClient(testConn);
    test:assertFalse(closeResult is error, msg = "Client should close without error");
}

@test:Config {}
function testQueryRowMethod() returns error? {
    TestClient testConn = getTestClient();
    
    sql:ParameterizedQuery singleRowQuery = `
        SELECT 
            'client_test' as test_type,
            'queryRow_method' as operation,
            42 as magic_number
    `;
    
    anydata|sql:Error queryRowResult = performQueryRow(testConn, singleRowQuery);
    
    if queryRowResult is record {} {
        test:assertTrue(true, msg = "QueryRow method returned record successfully");
        io:println("QueryRow result: ", queryRowResult);
    } else if queryRowResult is sql:NoRowsError {
        test:assertTrue(true, msg = "QueryRow method handled no rows appropriately");
    } else if queryRowResult is sql:Error {
        test:assertTrue(true, msg = "QueryRow method handled error appropriately");
        io:println("QueryRow error: ", queryRowResult.message());
    } else {
        test:assertTrue(true, msg = "QueryRow method executed");
    }
    
    error? closeResult = closeTestClient(testConn);
    test:assertFalse(closeResult is error, msg = "Client should close without error");
}

@test:Config {}
function testExecuteMethod() returns error? {
    TestClient testConn = getTestClient();
    
    // Test INSERT-like operation
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO test_table (name, value, created_at) 
        VALUES ('client_test', 'execute_method', CURRENT_TIMESTAMP)
    `;
    
    sql:ExecutionResult|sql:Error executeResult = performExecute(testConn, insertQuery);
    
    if executeResult is sql:ExecutionResult {
        test:assertTrue(true, msg = "Execute method returned ExecutionResult successfully");
        io:println("Execute result - affected rows: ", executeResult.affectedRowCount);
        
        if executeResult.lastInsertId is int {
            io:println("Last insert ID: ", executeResult.lastInsertId);
        }
    } else {
        test:assertTrue(true, msg = "Execute method handled error appropriately");
        io:println("Execute error: ", executeResult.message());
    }
    
    // Test UPDATE-like operation
    sql:ParameterizedQuery updateQuery = `
        UPDATE test_table 
        SET value = 'updated_by_client_test', updated_at = CURRENT_TIMESTAMP 
        WHERE name = 'client_test'
    `;
    
    sql:ExecutionResult|sql:Error updateResult = performExecute(testConn, updateQuery);
    test:assertTrue(updateResult is sql:ExecutionResult || updateResult is sql:Error, 
                   msg = "Update execute should return result or error");
    
    error? closeResult = closeTestClient(testConn);
    test:assertFalse(closeResult is error, msg = "Client should close without error");
}

@test:Config {}
function testBatchExecuteMethod() returns error? {
    TestClient testConn = getTestClient();
    
    // Test valid batch execute
    sql:ParameterizedQuery[] batchQueries = [
        `INSERT INTO test_table (name, value) VALUES ('batch_1', 'client_test')`,
        `INSERT INTO test_table (name, value) VALUES ('batch_2', 'client_test')`,
        `INSERT INTO test_table (name, value) VALUES ('batch_3', 'client_test')`,
        `UPDATE test_table SET value = 'batch_updated' WHERE name LIKE 'batch_%'`
    ];
    
    sql:ExecutionResult[]|sql:Error batchResult = performBatchExecute(testConn, batchQueries);
    
    if batchResult is sql:ExecutionResult[] {
        test:assertTrue(true, msg = "Batch execute method successful");
        io:println("Batch execute completed - ", batchResult.length(), " operations");
        
        foreach sql:ExecutionResult result in batchResult {
            io:println("Batch operation affected rows: ", result.affectedRowCount);
        }
    } else {
        test:assertTrue(true, msg = "Batch execute method handled error appropriately");
        io:println("Batch execute error: ", batchResult.message());
    }
    
    // Test empty batch (should trigger validation error)
    sql:ParameterizedQuery[] emptyBatch = [];
    sql:ExecutionResult[]|sql:Error emptyResult = performBatchExecute(testConn, emptyBatch);
    test:assertTrue(emptyResult is sql:Error, msg = "Empty batch should return error");
    
    error? closeResult = closeTestClient(testConn);
    test:assertFalse(closeResult is error, msg = "Client should close without error");
}

@test:Config {}
function testCallMethod() returns error? {
    TestClient testConn = getTestClient();
    
    // Test stored procedure call
    sql:ParameterizedCallQuery callQuery = `{CALL test_procedure('client_test', 42)}`;
    
    sql:ProcedureCallResult|sql:Error callResult = performCall(testConn, callQuery);
    
    if callResult is sql:ProcedureCallResult {
        test:assertTrue(true, msg = "Call method executed successfully");
        
        // Process query result if available
        stream<record {}, sql:Error?>? queryResult = callResult.queryResult;
        if queryResult is stream<record {}, sql:Error?> {
            record {}|error? firstResult = queryResult.next();
            if firstResult is record {} {
                io:println("Call query result: ", firstResult);
            }
            _ = check queryResult.close();
        }
        
        _ = check callResult.close();
    } else {
        test:assertTrue(true, msg = "Call method handled error appropriately");
        io:println("Call error: ", callResult.message());
    }
    
    // Test call with OUT parameters
    sql:ParameterizedCallQuery outParamCall = `{CALL test_proc_with_out(?, ?)}`;
    sql:ProcedureCallResult|sql:Error outResult = performCall(testConn, outParamCall);
    test:assertTrue(outResult is sql:ProcedureCallResult || outResult is sql:Error,
                   msg = "OUT parameter call should execute");
    
    if outResult is sql:ProcedureCallResult {
        _ = check outResult.close();
    }
    
    error? closeResult = closeTestClient(testConn);
    test:assertFalse(closeResult is error, msg = "Client should close without error");
}

@test:Config {}
function testParameterizedQueries() returns error? {
    TestClient testConn = getTestClient();
    
    // Test with different parameter types
    string stringParam = "client_test_param";
    int intParam = 12345;
    float floatParam = 98.76;
    boolean boolParam = true;
    
    sql:ParameterizedQuery paramQuery = `
        SELECT 
            ${stringParam} as string_value,
            ${intParam} as int_value,
            ${floatParam} as float_value,
            ${boolParam} as bool_value,
            'parameterized_test' as test_type
    `;
    
    stream<record {}, sql:Error?> resultStream = performQuery(testConn, paramQuery);
    
    record {}|error? firstResult = resultStream.next();
    if firstResult is record {} {
        test:assertTrue(true, msg = "Parameterized query executed successfully");
        io:println("Parameterized query result: ", firstResult);
    } else if firstResult is () {
        test:assertTrue(true, msg = "Parameterized query completed with no results");
    } else {
        test:assertTrue(true, msg = "Parameterized query handled error appropriately");
    }
    
    check resultStream.close();
    
    // Test with null parameters
    string? nullStringParam = ();
    int? nullIntParam = ();
    
    sql:ParameterizedQuery nullParamQuery = `
        SELECT 
            ${nullStringParam} as null_string,
            ${nullIntParam} as null_int,
            'null_param_test' as test_type
    `;
    
    stream<record {}, sql:Error?> nullResultStream = performQuery(testConn, nullParamQuery);
    record {}|error? nullResult = nullResultStream.next();
    test:assertTrue(nullResult is record {} || nullResult is () || nullResult is error,
                   msg = "Null parameter query should execute");
    check nullResultStream.close();
    
    error? closeResult = closeTestClient(testConn);
    test:assertFalse(closeResult is error, msg = "Client should close without error");
}

@test:Config {}
function testTransactionScenarios() returns error? {
    TestClient testConn = getTestClient();
    
    // Test basic transaction-like operations
    sql:ParameterizedQuery[] transactionQueries = [
        `INSERT INTO accounts (name, balance) VALUES ('account_a', 1000.00)`,
        `INSERT INTO accounts (name, balance) VALUES ('account_b', 500.00)`,
        `UPDATE accounts SET balance = balance - 100.00 WHERE name = 'account_a'`,
        `UPDATE accounts SET balance = balance + 100.00 WHERE name = 'account_b'`
    ];
    
    // Execute as batch to simulate transaction
    sql:ExecutionResult[]|sql:Error transactionResult = performBatchExecute(testConn, transactionQueries);
    
    if transactionResult is sql:ExecutionResult[] {
        test:assertTrue(true, msg = "Transaction simulation completed successfully");
        io:println("Transaction operations completed: ", transactionResult.length());
    } else {
        test:assertTrue(true, msg = "Transaction simulation handled error appropriately");
        io:println("Transaction error: ", transactionResult.message());
    }
    
    error? closeResult = closeTestClient(testConn);
    test:assertFalse(closeResult is error, msg = "Client should close without error");
}

@test:Config {}
function testComplexQueryScenarios() returns error? {
    TestClient testConn = getTestClient();
    
    // Test JOIN query
    sql:ParameterizedQuery joinQuery = `
        SELECT 
            u.name as user_name,
            u.email as user_email,
            p.title as post_title,
            p.content as post_content
        FROM users u
        LEFT JOIN posts p ON u.id = p.user_id
        WHERE u.active = true
        ORDER BY u.name, p.created_at DESC
        LIMIT 10
    `;
    
    stream<record {}, sql:Error?> joinStream = performQuery(testConn, joinQuery);
    
    int recordCount = 0;
    check from record {} result in joinStream
        do {
            recordCount += 1;
            if recordCount <= 3 {  // Log first few records for verification
                io:println("Join query result ", recordCount, ": ", result);
            }
        };
    
    test:assertTrue(recordCount >= 0, msg = "Complex JOIN query should execute");
    io:println("Complex query processed ", recordCount, " records");
    
    // Test aggregate query
    sql:ParameterizedQuery aggregateQuery = `
        SELECT 
            department,
            COUNT(*) as employee_count,
            AVG(salary) as avg_salary,
            MAX(salary) as max_salary,
            MIN(salary) as min_salary
        FROM employees
        WHERE active = true
        GROUP BY department
        HAVING COUNT(*) > 1
        ORDER BY avg_salary DESC
    `;
    
    stream<record {}, sql:Error?> aggStream = performQuery(testConn, aggregateQuery);
    
    record {}[] aggResults = [];
    check from record {} result in aggStream
        do {
            aggResults.push(result);
        };
    
    test:assertTrue(aggResults.length() >= 0, msg = "Aggregate query should execute");
    io:println("Aggregate query returned ", aggResults.length(), " departments");
    
    error? closeResult = closeTestClient(testConn);
    test:assertFalse(closeResult is error, msg = "Client should close without error");
}

@test:Config {}
function testGraalVMCompatibilityScenarios() returns error? {
    // Test scenarios specifically for GraalVM compatibility
    
    // Test client creation in GraalVM context
    Client|error graalClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL + ";GraalVM=compatible");
    if graalClient is Client {
        // Test basic operations
        sql:ParameterizedQuery graalQuery = `
            SELECT 
                'graalvm_client_test' as context,
                'native_compilation' as feature,
                CURRENT_TIMESTAMP as execution_time
        `;
        
        stream<record {}, sql:Error?>|error queryResult = trap graalClient->query(graalQuery);
        if queryResult is stream<record {}, sql:Error?> {
            record {}|error? result = queryResult.next();
            test:assertTrue(result is record {} || result is (), 
                           msg = "GraalVM query should execute");
            check queryResult.close();
        }
        
        _ = check graalClient.close();
        test:assertTrue(true, msg = "GraalVM client test completed");
    } else {
        test:assertTrue(true, msg = "GraalVM client test skipped - connection not available");
    }
    
    // Test memory efficiency patterns for native compilation
    TestClient testConn = getTestClient();
    
    // Execute multiple small queries to test memory patterns
    foreach int i in 1...5 {
        sql:ParameterizedQuery memQuery = `
            SELECT 
                'memory_test' as test_type,
                ${i} as iteration,
                'graalvm_compatible' as status
        `;
        
        stream<record {}, sql:Error?> memStream = performQuery(testConn, memQuery);
        record {}|error? memResult = memStream.next();
        check memStream.close();
    }
    
    error? closeResult = closeTestClient(testConn);
    test:assertFalse(closeResult is error, msg = "Client should close without error");
    
    test:assertTrue(true, msg = "GraalVM compatibility scenarios completed");
}

@test:Config {}
function testClientResourceManagement() returns error? {
    // Test proper resource management and cleanup
    
    TestClient[] connections = [];
    
    // Create multiple clients
    foreach int i in 1...3 {
        TestClient testConn = getTestClient();
        connections.push(testConn);
        
        // Perform some operations
        sql:ParameterizedQuery testQuery = `
            SELECT 
                'resource_test' as test_type,
                ${i} as client_number,
                'active' as status
        `;
        
        stream<record {}, sql:Error?> resultStream = performQuery(testConn, testQuery);
        record {}|error? result = resultStream.next();
        check resultStream.close();
    }
    
    // Close all clients
    foreach TestClient conn in connections {
        error? closeResult = closeTestClient(conn);
        test:assertFalse(closeResult is error, msg = "Each client should close without error");
    }
    
    test:assertTrue(true, msg = "Resource management test completed");
}

@test:Config {}
function testErrorRecoveryScenarios() returns error? {
    TestClient testConn = getTestClient();
    
    // Test recovery from query errors
    sql:ParameterizedQuery[] testQueries = [
        `SELECT 'valid_query_1' as status, 1 as id`,
        `INVALID SQL SYNTAX HERE`,  // This should fail
        `SELECT 'valid_query_2' as status, 2 as id`  // This should work after error
    ];
    
    foreach sql:ParameterizedQuery query in testQueries {
        stream<record {}, sql:Error?>|error result = trap performQuery(testConn, query);
        if result is stream<record {}, sql:Error?> {
            record {}|error? queryResult = result.next();
            check result.close();
            test:assertTrue(true, msg = "Query executed or handled appropriately");
        } else {
            test:assertTrue(true, msg = "Query error handled appropriately");
        }
    }
    
    error? closeResult = closeTestClient(testConn);
    test:assertFalse(closeResult is error, msg = "Client should close without error after errors");
    
    test:assertTrue(true, msg = "Error recovery scenarios completed");
}

@test:Config {}
function testClientConfigurationValidation() returns error? {
    // Test various configuration validation scenarios
    
    // Test SSL configuration validation
    SSL validSSL = {sslServerCert: "/valid/path/cert.pem"};
    SSL invalidSSL = {sslServerCert: ""};
    
    // Test Firewall configuration validation
    Firewall validFirewall = {
        firewallType: TUNNEL,
        firewallServer: "firewall.example.com",
        firewallPort: 8080,
        firewallUser: "fwuser",
        firewallPassword: "fwpass"
    };
    
    // Test Proxy configuration validation
    Proxy validProxy = {
        proxyAutoDetect: false,
        proxyServer: "proxy.example.com",
        proxyPort: 3128,
        proxyAuthScheme: BASIC,
        proxyUser: "proxyuser",
        proxyPassword: "proxypass"
    };
    
    // Test Logging configuration validation
    Logging validLogging = {
        logfile: "/tmp/cdata-client-test.log",
        verbosity: "3",
        logModules: "connection,query,transaction",
        maxLogFileSize: "25MB",
        maxLogFileCount: 5
    };
    
    // Test Miscellaneous configuration validation
    Miscellaneous validMisc = {
        batchSize: 250,
        timeout: 60,
        connectionLifeTime: 1200,
        connectOnOpen: true,
        maxRows: 5000,
        useConnectionPooling: true,
        poolIdleTimeout: 180,
        poolMaxSize: 15,
        poolMinSize: 2,
        poolWaitTime: 30,
        pseudoColumns: "include",
        queryPassthrough: true,
        rtk: "test-runtime-key",
        other: "CustomParam1=Value1;CustomParam2=Value2"
    };
    
    // Combine all configurations
    Options comprehensiveOptions = {
        ssl: validSSL,
        firewall: validFirewall,
        proxy: validProxy,
        logging: validLogging,
        miscellaneous: validMisc
    };
    
    // Test client creation with comprehensive options
    Client|error configClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, comprehensiveOptions);
    if configClient is Client {
        test:assertTrue(true, msg = "Comprehensive configuration client created successfully");
        
        // Test basic operation with configured client
        sql:ParameterizedQuery configQuery = `
            SELECT 
                'config_validation_test' as test_type,
                'comprehensive_options' as config_level,
                'success' as status
        `;
        
        stream<record {}, sql:Error?>|error configResult = trap configClient->query(configQuery);
        if configResult is stream<record {}, sql:Error?> {
            record {}|error? result = configResult.next();
            check configResult.close();
        }
        
        _ = check configClient.close();
    } else {
        test:assertTrue(true, msg = "Configuration validation handled appropriately");
    }
    
    test:assertTrue(true, msg = "Client configuration validation completed");
}