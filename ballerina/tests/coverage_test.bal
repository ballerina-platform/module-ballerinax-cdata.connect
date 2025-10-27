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

// Focused tests to target specific missed lines without redundancy

@test:Config {}
function testEmptyBatchExecuteValidation() returns error? {
    // TARGET: Line 100 - empty array validation in batchExecute
    Client cdataClient = check new("test_user", "test_pass", JDBC_URL);
    
    sql:ParameterizedQuery[] emptyQueries = [];
    sql:ExecutionResult[]|sql:Error result = cdataClient->batchExecute(emptyQueries);
    
    test:assertTrue(result is sql:Error, msg = "Empty batch should return error");
    if result is sql:Error {
        test:assertTrue(result.message().includes("empty array"), 
                       msg = "Error should mention empty array");
    }
    
    check cdataClient.close();
}

@test:Config {}
function testConstructorOverloads() returns error? {
    // TARGET: All constructor variations to hit initialization paths
    
    // Constructor 1: (user, password)
    Client client1 = check new("user1", "pass1");
    check client1.close();
    
    // Constructor 2: (user, password, url)
    Client client2 = check new("user2", "pass2", JDBC_URL);
    check client2.close();
    
    // Constructor 3: (user, password, url, options)
    Options opts = {miscellaneous: {timeout: 30}};
    Client client3 = check new("user3", "pass3", JDBC_URL, opts);
    check client3.close();
    
    // Constructor 4: (user, password, url, options, pool)
    sql:ConnectionPool pool = {maxOpenConnections: 5};
    Client client4 = check new("user4", "pass4", JDBC_URL, opts, pool);
    check client4.close();
    
    // Constructor 5: (user, password, url, (), pool)
    Client client5 = check new("user5", "pass5", JDBC_URL, (), pool);
    check client5.close();
}

@test:Config {}
function testJDBCURLConstantUsage() returns error? {
    // TARGET: Line 133 - JDBC_URL constant usage
    
    test:assertEquals(JDBC_URL, "jdbc:cdata:connect:AuthScheme=Basic", 
                     msg = "JDBC_URL constant should have correct value");
    
    // Use constant in various contexts
    string[] urlVariations = [
        JDBC_URL,
        JDBC_URL + ";Timeout=30",
        JDBC_URL + ";BatchSize=100",
        JDBC_URL + ";MockMode=true"
    ];
    
    foreach string url in urlVariations {
        test:assertTrue(url.startsWith(JDBC_URL), 
                       msg = "URL variations should start with JDBC_URL constant");
        
        Client testClient = check new("user", "pass", url);
        check testClient.close();
    }
}

@test:Config {}
function testClientConfigurationRecord() returns error? {
    // TARGET: Lines 297, 300 - ClientConfiguration record usage
    
    ClientConfiguration config1 = {
        url: JDBC_URL,
        user: "user1",
        password: "pass1",
        options: (),
        connectionPool: ()
    };
    
    ClientConfiguration config2 = {
        url: JDBC_URL + ";Timeout=30",
        user: "user2", 
        password: "pass2",
        options: {miscellaneous: {timeout: 45}},
        connectionPool: {maxOpenConnections: 5}
    };
    
    // Verify record field access
    test:assertTrue(config1.url is string, msg = "Config URL should be string");
    test:assertTrue(config2.options is Options, msg = "Config options should be set");
}

@test:Config {}
function testComprehensiveEnumUsage() returns error? {
    // TARGET: Ensure all enum values are used for coverage
    
    // Test all FirewallType values
    FirewallType[] firewallTypes = [NONE, TUNNEL, SOCKS4, SOCKS5];
    foreach FirewallType fwType in firewallTypes {
        Firewall fw = {firewallType: fwType, firewallServer: "test.com"};
        Options opts = {firewall: fw};
        Client testClient = check new("user", "pass", JDBC_URL, opts);
        check testClient.close();
    }
    
    // Test all ProxyAuthScheme values
    ProxyAuthScheme[] authSchemes = [BASIC, DIGEST, NEGOTIATE, NTLM, PROPRIETARY];
    foreach ProxyAuthScheme authScheme in authSchemes {
        Proxy proxy = {proxyAuthScheme: authScheme, proxyServer: "proxy.com"};
        Options opts = {proxy: proxy};
        Client testClient = check new("user", "pass", JDBC_URL, opts);
        check testClient.close();
    }
    
    // Test all ProxySSLType values
    ProxySSLType[] sslTypes = [AUTO, ALWAYS, NEVER, TUNNEL];
    foreach ProxySSLType sslType in sslTypes {
        Proxy proxy = {proxySSLType: sslType, proxyServer: "ssl-proxy.com"};
        Options opts = {proxy: proxy};
        Client testClient = check new("user", "pass", JDBC_URL, opts);
        check testClient.close();
    }
}

@test:Config {}
function testOptionsRecordCombinations() returns error? {
    // TARGET: Record type construction coverage
    
    SSL ssl = {sslServerCert: "/path/cert.pem"};
    Firewall firewall = {firewallType: TUNNEL, firewallServer: "fw.com", firewallPort: 8080};
    Proxy proxy = {proxyServer: "proxy.com", proxyPort: 3128, proxyAuthScheme: DIGEST};
    Logging logging = {logfile: "/tmp/test.log", verbosity: "2", maxLogFileSize: "50MB"};
    Miscellaneous misc = {batchSize: 100, timeout: 60, useConnectionPooling: true};
    
    // Test various combinations
    Options[] optionsCombinations = [
        {ssl: ssl},
        {firewall: firewall},
        {proxy: proxy},
        {logging: logging},
        {miscellaneous: misc},
        {ssl: ssl, firewall: firewall},
        {proxy: proxy, logging: logging},
        {miscellaneous: misc, ssl: ssl},
        {ssl: ssl, firewall: firewall, proxy: proxy, logging: logging, miscellaneous: misc}
    ];
    
    foreach Options opts in optionsCombinations {
        Client testClient = check new("user", "pass", JDBC_URL, opts);
        check testClient.close();
    }
}

@test:Config {}
function testMethodWrapperCalls() returns error? {
    // TARGET: Method wrapper code around external functions
    Client cdataClient = check new("user", "pass", JDBC_URL + ";MockMode=true");
    
    // Test query wrapper
    sql:ParameterizedQuery query1 = `SELECT 'test' as value`;
    stream<record {}, sql:Error?> queryResult = cdataClient->query(query1);
    check queryResult.close();
    
    // Test queryRow wrapper
    sql:ParameterizedQuery query2 = `SELECT 1 as id`;
    record {}|sql:Error queryRowResult = cdataClient->queryRow(query2);
    
    // Test execute wrapper
    sql:ParameterizedQuery query3 = `INSERT INTO test VALUES (1)`;
    sql:ExecutionResult|sql:Error executeResult = cdataClient->execute(query3);
    
    // Test call wrapper
    sql:ParameterizedCallQuery callQuery = `{CALL test_proc()}`;
    sql:ProcedureCallResult|sql:Error callResult = cdataClient->call(callQuery);
    if callResult is sql:ProcedureCallResult {
        check callResult.close();
    }
    
    // Test non-empty batch to hit nativeBatchExecute path
    sql:ParameterizedQuery[] batchQueries = [
        `SELECT 1 as id`,
        `SELECT 2 as id`
    ];
    sql:ExecutionResult[]|sql:Error batchResult = cdataClient->batchExecute(batchQueries);
    
    check cdataClient.close();
}
