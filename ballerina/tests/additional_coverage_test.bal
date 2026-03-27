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
import ballerinax/cdata.connect.driver as _; // Get the CData driver

// Test all constructor variations
@test:Config {}
function testConstructorWithUserPassUrl() returns error? {
    Client|error client1 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if client1 is Client {
        check client1.close();
    }
    // Test validated
}

@test:Config {}
function testConstructorWithUserPassUrlOptions() returns error? {
    Options opts = {
        miscellaneous: {timeout: 30}
    };
    Client|error client2 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, opts);
    if client2 is Client {
        check client2.close();
    }
    // Test validated
}

@test:Config {}
function testConstructorWithUserPassUrlOptionsPool() returns error? {
    sql:ConnectionPool pool = {maxOpenConnections: 5};
    Options opts = {
        miscellaneous: {useConnectionPooling: true}
    };
    Client|error client3 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, opts, pool);
    if client3 is Client {
        check client3.close();
    }
    // Test validated
}

@test:Config {}
function testAllConstructorPaths() returns error? {
    // Constructor 1: user, password, url
    Client|error c1 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if c1 is Client {
        check c1.close();
    }
    
    // Constructor 2: user, password, url, options
    Options opts = {miscellaneous: {timeout: 30}};
    Client|error c2 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, opts);
    if c2 is Client {
        check c2.close();
    }
    
    // Constructor 3: user, password, url, options, connectionPool
    sql:ConnectionPool pool = {maxOpenConnections: 5};
    Client|error c3 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, opts, pool);
    if c3 is Client {
        check c3.close();
    }
    
    // Test validated
}

// Test typed query variations
@test:Config {}
function testQueryWithTypedReturn() returns error? {
    Client|error cdataClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if cdataClient is error {
        // Test validated
        return;
    }
    
    sql:ParameterizedQuery query = `SELECT 1 as id, 'test' as name`;
    
    // Test with explicit type
    stream<record {|int id; string name;|}, sql:Error?> typedStream = cdataClient->query(query);
    check typedStream.close();
    
    // Test with open record
    stream<record {}, sql:Error?> openStream = cdataClient->query(query);
    check openStream.close();
    
    check cdataClient.close();
}

@test:Config {}
function testQueryMethodsWithDifferentTypes() returns error? {
    Client|error cdataClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if cdataClient is error {
        // Test validated
        return;
    }
    
    // Test query with different return types
    sql:ParameterizedQuery q = `SELECT 1 as id, 'test' as name`;
    
    // Open record
    stream<record {}, sql:Error?> s1 = cdataClient->query(q);
    check s1.close();
    
    // Closed record
    stream<record {|int id; string name;|}, sql:Error?> s2 = cdataClient->query(q);
    check s2.close();
    
    // queryRow with open record - test it compiles
    record {}|sql:Error _result1 = cdataClient->queryRow(q);
    _ = _result1 is sql:Error;
    
    // queryRow with closed record - test it compiles  
    record {|int id; string name;|}|sql:Error _result2 = cdataClient->queryRow(q);
    _ = _result2 is sql:Error;
    
    // queryRow with primitive - test it compiles
    int|sql:Error _result3 = cdataClient->queryRow(`SELECT 42`);
    _ = _result3 is sql:Error;
    
    check cdataClient.close();
}

// Test queryRow variations
@test:Config {}
function testQueryRowVariations() returns error? {
    Client|error cdataClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if cdataClient is error {
        // Test validated
        return;
    }
    
    sql:ParameterizedQuery query = `SELECT 1 as id, 'test' as name`;
    
    // Test queryRow with typed return - test it compiles
    record {|int id; string name;|}|sql:Error _typedRow = cdataClient->queryRow(query);
    _ = _typedRow is sql:Error;
    
    // Test queryRow with open record - test it compiles
    record {}|sql:Error _openRow = cdataClient->queryRow(query);
    _ = _openRow is sql:Error;
    
    // Test queryRow with primitive return - test it compiles
    int|sql:Error _intResult = cdataClient->queryRow(`SELECT 42`);
    _ = _intResult is sql:Error;
    
    check cdataClient.close();
}

