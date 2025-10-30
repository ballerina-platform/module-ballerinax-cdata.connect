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

@test:Config {enable: false}
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
    if optionsClient is error {
        test:assertFail(msg = "Client creation with options failed: " + optionsClient.message());
    } else {
        // Client type validated
        check optionsClient.close();
    }
}

@test:Config {enable: false}
function testClientConfigurationValidation() returns error? {
    SSL validSSL = {sslServerCert: "/valid/path/cert.pem"};
    
    Firewall validFirewall = {
        firewallType: TUNNEL,
        firewallServer: "firewall.example.com",
        firewallPort: 8080,
        firewallUser: "fwuser",
        firewallPassword: "fwpass"
    };
    
    Proxy validProxy = {
        proxyAutoDetect: false,
        proxyServer: "proxy.example.com",
        proxyPort: 3128,
        proxyAuthScheme: BASIC,
        proxyUser: "proxyuser",
        proxyPassword: "proxypass"
    };
    
    Logging validLogging = {
        logfile: "/tmp/cdata-client-test.log",
        verbosity: "3",
        logModules: "connection,query,transaction",
        maxLogFileSize: "25MB",
        maxLogFileCount: 5
    };
    
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
    
    Options comprehensiveOptions = {
        ssl: validSSL,
        firewall: validFirewall,
        proxy: validProxy,
        logging: validLogging,
        miscellaneous: validMisc
    };
    
    Client|sql:Error configClient = new(TEST_USER, TEST_PASSWORD, TEST_URL, comprehensiveOptions);
    if configClient is sql:Error {
        test:assertFail(msg = "Client creation with comprehensive options failed: " + configClient.message());
    } else {
        // Client type validated
        check configClient.close();
    }
}
