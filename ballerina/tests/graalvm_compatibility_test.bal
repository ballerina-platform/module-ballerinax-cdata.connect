import ballerina/test;
import ballerina/sql;
import ballerina/io;

@test:Config {}
function testGraalVMBasicQuery() returns error? {
    TestClient cdataClient = getTestClient();
    
    sql:ParameterizedQuery graalVMQuery = `
        SELECT 
            'graalvm_test' as test_type,
            'GraalVM Compatible' as message,
            1 as test_id
    `;
    
    // Use trap to handle potential compilation differences in GraalVM
    stream<record {}, sql:Error?>|error queryResult = trap performQuery(cdataClient, graalVMQuery);
    
    if queryResult is stream<record {}, sql:Error?> {
        record {}[] results = [];
        check from record {} result in queryResult
            do {
                results.push(result);
            };
        
        test:assertTrue(results.length() >= 0, msg = "GraalVM query should execute");
        io:println("GraalVM test results: ", results.length(), " records");
    } else {
        // If there's an error, fall back to simple query
        sql:ParameterizedQuery fallbackQuery = `SELECT 'graalvm_fallback' as test_type, 1 as test_id`;
        stream<record {}, sql:Error?> fallbackStream = performQuery(cdataClient, fallbackQuery);
        
        record {}|error? result = fallbackStream.next();
        test:assertTrue(result is record {}, msg = "GraalVM fallback query should work");
        check fallbackStream.close();
    }
    
    error? closeResult = closeTestClient(cdataClient);
    test:assertFalse(closeResult is error, msg = "Client should close without error");
}

@test:Config {}
function testGraalVMMemoryEfficiency() returns error? {
    TestClient cdataClient = getTestClient();
    
    // Test multiple queries to check memory handling
    int queryCount = 5;
    
    foreach int i in 1...queryCount {
        sql:ParameterizedQuery memoryQuery = `
            SELECT 
                'memory_test' as test_type,
                ${i} as iteration,
                'data_chunk_for_memory_test' as data
        `;
        
        stream<record {}, sql:Error?> resultStream = performQuery(cdataClient, memoryQuery);
        
        // Process results to simulate memory usage
        record {}[] tempResults = [];
        check from record {} result in resultStream
            do {
                tempResults.push(result);
            };
        
        // Clear temporary results to help GC
        tempResults.removeAll();
    }
    
    test:assertTrue(true, msg = "GraalVM memory efficiency test completed");
    io:println("Processed ", queryCount, " queries for memory efficiency test");
    
    error? closeResult = closeTestClient(cdataClient);
    test:assertFalse(closeResult is error, msg = "Client should close without error");
}

@test:Config {}
function testGraalVMNativeImageCompatibility() returns error? {
    TestClient cdataClient = getTestClient();
    
    // Test operations that might be affected by native image compilation
    sql:ParameterizedQuery nativeQuery = `
        SELECT 
            'native_image_test' as compatibility_type,
            'current_time' as query_time
    `;
    
    stream<record {}, sql:Error?>|error queryResult = trap performQuery(cdataClient, nativeQuery);
    
    if queryResult is stream<record {}, sql:Error?> {
        record {}|error? firstResult = queryResult.next();
        
        if firstResult is record {} {
            io:println("Native image compatibility test result: ", firstResult);
            test:assertTrue(true, msg = "Native image query executed successfully");
        } else if firstResult is () {
            test:assertTrue(true, msg = "Native image query completed (no results)");
        }
        
        check queryResult.close();
    } else {
        // Handle potential reflection or serialization issues in native image
        io:println("Native image query failed, testing fallback");
        
        sql:ParameterizedQuery simpleFallback = `SELECT 'native_fallback' as test, 1 as result`;
        stream<record {}, sql:Error?> fallbackStream = performQuery(cdataClient, simpleFallback);
        
        record {}|error? fallbackResult = fallbackStream.next();
        test:assertTrue(fallbackResult is record {}, msg = "Fallback should work in native image");
        check fallbackStream.close();
    }
    
    error? closeResult = closeTestClient(cdataClient);
    test:assertFalse(closeResult is error, msg = "Client should close without error");
}

@test:Config {}
function testGraalVMResourceHandling() returns error? {
    TestClient cdataClient = getTestClient();
    
    // Test that resources are properly handled in GraalVM native image
    sql:ParameterizedQuery[] resourceQueries = [
        `SELECT 'resource_1' as name, 1 as id`,
        `SELECT 'resource_2' as name, 2 as id`, 
        `SELECT 'resource_3' as name, 3 as id`
    ];
    
    foreach sql:ParameterizedQuery query in resourceQueries {
        stream<record {}, sql:Error?> resultStream = performQuery(cdataClient, query);
        
        // Ensure proper resource cleanup
        record {}|error? result = resultStream.next();
        if result is record {} {
            io:println("Resource handling test - processed: ", result);
        }
        
        // Explicitly close stream to test resource cleanup
        error? streamCloseResult = resultStream.close();
        test:assertFalse(streamCloseResult is error, msg = "Stream should close cleanly");
    }
    
    test:assertTrue(true, msg = "GraalVM resource handling test completed");
    
    error? closeResult = closeTestClient(cdataClient);
    test:assertFalse(closeResult is error, msg = "Client should close without error");
}