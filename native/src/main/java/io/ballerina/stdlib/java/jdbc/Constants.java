/*
 * Copyright (c) 2022, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package io.ballerina.stdlib.java.jdbc;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BString;

/**
 * Constants for JDBC client.
 *
 * @since 1.0.0
 */
public final class Constants {
    /**
     * Constants for Endpoint Configs.
     */
    public static final class ClientConfiguration {
        public static final BString URL = StringUtils.fromString("url");
        public static final BString USER = StringUtils.fromString("user");
        public static final BString PASSWORD = StringUtils.fromString("password");
        public static final BString DATASOURCE_NAME = StringUtils.fromString("datasourceName");
        public static final BString REQUEST_GENERATED_KEYS = StringUtils.fromString("requestGeneratedKeys");
        public static final BString CONNECTION_POOL_OPTIONS = StringUtils.fromString("connectionPool");
        public static final BString OPTIONS = StringUtils.fromString("options");
        public static final BString PROPERTIES = StringUtils.fromString("properties");
    }

    public static final String CONNECT_TIMEOUT = ".*(connect).*(timeout).*";
    public static final String POOL_CONNECTION_TIMEOUT = "ConnectionTimeout";

    /**
     * Constants for Request Generated Keys field.
     */
    public static final class RequestGeneratedKeysValues {
        public static final String ALL = "ALL";
        public static final String EXECUTE = "EXECUTE";
        public static final String BATCH_EXECUTE = "BATCH_EXECUTE";
    }

    /**
     * Constants for connection string options.
     */
    public static final class Options {

        private Options() {
        }

        public static final BString SSL = StringUtils.fromString("ssl");
        public static final BString FIREWALL = StringUtils.fromString("firewall");
        public static final BString PROXY = StringUtils.fromString("proxy");
        public static final BString LOGGING = StringUtils.fromString("logging");
        public static final BString MISCELLANEOUS = StringUtils.fromString("miscellaneous");
    }

    /**
     * Constants for Connection string properties.
     */
    public static final class ConnectionStringProps {

        private ConnectionStringProps() {
        }
        // SSL
        public static final BString SSL_SERVER_CERT = StringUtils.fromString("SSLServerCert");
        // Firewall
        public static final BString FIREWALL_TYPE = StringUtils.fromString("FirewallType");
        public static final BString FIREWALL_SERVER = StringUtils.fromString("FirewallServer");
        public static final BString FIREWALL_PORT = StringUtils.fromString("FirewallPort");
        public static final BString FIREWALL_USER = StringUtils.fromString("FirewallUser");
        public static final BString FIREWALL_PASSWORD = StringUtils.fromString("FirewallPassword");
        // Proxy
        public static final BString PROXY_AUTO_DETECT = StringUtils.fromString("ProxyAutoDetect");
        public static final BString PROXY_SERVER = StringUtils.fromString("ProxyServer");
        public static final BString PROXY_PORT = StringUtils.fromString("ProxyPort");
        public static final BString PROXY_AUTH_SCHEMA = StringUtils.fromString("ProxyAuthScheme");
        public static final BString PROXY_USER = StringUtils.fromString("ProxyUser");
        public static final BString PROXY_PASSWORD = StringUtils.fromString("ProxyPassword");
        public static final BString PROXY_SSL_TYPE = StringUtils.fromString("ProxySSLType");
        public static final BString PROXY_EXCEPTIONS = StringUtils.fromString("ProxyExceptions");
        // Logging
        public static final BString LOG_FILE = StringUtils.fromString("Logfile");
        public static final BString VERBOSITY = StringUtils.fromString("Verbosity");
        public static final BString LOG_MODULES = StringUtils.fromString("LogModules");
        public static final BString MAX_LOG_FILE_SIZE = StringUtils.fromString("MaxLogFileSize");
        public static final BString MAX_LOG_FILE_COUNT = StringUtils.fromString("MaxLogFileCount");
        // Miscellaneous
        public static final BString BATCH_SIZE = StringUtils.fromString("BatchSize");
        public static final BString CONNECTION_LIFE_TIME = StringUtils.fromString("ConnectionLifeTime");
        public static final BString CONNECT_ON_OPEN = StringUtils.fromString("ConnectOnOpen");
        public static final BString MAX_ROWS = StringUtils.fromString("MaxRows");
        public static final BString OTHER = StringUtils.fromString("Other");
        public static final BString POOL_IDLE_TIMEOUT = StringUtils.fromString("PoolIdleTimeout");
        public static final BString POOL_MAX_SIZE = StringUtils.fromString("PoolMaxSize");
        public static final BString POOL_MIN_SIZE = StringUtils.fromString("PoolMinSize");
        public static final BString POOL_WAIT_TIME = StringUtils.fromString("PoolWaitTime");
        public static final BString PSEUDO_COLUMNS = StringUtils.fromString("PseudoColumns");
        public static final BString QUERY_PASS_THROUGH = StringUtils.fromString("QueryPassthrough");
        public static final BString RTK = StringUtils.fromString("RTK");
        public static final BString TIMEOUT = StringUtils.fromString("Timeout");
        public static final BString USE_CONNECTION_POOLING = StringUtils.fromString("UseConnectionPooling");
    }

