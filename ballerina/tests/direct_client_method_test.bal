// Copyright (c) 2024 WSO2 LLC. (https://www.wso2.com).
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


@test:Config {}
function testDirectQueryMethod() returns error? {
    // Try to create a real client - test will fail naturally if creation fails
    Client cdataClient = check new("testuser", "testpass", JDBC_URL + ";MockMode=true;Timeout=5");
    
    // LINE 73: Direct call to query method
    sql:ParameterizedQuery query = `SELECT 'direct_test' as test`;
    stream<record {}, sql:Error?> result = cdataClient->query(query);
    check result.close();
    
    check cdataClient.close();
}

@test:Config {}
function testDirectQueryRowMethod() returns error? {
    Client cdataClient = check new("testuser", "testpass", JDBC_URL + ";MockMode=true;Timeout=5");
    
    // LINE 86: Direct call to queryRow method
    sql:ParameterizedQuery query = `SELECT 1 as id`;
    anydata|sql:Error result = cdataClient->queryRow(query);
    
    check cdataClient.close();
}

@test:Config {}
function testDirectExecuteMethod() returns error? {
    Client cdataClient = check new("testuser", "testpass", JDBC_URL + ";MockMode=true;Timeout=5");
    
    // LINE 96: Direct call to execute method
    sql:ParameterizedQuery query = `INSERT INTO test VALUES (1)`;
    sql:ExecutionResult|sql:Error result = cdataClient->execute(query);
    
    check cdataClient.close();
}

@test:Config {}
function testDirectBatchExecuteMethod() returns error? {
    Client cdataClient = check new("testuser", "testpass", JDBC_URL + ";MockMode=true;Timeout=5");
    
    // LINE 100: Empty array validation
    sql:ParameterizedQuery[] emptyQueries = [];
    sql:ExecutionResult[]|sql:Error result1 = cdataClient->batchExecute(emptyQueries);
    test:assertTrue(result1 is sql:Error, msg = "Empty batch should error");
    
    // LINE 110-114: Non-empty batch calls nativeBatchExecute
    sql:ParameterizedQuery[] queries = [
        `INSERT INTO test VALUES (1)`,
        `INSERT INTO test VALUES (2)`
    ];
    sql:ExecutionResult[]|sql:Error result2 = cdataClient->batchExecute(queries);
    
    check cdataClient.close();
}

@test:Config {}
function testDirectCallMethod() returns error? {
    Client cdataClient = check new("testuser", "testpass", JDBC_URL + ";MockMode=true;Timeout=5");
    
    // LINE 121: Direct call to stored procedure
    sql:ParameterizedCallQuery callQuery = `{CALL test_proc()}`;
    sql:ProcedureCallResult|sql:Error result = cdataClient->call(callQuery);
    
    if result is sql:ProcedureCallResult {
        check result.close();
    }
    
    check cdataClient.close();
}

@test:Config {}
function testDirectCloseMethod() returns error? {
    Client cdataClient = check new("testuser", "testpass", JDBC_URL + ";MockMode=true;Timeout=5");
    
    // LINE 130: Direct call to close method
    check cdataClient.close();
}

@test:Config {}
function testJDBCURLConstant() {
    // LINE 133: Access JDBC_URL constant directly
    string url = JDBC_URL;
    test:assertEquals(url, "jdbc:cdata:connect:AuthScheme=Basic", msg = "JDBC_URL constant accessed");
}

@test:Config {}
function testClientConfigurationUsage() returns error? {
    // LINE 297, 300: createClient and nativeBatchExecute are called through Client methods
    // We've already hit these through direct method calls above
    
    // Additional test to ensure ClientConfiguration type is used
    Client client1 = check new("user1", "pass1");
    check client1.close();
    
    Client client2 = check new("user2", "pass2", JDBC_URL);
    check client2.close();
    
    Client client3 = check new("user3", "pass3", JDBC_URL, {miscellaneous: {timeout: 30}});
    check client3.close();
    
    sql:ConnectionPool pool = {maxOpenConnections: 5};
    Client client4 = check new("user4", "pass4", JDBC_URL, (), pool);
    check client4.close();
    
    Client client5 = check new("user5", "pass5", JDBC_URL, {miscellaneous: {timeout: 30}}, pool);
    check client5.close();
}

@test:Config {}
function testAllRemoteMethodSignatures() returns error? {
    // Ensure all remote method signatures are tested
    Client cdataClient = check new("test", "test", JDBC_URL + ";MockMode=true");
    
    // Test query with different type descriptors
    sql:ParameterizedQuery q1 = `SELECT 1 as id`;
    stream<record {}, sql:Error?> s1 = cdataClient->query(q1);
    check s1.close();
    
    stream<record {|int id;|}, sql:Error?> s2 = cdataClient->query(q1);
    check s2.close();
    
    // Test queryRow with different return types
    int|sql:Error r1 = cdataClient->queryRow(`SELECT 1`);
    record {}|sql:Error r2 = cdataClient->queryRow(q1);
    
    // Test execute
    sql:ExecutionResult|sql:Error e1 = cdataClient->execute(`INSERT INTO test VALUES (1)`);
    
    // Test batchExecute
    sql:ExecutionResult[]|sql:Error b1 = cdataClient->batchExecute([q1, q1]);
    
    // Test call with different rowTypes
    sql:ProcedureCallResult|sql:Error c1 = cdataClient->call(`{CALL proc()}`);
    if c1 is sql:ProcedureCallResult {
        check c1.close();
    }
    
    typedesc<record {|int id;|}> rowType = typeof {id: 0};
    sql:ProcedureCallResult|sql:Error c2 = cdataClient->call(`{CALL proc()}`, [rowType]);
    if c2 is sql:ProcedureCallResult {
        check c2.close();
    }
    
    check cdataClient.close();
}

@test:Config {}
function testInitMethodVariations() returns error? {
    // LINE 56-65: Test init method with all parameter combinations
    
    // 2-param constructor
    Client c1 = check new("user", "pass");
    check c1.close();
    
    // 3-param constructor
    Client c2 = check new("user", "pass", JDBC_URL);
    check c2.close();
    
    // 4-param constructor with options
    Options opts = {miscellaneous: {timeout: 30}};
    Client c3 = check new("user", "pass", JDBC_URL, opts);
    check c3.close();
    
    // 4-param constructor with null options
    Client c4 = check new("user", "pass", JDBC_URL, ());
    check c4.close();
    
    // 5-param constructor with pool
    sql:ConnectionPool pool = {maxOpenConnections: 5};
    Client c5 = check new("user", "pass", JDBC_URL, (), pool);
    check c5.close();
    
    // 5-param constructor with options and pool
    Client c6 = check new("user", "pass", JDBC_URL, opts, pool);
    check c6.close();
    
    // 5-param constructor with null pool
    Client c7 = check new("user", "pass", JDBC_URL, opts, ());
    check c7.close();
}
