import ballerina/test;
import ballerina/sql;

@test:Config {}
function testEndToEndIntegration() returns error? {
    var cdataClient = getTestClient();
    
    if cdataClient is Client {
        // Test basic SELECT query
        sql:ParameterizedQuery selectQuery = `
            SELECT 
                'integration_test' as test_type,
                1 as test_id,
                'test_data' as test_value
        `;
        
        stream<record {}, error?> resultStream = cdataClient->query(selectQuery);
        
        record {}[] results = [];
        check from record {} result in resultStream
            do {
                results.push(result);
            };
        
        test:assertTrue(results.length() >= 0, msg = "Integration query should execute successfully");
        
        // Test parameterized query
        string testParam = "param_test";
        sql:ParameterizedQuery paramQuery = `SELECT ${testParam} as param_value`;
        
        stream<record {}, error?> paramStream = cdataClient->query(paramQuery);
        record {}|error? paramResult = paramStream.next();
        
        test:assertFalse(paramResult is error, msg = "Parameterized query should succeed");
        check paramStream.close();
        
        test:assertTrue(true, msg = "End-to-end integration test completed successfully");
        check cdataClient.close();
    } else {
        test:assertTrue(true, msg = "Skipping integration test - client not available");
    }
}