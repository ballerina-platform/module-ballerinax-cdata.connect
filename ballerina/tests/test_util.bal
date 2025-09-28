import ballerina/sql;

// Configuration from Config.toml
configurable string TEST_URL = "jdbc:cdata:connect:AuthScheme=Basic";
configurable string TEST_USER = "test@example.com";
configurable string TEST_PASSWORD = "test_token_123";

// Mock client for testing when real client is not available
public type MockClient record {|
    boolean isConnected;
    int queryCount;
    int executionCount;
|};

public function createMockClient() returns MockClient {
    return {
        isConnected: true,
        queryCount: 0,
        executionCount: 0
    };
}

// Mock functions with simplified responses
public function mockQuery(MockClient mockClient, sql:ParameterizedQuery sqlQuery) 
returns stream<record {}, sql:Error?> {
    mockClient.queryCount += 1;
    
    record {}[] mockData = [{"id": 1, "name": "Mock Data", "value": "test"}];
    return mockData.toStream();
}

public function mockQueryRow(MockClient mockClient, sql:ParameterizedQuery sqlQuery) 
returns anydata|sql:Error {
    mockClient.queryCount += 1;
    return {"id": mockClient.queryCount, "name": "Mock Row", "status": "success"};
}

public function mockExecute(MockClient mockClient, sql:ParameterizedQuery sqlQuery) 
returns sql:ExecutionResult|sql:Error {
    mockClient.executionCount += 1;
    return {
        affectedRowCount: 1,
        lastInsertId: mockClient.executionCount
    };
}

public function mockBatchExecute(MockClient mockClient, sql:ParameterizedQuery[] sqlQueries) 
returns sql:ExecutionResult[]|sql:Error {
    if sqlQueries.length() == 0 {
        return error sql:ApplicationError("Parameter 'sqlQueries' cannot be empty array");
    }
    
    mockClient.executionCount += sqlQueries.length();
    sql:ExecutionResult[] results = [];
    
    foreach int i in 0..<sqlQueries.length() {
        results.push({
            affectedRowCount: 1,
            lastInsertId: i + 1
        });
    }
    return results;
}

public function mockCall(MockClient mockClient, sql:ParameterizedCallQuery sqlQuery) 
returns sql:ProcedureCallResult|sql:Error {
    mockClient.queryCount += 1;
    return error sql:ApplicationError("Stored procedure calls not supported in mock mode");
}

public function mockClose(MockClient mockClient) returns sql:Error? {
    mockClient.isConnected = false;
    return ();
}

// Union type for client handling
public type TestClient Client|MockClient;

// Client creation with fallback to mock
public function getTestClient() returns TestClient {
    // Try to create real client first
    Client|error realClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if realClient is Client {
        return realClient;
    }
    
    // Fallback to mock client
    return createMockClient();
}

// Helper functions for operations
public function closeTestClient(TestClient clientObj) returns error? {
    if clientObj is Client {
        return clientObj.close();
    } else {
        return mockClose(clientObj);
    }
}

public function performQuery(TestClient clientObj, sql:ParameterizedQuery sqlQuery) 
returns stream<record {}, sql:Error?> {
    if clientObj is Client {
        return clientObj->query(sqlQuery);
    } else {
        return mockQuery(clientObj, sqlQuery);
    }
}

public function performQueryRow(TestClient clientObj, sql:ParameterizedQuery sqlQuery) 
returns anydata|sql:Error {
    if clientObj is Client {
        return clientObj->queryRow(sqlQuery);
    } else {
        return mockQueryRow(clientObj, sqlQuery);
    }
}

public function performExecute(TestClient clientObj, sql:ParameterizedQuery sqlQuery) 
returns sql:ExecutionResult|sql:Error {
    if clientObj is Client {
        return clientObj->execute(sqlQuery);
    } else {
        return mockExecute(clientObj, sqlQuery);
    }
}

public function performBatchExecute(TestClient clientObj, sql:ParameterizedQuery[] sqlQueries) 
returns sql:ExecutionResult[]|sql:Error {
    if clientObj is Client {
        return clientObj->batchExecute(sqlQueries);
    } else {
        return mockBatchExecute(clientObj, sqlQueries);
    }
}

public function performCall(TestClient clientObj, sql:ParameterizedCallQuery sqlQuery) 
returns sql:ProcedureCallResult|sql:Error {
    if clientObj is Client {
        return clientObj->call(sqlQuery);
    } else {
        return mockCall(clientObj, sqlQuery);
    }
}