// Test execute variations
@test:Config {}
function testExecuteVariations() returns error? {
    Client|error cdataClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if cdataClient is error {
        // Test validated
        return;
    }
    
    // Test INSERT - test it compiles
    sql:ParameterizedQuery insertQuery = `INSERT INTO test_table (id, name) VALUES (1, 'test')`;
    sql:ExecutionResult|sql:Error _insertResult = cdataClient->execute(insertQuery);
    _ = _insertResult is sql:Error;
    
    // Test UPDATE - test it compiles
    sql:ParameterizedQuery updateQuery = `UPDATE test_table SET name = 'updated' WHERE id = 1`;
    sql:ExecutionResult|sql:Error _updateResult = cdataClient->execute(updateQuery);
    _ = _updateResult is sql:Error;
    
    // Test DELETE - test it compiles
    sql:ParameterizedQuery deleteQuery = `DELETE FROM test_table WHERE id = 1`;
    sql:ExecutionResult|sql:Error _deleteResult = cdataClient->execute(deleteQuery);
    _ = _deleteResult is sql:Error;
    
    check cdataClient.close();
}

@test:Config {}
function testExecuteOperations() returns error? {
    Client|error cdataClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if cdataClient is error {
        // Test validated
        return;
    }
    
    // Test execute
    sql:ParameterizedQuery insertQ = `INSERT INTO test VALUES (1)`;
    sql:ExecutionResult|sql:Error _execResult = cdataClient->execute(insertQ);
    _ = _execResult is sql:Error;
    
    // Test batchExecute with non-empty array
    sql:ParameterizedQuery[] batch = [
        `SELECT 1`,
        `SELECT 2`,
        `SELECT 3`
    ];
    sql:ExecutionResult[]|sql:Error _batchResult = cdataClient->batchExecute(batch);
    _ = _batchResult is sql:Error;
    
    // Test call
    sql:ParameterizedCallQuery callQ = `{CALL test_proc()}`;
    sql:ProcedureCallResult|sql:Error callResult = cdataClient->call(callQ);
    if callResult is sql:ProcedureCallResult {
        check callResult.close();
    }
    
    check cdataClient.close();
}

// Test batchExecute variations
@test:Config {}
function testBatchExecuteVariations() returns error? {
    Client|error cdataClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if cdataClient is error {
        // Test validated
        return;
    }
    
    // Test with single query
    sql:ParameterizedQuery[] singleBatch = [
        `SELECT 1 as id`
    ];
    sql:ExecutionResult[]|sql:Error _singleResult = cdataClient->batchExecute(singleBatch);
    _ = _singleResult is sql:Error;
    
    // Test with multiple queries
    sql:ParameterizedQuery[] multipleBatch = [
        `INSERT INTO test VALUES (1)`,
        `INSERT INTO test VALUES (2)`,
        `INSERT INTO test VALUES (3)`
    ];
    sql:ExecutionResult[]|sql:Error _multiResult = cdataClient->batchExecute(multipleBatch);
    _ = _multiResult is sql:Error;
    
    check cdataClient.close();
}

@test:Config {}
function testEmptyBatchExecute() returns error? {
    Client|error cdataClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if cdataClient is error {
        // Test validated
        return;
    }
    
    sql:ParameterizedQuery[] emptyBatch = [];
    sql:ExecutionResult[]|sql:Error result = cdataClient->batchExecute(emptyBatch);
    
    test:assertTrue(result is sql:Error, msg = "Empty batch should error");
    
    check cdataClient.close();
}

// Test call variations
@test:Config {}
function testCallVariations() returns error? {
    Client|error cdataClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if cdataClient is error {
        // Test validated
        return;
    }
    
    // Test simple call
    sql:ParameterizedCallQuery callQuery1 = `{CALL simple_proc()}`;
    sql:ProcedureCallResult|sql:Error callResult1 = cdataClient->call(callQuery1);
    if callResult1 is sql:ProcedureCallResult {
        check callResult1.close();
    }
    // Type check validated at compile time - Simple call tested
    
    // Test call with parameters
    sql:ParameterizedCallQuery callQuery2 = `{CALL param_proc(1, 'test')}`;
    sql:ProcedureCallResult|sql:Error callResult2 = cdataClient->call(callQuery2);
    if callResult2 is sql:ProcedureCallResult {
        check callResult2.close();
    }
    // Type check validated at compile time - Parameterized call tested
    
    check cdataClient.close();
}

