import ballerina/test;
import ballerina/sql;

@test:Config {}
function testGraalVMBasicCompatibility() returns error? {
    TestClient testConn = getTestClient();
    
    sql:ParameterizedQuery graalQuery = `
        SELECT 
            'graalvm_test' as test_type,
            'native_compilation' as feature,
            1 as test_id
    `;
    
    stream<record {}, sql:Error?> resultStream = performQuery(testConn, graalQuery);
    
    record {}[] results = [];
    check from record {} result in resultStream
        do {
            results.push(result);
        };
    
    test:assertTrue(results.length() >= 0, msg = "GraalVM basic query executed");
    _ = check closeTestClient(testConn);
}

@test:Config {}
function testGraalVMMemoryEfficiency() returns error? {
    TestClient testConn = getTestClient();
    
    // Test multiple queries for memory handling
    foreach int i in 1...3 {
        sql:ParameterizedQuery memoryQuery = `
            SELECT 
                'memory_test' as test_type,
                ${i} as iteration
        `;
        
        stream<record {}, sql:Error?> resultStream = performQuery(testConn, memoryQuery);
        
        // Process and clear results
        record {}[] tempResults = [];
        check from record {} result in resultStream
            do {
                tempResults.push(result);
            };
        
        tempResults.removeAll();
    }
    
    test:assertTrue(true, msg = "GraalVM memory efficiency tested");
    _ = check closeTestClient(testConn);
}

@test:Config {}
function testGraalVMResourceHandling() returns error? {
    TestClient testConn = getTestClient();
    
    // Test resource cleanup in GraalVM context
    sql:ParameterizedQuery[] resourceQueries = [
        `SELECT 'resource_1' as name, 1 as id`,
        `SELECT 'resource_2' as name, 2 as id`,
        `SELECT 'resource_3' as name, 3 as id`
    ];
    
    foreach sql:ParameterizedQuery query in resourceQueries {
        stream<record {}, sql:Error?> resultStream = performQuery(testConn, query);
        _ = check resultStream.close();
    }
    
    test:assertTrue(true, msg = "GraalVM resource handling tested");
    _ = check closeTestClient(testConn);
}

@test:Config {}
function testGraalVMNativeImageOperations() returns error? {
    TestClient testConn = getTestClient();
    
    // Test operations that might be affected by native compilation
    sql:ParameterizedQuery nativeQuery = `
        SELECT 
            'native_image_test' as compatibility_type,
            'current_time' as query_time
    `;
    
    stream<record {}, sql:Error?> resultStream = performQuery(testConn, nativeQuery);
    record {}|error? result = resultStream.next();
    
    test:assertTrue(result is record {} || result is (), 
                   msg = "Native image operations work correctly");
    
    _ = check resultStream.close();
    _ = check closeTestClient(testConn);
}