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

@test:Config {}
function testSSLConfiguration() {
    // Test SSL configuration type (lines around SSL record)
    SSL sslConfig = {
        sslServerCert: "/path/to/server.crt"
    };
    
    test:assertEquals(sslConfig.sslServerCert, "/path/to/server.crt", 
                     msg = "SSL certificate path should be set correctly");
    
    // Test default value
    SSL defaultSSL = {};
    test:assertEquals(defaultSSL.sslServerCert, "", 
                     msg = "Default SSL certificate should be empty string");
}

@test:Config {}
function testFirewallConfiguration() {
    // Test Firewall configuration type with all values
    Firewall firewallConfig = {
        firewallType: TUNNEL,
        firewallServer: "firewall.example.com",
        firewallPort: 8080,
        firewallUser: "fwuser",
        firewallPassword: "fwpass"
    };
    
    test:assertEquals(firewallConfig.firewallType, TUNNEL, msg = "Firewall type should be TUNNEL");
    test:assertEquals(firewallConfig.firewallServer, "firewall.example.com", msg = "Firewall server should match");
    test:assertEquals(firewallConfig.firewallPort, 8080, msg = "Firewall port should match");
    test:assertEquals(firewallConfig.firewallUser, "fwuser", msg = "Firewall user should match");
    test:assertEquals(firewallConfig.firewallPassword, "fwpass", msg = "Firewall password should match");
    
    // Test default values
    Firewall defaultFirewall = {};
    test:assertEquals(defaultFirewall.firewallType, NONE, msg = "Default firewall type should be NONE");
    test:assertEquals(defaultFirewall.firewallServer, "", msg = "Default firewall server should be empty");
    test:assertEquals(defaultFirewall.firewallPort, 0, msg = "Default firewall port should be 0");
    test:assertEquals(defaultFirewall.firewallUser, "", msg = "Default firewall user should be empty");
    test:assertEquals(defaultFirewall.firewallPassword, "", msg = "Default firewall password should be empty");
}

@test:Config {}
function testProxyConfiguration() {
    // Test Proxy configuration type with all values
    Proxy proxyConfig = {
        proxyAutoDetect: true,
        proxyServer: "proxy.example.com",
        proxyPort: 3128,
        proxyAuthScheme: DIGEST,
        proxyUser: "proxyuser",
        proxyPassword: "proxypass",
        proxySSLType: ALWAYS,
        proxyExceptions: "localhost;127.0.0.1"
    };
    
    test:assertEquals(proxyConfig.proxyAutoDetect, true, msg = "Proxy auto detect should be true");
    test:assertEquals(proxyConfig.proxyServer, "proxy.example.com", msg = "Proxy server should match");
    test:assertEquals(proxyConfig.proxyPort, 3128, msg = "Proxy port should match");
    test:assertEquals(proxyConfig.proxyAuthScheme, DIGEST, msg = "Proxy auth scheme should be DIGEST");
    test:assertEquals(proxyConfig.proxyUser, "proxyuser", msg = "Proxy user should match");
    test:assertEquals(proxyConfig.proxyPassword, "proxypass", msg = "Proxy password should match");
    test:assertEquals(proxyConfig.proxySSLType, ALWAYS, msg = "Proxy SSL type should be ALWAYS");
    test:assertEquals(proxyConfig.proxyExceptions, "localhost;127.0.0.1", msg = "Proxy exceptions should match");
    
    // Test default values
    Proxy defaultProxy = {};
    test:assertEquals(defaultProxy.proxyAutoDetect, false, msg = "Default proxy auto detect should be false");
    test:assertEquals(defaultProxy.proxyServer, "", msg = "Default proxy server should be empty");
    test:assertEquals(defaultProxy.proxyPort, 80, msg = "Default proxy port should be 80");
    test:assertEquals(defaultProxy.proxyAuthScheme, BASIC, msg = "Default proxy auth should be BASIC");
    test:assertEquals(defaultProxy.proxyUser, "", msg = "Default proxy user should be empty");
    test:assertEquals(defaultProxy.proxyPassword, "", msg = "Default proxy password should be empty");
    test:assertEquals(defaultProxy.proxySSLType, AUTO, msg = "Default proxy SSL type should be AUTO");
    test:assertEquals(defaultProxy.proxyExceptions, "", msg = "Default proxy exceptions should be empty");
}