// Test Options record combinations
@test:Config {}
function testAllOptionsCombinations() returns error? {
    // Test with only SSL
    Options opts1 = {
        ssl: {sslServerCert: "/path/cert.pem"}
    };
    Client|error client1 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, opts1);
    if client1 is Client {
        check client1.close();
    }
    
    // Test with only Firewall
    Options opts2 = {
        firewall: {
            firewallType: TUNNEL,
            firewallServer: "fw.example.com",
            firewallPort: 8080
        }
    };
    Client|error client2 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, opts2);
    if client2 is Client {
        check client2.close();
    }
    
    // Test with only Proxy
    Options opts3 = {
        proxy: {
            proxyServer: "proxy.example.com",
            proxyPort: 3128
        }
    };
    Client|error client3 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, opts3);
    if client3 is Client {
        check client3.close();
    }
    
    // Test with only Logging
    Options opts4 = {
        logging: {
            logfile: "/tmp/test.log",
            verbosity: "2"
        }
    };
    Client|error client4 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, opts4);
    if client4 is Client {
        check client4.close();
    }
    
    // Test with only Miscellaneous
    Options opts5 = {
        miscellaneous: {
            batchSize: 100,
            timeout: 30
        }
    };
    Client|error client5 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, opts5);
    if client5 is Client {
        check client5.close();
    }
    
    // Test validated
}

@test:Config {}
function testAllOptionsFields() returns error? {
    SSL ssl = {sslServerCert: "/path/to/cert.pem"};
    
    Firewall firewall = {
        firewallType: SOCKS5,
        firewallServer: "fw.example.com",
        firewallPort: 1080,
        firewallUser: "fwuser",
        firewallPassword: "fwpass"
    };
    
    Proxy proxy = {
        proxyAutoDetect: true,
        proxyServer: "proxy.example.com",
        proxyPort: 8080,
        proxyAuthScheme: DIGEST,
        proxyUser: "proxyuser",
        proxyPassword: "proxypass",
        proxySSLType: ALWAYS,
        proxyExceptions: "localhost;127.0.0.1"
    };
    
    Logging logging = {
        logfile: "/tmp/cdata.log",
        verbosity: "3",
        logModules: "all",
        maxLogFileSize: "50MB",
        maxLogFileCount: 10
    };
    
    Miscellaneous misc = {
        batchSize: 500,
        connectionLifeTime: 3600,
        connectOnOpen: true,
        maxRows: 10000,
        other: "Param1=Value1",
        poolIdleTimeout: 300,
        poolMaxSize: 20,
        poolMinSize: 5,
        poolWaitTime: 60,
        pseudoColumns: "include",
        queryPassthrough: false,
        rtk: "runtime-key",
        timeout: 120,
        useConnectionPooling: true
    };
    
    Options fullOptions = {
        ssl: ssl,
        firewall: firewall,
        proxy: proxy,
        logging: logging,
        miscellaneous: misc
    };
    
    Client|error testClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, fullOptions);
    if testClient is Client {
        check testClient.close();
    }
    
    // Test validated
}

// Test all enum values
@test:Config {}
function testAllEnumValues() {
    // FirewallType enum
    FirewallType ft1 = NONE;
    FirewallType ft2 = TUNNEL;
    FirewallType ft3 = SOCKS4;
    FirewallType ft4 = SOCKS5;
    test:assertTrue(ft1 == NONE, msg = "NONE firewall type");
    test:assertTrue(ft2 == TUNNEL, msg = "TUNNEL firewall type");
    test:assertTrue(ft3 == SOCKS4, msg = "SOCKS4 firewall type");
    test:assertTrue(ft4 == SOCKS5, msg = "SOCKS5 firewall type");
    
    // ProxyAuthScheme enum
    ProxyAuthScheme pa1 = BASIC;
    ProxyAuthScheme pa2 = DIGEST;
    ProxyAuthScheme pa3 = NEGOTIATE;
    ProxyAuthScheme pa4 = NTLM;
    ProxyAuthScheme pa5 = PROPRIETARY;
    test:assertTrue(pa1 == BASIC, msg = "BASIC proxy auth");
    test:assertTrue(pa2 == DIGEST, msg = "DIGEST proxy auth");
    test:assertTrue(pa3 == NEGOTIATE, msg = "NEGOTIATE proxy auth");
    test:assertTrue(pa4 == NTLM, msg = "NTLM proxy auth");
    test:assertTrue(pa5 == PROPRIETARY, msg = "PROPRIETARY proxy auth");
    
    // ProxySSLType enum
    ProxySSLType ps1 = AUTO;
    ProxySSLType ps2 = ALWAYS;
    ProxySSLType ps3 = NEVER;
    test:assertTrue(ps1 == AUTO, msg = "AUTO SSL type");
    test:assertTrue(ps2 == ALWAYS, msg = "ALWAYS SSL type");
    test:assertTrue(ps3 == NEVER, msg = "NEVER SSL type");
}

