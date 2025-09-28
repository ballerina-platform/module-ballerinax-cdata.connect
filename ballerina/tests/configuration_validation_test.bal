import ballerina/test;

@test:Config {}
function testSSLConfiguration() {
    SSL sslConfig = {
        sslServerCert: "/path/to/server.crt"
    };
    
    test:assertEquals(sslConfig.sslServerCert, "/path/to/server.crt", 
                     msg = "SSL certificate path should be set correctly");
    
    SSL defaultSSL = {};
    test:assertEquals(defaultSSL.sslServerCert, "", 
                     msg = "Default SSL certificate should be empty");
}

@test:Config {}
function testFirewallConfiguration() {
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
    
    Firewall defaultFirewall = {};
    test:assertEquals(defaultFirewall.firewallType, NONE, msg = "Default firewall type should be NONE");
}

@test:Config {}
function testProxyConfiguration() {
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
    test:assertEquals(proxyConfig.proxyAuthScheme, DIGEST, msg = "Proxy auth scheme should be DIGEST");
    
    Proxy defaultProxy = {};
    test:assertEquals(defaultProxy.proxyAutoDetect, false, msg = "Default proxy auto detect should be false");
    test:assertEquals(defaultProxy.proxyPort, 80, msg = "Default proxy port should be 80");
}

@test:Config {}
function testLoggingConfiguration() {
    Logging loggingConfig = {
        logfile: "/tmp/cdata.log",
        verbosity: "3",
        logModules: "query,connection",
        maxLogFileSize: "50MB",
        maxLogFileCount: 10
    };
    
    test:assertEquals(loggingConfig.logfile, "/tmp/cdata.log", msg = "Log file path should match");
    test:assertEquals(loggingConfig.verbosity, "3", msg = "Verbosity should match");
    test:assertEquals(loggingConfig.maxLogFileCount, 10, msg = "Max log file count should match");
    
    Logging defaultLogging = {};
    test:assertEquals(defaultLogging.verbosity, "1", msg = "Default verbosity should be 1");
}

@test:Config {}
function testMiscellaneousConfiguration() {
    Miscellaneous miscConfig = {
        batchSize: 500,
        timeout: 90,
        useConnectionPooling: true,
        maxRows: 5000
    };
    
    test:assertEquals(miscConfig.batchSize, 500, msg = "Batch size should match");
    test:assertEquals(miscConfig.timeout, 90, msg = "Timeout should match");
    test:assertEquals(miscConfig.useConnectionPooling, true, msg = "Use connection pooling should be true");
    
    Miscellaneous defaultMisc = {};
    test:assertEquals(defaultMisc.timeout, 60, msg = "Default timeout should be 60");
    test:assertEquals(defaultMisc.useConnectionPooling, false, msg = "Default connection pooling should be false");
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
    
    // Test ProxySSLType enum
    test:assertEquals(AUTO, AUTO, msg = "AUTO SSL type should exist");
    test:assertEquals(ALWAYS, ALWAYS, msg = "ALWAYS SSL type should exist");
    test:assertEquals(NEVER, NEVER, msg = "NEVER SSL type should exist");
}

@test:Config {}
function testOptionsConfiguration() {
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
}

@test:Config {}
function testJDBCURL() {
    test:assertEquals(JDBC_URL, "jdbc:cdata:connect:AuthScheme=Basic", 
                     msg = "JDBC URL should match expected value");
}