    /**
     * Constants for SSL configuration.
     */
    public static final class SslConfig {

        private SslConfig() {
        }

        public static final BString SSL_SERVER_CERT = StringUtils.fromString("sslServerCert");
    }

    /**
     * Constants for Firewall configuration.
     */
    public static final class FirewallConfig {

        private FirewallConfig() {
        }

        public static final BString FIREWALL_TYPE = StringUtils.fromString("firewallType");
        public static final BString FIREWALL_SERVER = StringUtils.fromString("firewallServer");
        public static final BString FIREWALL_PORT = StringUtils.fromString("firewallPort");
        public static final BString FIREWALL_USER = StringUtils.fromString("firewallUser");
        public static final BString FIREWALL_PASSWORD = StringUtils.fromString("firewallPassword");
    }

    /**
     * Constants for Proxy configuration.
     */
    public static final class ProxyConfig {

        private ProxyConfig() {
        }

        public static final BString PROXY_AUTO_DETECT = StringUtils.fromString("ProxyAutoDetect");
        public static final BString PROXY_SERVER = StringUtils.fromString("ProxyServer");
        public static final BString PROXY_PORT = StringUtils.fromString("ProxyPort");
        public static final BString PROXY_AUTH_SCHEMA = StringUtils.fromString("ProxyAuthScheme");
        public static final BString PROXY_USER = StringUtils.fromString("ProxyUser");
        public static final BString PROXY_PASSWORD = StringUtils.fromString("ProxyPassword");
        public static final BString PROXY_SSL_TYPE = StringUtils.fromString("ProxySSLType");
        public static final BString PROXY_EXCEPTIONS = StringUtils.fromString("ProxyExceptions");
    }

    /**
     * Constants for Logging configuration.
     */
    public static final class LoggingConfig {

        private LoggingConfig() {
        }

        public static final BString LOG_FILE = StringUtils.fromString("logfile");
        public static final BString VERBOSITY = StringUtils.fromString("verbosity");
        public static final BString LOG_MODULES = StringUtils.fromString("logModules");
        public static final BString MAX_LOG_FILE_SIZE = StringUtils.fromString("maxLogFileSize");
        public static final BString MAX_LOG_FILE_COUNT = StringUtils.fromString("maxLogFileCount");
    }

    /**
     * Constants for Miscellaneous configuration.
     */
    public static final class MiscellaneousConfig {

        private MiscellaneousConfig() {
        }

        public static final BString BATCH_SIZE = StringUtils.fromString("batchSize");
        public static final BString CONNECTION_LIFE_TIME = StringUtils.fromString("connectionLifeTime");
        public static final BString CONNECT_ON_OPEN = StringUtils.fromString("connectOnOpen");
        public static final BString MAX_ROWS = StringUtils.fromString("maxRows");
        public static final BString OTHER = StringUtils.fromString("other");
        public static final BString POOL_IDLE_TIMEOUT = StringUtils.fromString("poolIdleTimeout");
        public static final BString POOL_MAX_SIZE = StringUtils.fromString("poolMaxSize");
        public static final BString POOL_MIN_SIZE = StringUtils.fromString("poolMinSize");
        public static final BString POOL_WAIT_TIME = StringUtils.fromString("poolWaitTime");
        public static final BString PSEUDO_COLUMNS = StringUtils.fromString("pseudoColumns");
        public static final BString QUERY_PASS_THROUGH = StringUtils.fromString("queryPassthrough");
        public static final BString RTK = StringUtils.fromString("rtk");
        public static final BString TIMEOUT = StringUtils.fromString("timeout");
        public static final BString USE_CONNECTION_POOLING = StringUtils.fromString("useConnectionPooling");
    }
}