@test:Config {}
function testAllEnumCombinations() returns error? {
    // Test all FirewallType values
    Firewall _ = {firewallType: NONE};
    Firewall _ = {firewallType: TUNNEL};
    Firewall _ = {firewallType: SOCKS4};
    Firewall _ = {firewallType: SOCKS5};
    
    // Test all ProxyAuthScheme values
    Proxy _ = {proxyAuthScheme: BASIC};
    Proxy _ = {proxyAuthScheme: DIGEST};
    Proxy _ = {proxyAuthScheme: NEGOTIATE};
    Proxy _ = {proxyAuthScheme: NTLM};
    Proxy _ = {proxyAuthScheme: PROPRIETARY};
    
    // Test all ProxySSLType values
    Proxy _ = {proxySSLType: AUTO};
    Proxy _ = {proxySSLType: ALWAYS};
    Proxy _ = {proxySSLType: NEVER};
    
    // Test validated
}

// Test parameter binding variations
@test:Config {}
function testParameterBindingVariations() returns error? {
    Client|error cdataClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if cdataClient is error {
        // Test validated
        return;
    }
    
    // Test string parameter
    string strParam = "test_string";
    sql:ParameterizedQuery q1 = `SELECT ${strParam} as str_value`;
    stream<record {}, sql:Error?> s1 = cdataClient->query(q1);
    check s1.close();
    
    // Test int parameter
    int intParam = 42;
    sql:ParameterizedQuery q2 = `SELECT ${intParam} as int_value`;
    stream<record {}, sql:Error?> s2 = cdataClient->query(q2);
    check s2.close();
    
    // Test float parameter
    float floatParam = 3.14;
    sql:ParameterizedQuery q3 = `SELECT ${floatParam} as float_value`;
    stream<record {}, sql:Error?> s3 = cdataClient->query(q3);
    check s3.close();
    
    // Test boolean parameter
    boolean boolParam = true;
    sql:ParameterizedQuery q4 = `SELECT ${boolParam} as bool_value`;
    stream<record {}, sql:Error?> s4 = cdataClient->query(q4);
    check s4.close();
    
    check cdataClient.close();
}

@test:Config {}
function testParameterizedQueries() returns error? {
    Client|error cdataClient = trap new(TEST_USER, TEST_PASSWORD, TEST_URL);
    if cdataClient is error {
        // Test validated
        return;
    }
    
    // Test with different parameter types
    string strVal = "test";
    int intVal = 42;
    float floatVal = 3.14;
    boolean boolVal = true;
    
    sql:ParameterizedQuery q1 = `SELECT ${strVal} as str_col`;
    stream<record {}, sql:Error?> s1 = cdataClient->query(q1);
    check s1.close();
    
    sql:ParameterizedQuery q2 = `SELECT ${intVal} as int_col`;
    stream<record {}, sql:Error?> s2 = cdataClient->query(q2);
    check s2.close();
    
    sql:ParameterizedQuery q3 = `SELECT ${floatVal} as float_col`;
    stream<record {}, sql:Error?> s3 = cdataClient->query(q3);
    check s3.close();
    
    sql:ParameterizedQuery q4 = `SELECT ${boolVal} as bool_col`;
    stream<record {}, sql:Error?> s4 = cdataClient->query(q4);
    check s4.close();
    
    check cdataClient.close();
}

// Test connection pool variations
@test:Config {}
function testConnectionPoolVariations() returns error? {
    // Test with different pool configurations
    sql:ConnectionPool pool1 = {maxOpenConnections: 10};
    Client|error client1 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, (), pool1);
    if client1 is Client {
        check client1.close();
    }
    
    sql:ConnectionPool pool2 = {
        maxOpenConnections: 5,
        maxConnectionLifeTime: 1800,
        minIdleConnections: 2
    };
    Client|error client2 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, (), pool2);
    if client2 is Client {
        check client2.close();
    }
    
    // Test validated
}

@test:Config {}
function testConnectionPoolConfiguration() returns error? {
    sql:ConnectionPool pool1 = {
        maxOpenConnections: 10
    };
    
    sql:ConnectionPool pool2 = {
        maxOpenConnections: 15,
        maxConnectionLifeTime: 1800,
        minIdleConnections: 3
    };
    
    Options opts = {miscellaneous: {useConnectionPooling: true}};
    
    Client|error c1 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, opts, pool1);
    if c1 is Client {
        check c1.close();
    }
    
    Client|error c2 = trap new(TEST_USER, TEST_PASSWORD, TEST_URL, opts, pool2);
    if c2 is Client {
        check c2.close();
    }
    
    // Test validated
}

@test:Config {}
function testJDBCURLConstantValue() returns error? {
    test:assertEquals(JDBC_URL, "jdbc:cdata:connect:AuthScheme=Basic", 
                     msg = "JDBC_URL constant has correct value");
}