@test:Config {}
function testLoggingConfiguration() {
    // Test Logging configuration type
    Logging loggingConfig = {
        logfile: "/tmp/cdata.log",
        verbosity: "3",
        logModules: "query,connection",
        maxLogFileSize: "50MB",
        maxLogFileCount: 10
    };
    
    test:assertEquals(loggingConfig.logfile, "/tmp/cdata.log", msg = "Log file path should match");
    test:assertEquals(loggingConfig.verbosity, "3", msg = "Verbosity should match");
    test:assertEquals(loggingConfig.logModules, "query,connection", msg = "Log modules should match");
    test:assertEquals(loggingConfig.maxLogFileSize, "50MB", msg = "Max log file size should match");
    test:assertEquals(loggingConfig.maxLogFileCount, 10, msg = "Max log file count should match");
    
    // Test default values
    Logging defaultLogging = {};
    test:assertEquals(defaultLogging.logfile, "", msg = "Default log file should be empty");
    test:assertEquals(defaultLogging.verbosity, "1", msg = "Default verbosity should be 1");
    test:assertEquals(defaultLogging.logModules, "", msg = "Default log modules should be empty");
    test:assertEquals(defaultLogging.maxLogFileSize, "100MB", msg = "Default max log file size should be 100MB");
    test:assertEquals(defaultLogging.maxLogFileCount, -1, msg = "Default max log file count should be -1");
}

@test:Config {}
function testMiscellaneousConfiguration() {
    // Test Miscellaneous configuration type with all custom values
    Miscellaneous miscConfig = {
        batchSize: 500,
        connectionLifeTime: 1800,
        connectOnOpen: true,
        maxRows: 5000,
        other: "CustomProp=Value;AnotherProp=Test",
        poolIdleTimeout: 300,
        poolMaxSize: 25,
        poolMinSize: 3,
        poolWaitTime: 45,
        pseudoColumns: "exclude",
        queryPassthrough: false,
        rtk: "test-license-key",
        timeout: 90,
        useConnectionPooling: true
    };
    
    test:assertEquals(miscConfig.batchSize, 500, msg = "Batch size should match");
    test:assertEquals(miscConfig.connectionLifeTime, 1800, msg = "Connection lifetime should match");
    test:assertEquals(miscConfig.connectOnOpen, true, msg = "Connect on open should be true");
    test:assertEquals(miscConfig.maxRows, 5000, msg = "Max rows should match");
    test:assertEquals(miscConfig.other, "CustomProp=Value;AnotherProp=Test", msg = "Other properties should match");
    test:assertEquals(miscConfig.poolIdleTimeout, 300, msg = "Pool idle timeout should match");
    test:assertEquals(miscConfig.poolMaxSize, 25, msg = "Pool max size should match");
    test:assertEquals(miscConfig.poolMinSize, 3, msg = "Pool min size should match");
    test:assertEquals(miscConfig.poolWaitTime, 45, msg = "Pool wait time should match");
    test:assertEquals(miscConfig.pseudoColumns, "exclude", msg = "Pseudo columns should match");
    test:assertEquals(miscConfig.queryPassthrough, false, msg = "Query passthrough should be false");
    test:assertEquals(miscConfig.rtk, "test-license-key", msg = "RTK should match");
    test:assertEquals(miscConfig.timeout, 90, msg = "Timeout should match");
    test:assertEquals(miscConfig.useConnectionPooling, true, msg = "Use connection pooling should be true");
    
    // Test default values
    Miscellaneous defaultMisc = {};
    test:assertEquals(defaultMisc.batchSize, 0, msg = "Default batch size should be 0");
    test:assertEquals(defaultMisc.connectionLifeTime, 0, msg = "Default connection lifetime should be 0");
    test:assertEquals(defaultMisc.connectOnOpen, false, msg = "Default connect on open should be false");
    test:assertEquals(defaultMisc.maxRows, -1, msg = "Default max rows should be -1");
    test:assertEquals(defaultMisc.other, "", msg = "Default other should be empty");
    test:assertEquals(defaultMisc.poolIdleTimeout, 60, msg = "Default pool idle timeout should be 60");
    test:assertEquals(defaultMisc.poolMaxSize, 100, msg = "Default pool max size should be 100");
    test:assertEquals(defaultMisc.poolMinSize, 1, msg = "Default pool min size should be 1");
    test:assertEquals(defaultMisc.poolWaitTime, 60, msg = "Default pool wait time should be 60");
    test:assertEquals(defaultMisc.pseudoColumns, "", msg = "Default pseudo columns should be empty");
    test:assertEquals(defaultMisc.queryPassthrough, true, msg = "Default query passthrough should be true");
    test:assertEquals(defaultMisc.rtk, "", msg = "Default RTK should be empty");
    test:assertEquals(defaultMisc.timeout, 60, msg = "Default timeout should be 60");
    test:assertEquals(defaultMisc.useConnectionPooling, false, msg = "Default use connection pooling should be false");
}

@test:Config {}
function testEnumValues() {
    // Test FirewallType enum
    test:assertEquals(NONE, NONE, msg = "NONE firewall type should exist");
    test:assertEquals(TUNNEL, TUNNEL, msg = "TUNNEL firewall type should exist");
    test:assertEquals(SOCKS4, SOCKS4, msg = "SOCKS4 firewall type should exist");
    test:assertEquals(SOCKS5, SOCKS5, msg = "SOCKS5 firewall type should exist");
    
    // Test ProxyAuthScheme enum
    test:assertEquals(BASIC, BASIC, msg = "BASIC proxy auth should exist");
    test:assertEquals(DIGEST, DIGEST, msg = "DIGEST proxy auth should exist");
    test:assertEquals(NEGOTIATE, NEGOTIATE, msg = "NEGOTIATE proxy auth should exist");
    test:assertEquals(NTLM, NTLM, msg = "NTLM proxy auth should exist");
    test:assertEquals(PROPRIETARY, PROPRIETARY, msg = "PROPRIETARY proxy auth should exist");
    
    // Test ProxySSLType enum
    test:assertEquals(AUTO, AUTO, msg = "AUTO SSL type should exist");
    test:assertEquals(ALWAYS, ALWAYS, msg = "ALWAYS SSL type should exist");
    test:assertEquals(NEVER, NEVER, msg = "NEVER SSL type should exist");
    test:assertEquals(TUNNEL, TUNNEL, msg = "TUNNEL SSL type should exist");
}

@test:Config {}
function testOptionsConfiguration() {
    // Test complete Options configuration
    SSL ssl = {sslServerCert: "/path/cert.pem"};
    Firewall firewall = {firewallType: SOCKS5, firewallServer: "fw.test.com"};
    Proxy proxy = {proxyServer: "proxy.test.com", proxyPort: 8080};
    Logging logging = {logfile: "/tmp/test.log", verbosity: "2"};
    Miscellaneous misc = {batchSize: 100, timeout: 30};
    
    Options options = {
        ssl: ssl,
        firewall: firewall,
        proxy: proxy,
        logging: logging,
        miscellaneous: misc
    };
    
    test:assertTrue(options.ssl is SSL, msg = "SSL should be configured");
    test:assertTrue(options.firewall is Firewall, msg = "Firewall should be configured");
    test:assertTrue(options.proxy is Proxy, msg = "Proxy should be configured");
    test:assertTrue(options.logging is Logging, msg = "Logging should be configured");
    test:assertTrue(options.miscellaneous is Miscellaneous, msg = "Miscellaneous should be configured");
    
    // Test empty options
    Options emptyOptions = {};
    test:assertTrue(emptyOptions.ssl is (), msg = "SSL should be optional");
    test:assertTrue(emptyOptions.firewall is (), msg = "Firewall should be optional");
    test:assertTrue(emptyOptions.proxy is (), msg = "Proxy should be optional");
    test:assertTrue(emptyOptions.logging is (), msg = "Logging should be optional");
    test:assertTrue(emptyOptions.miscellaneous is (), msg = "Miscellaneous should be optional");
}

@test:Config {}
function testJDBCURL() {
    // Test the JDBC_URL constant (line 133)
    test:assertEquals(JDBC_URL, "jdbc:cdata:connect:AuthScheme=Basic", 
                     msg = "JDBC URL should match expected value");
}
