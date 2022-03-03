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
 
package io.ballerina.stdlib.java.jdbc.nativeimpl;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.java.jdbc.Constants;
import io.ballerina.stdlib.sql.datasource.SQLDatasource;
import io.ballerina.stdlib.sql.utils.ErrorGenerator;

import java.util.Properties;

/**
 * This class will include the native method implementation for the JDBC client.
 *
 * @since 1.0.0
 */
public class ClientProcessor {

    public static Object createClient(BObject client, BMap<BString, Object> clientConfig,
                                      BMap<BString, Object> globalPool) {
        String url = clientConfig.getStringValue(Constants.ClientConfiguration.URL).getValue();
        if (!isJdbcUrlValid(url)) {
            return ErrorGenerator.getSQLApplicationError("Invalid JDBC URL: " + url);
        }
        BString userVal = clientConfig.getStringValue(Constants.ClientConfiguration.USER);
        String user = userVal == null ? null : userVal.getValue();
        BString passwordVal = clientConfig.getStringValue(Constants.ClientConfiguration.PASSWORD);
        String password = passwordVal == null ? null : passwordVal.getValue();
        String datasourceName = null;
        String requestGeneratedKeys = Constants.RequestGeneratedKeysValues.ALL;

        BMap options = clientConfig.getMapValue(Constants.ClientConfiguration.OPTIONS);
        BMap<BString, Object> properties = ValueCreator.createMapValue();
        Properties poolProperties = null;

        if (options != null) {
            BString dataSourceNamVal = options.getStringValue(Constants.ClientConfiguration.DATASOURCE_NAME);
            datasourceName = dataSourceNamVal == null ? null : dataSourceNamVal.getValue();

            boolean isSslPresent = options.containsKey(Constants.Options.SSL);
            if (isSslPresent) {
                BMap sslMap = options.getMapValue(Constants.Options.SSL);
                if (sslMap.containsKey(Constants.SslConfig.SSL_SERVER_CERT)) {
                    properties.put(Constants.ConnectionStringProps.SSL_SERVER_CERT,
                            sslMap.getStringValue(Constants.SslConfig.SSL_SERVER_CERT));
                }
            }

            boolean isFirewallPresent = options.containsKey(Constants.Options.FIREWALL);
            if (isFirewallPresent) {
                BMap firewallMap = options.getMapValue(Constants.Options.FIREWALL);
                if (firewallMap.containsKey(Constants.FirewallConfig.FIREWALL_TYPE)) {
                    properties.put(Constants.ConnectionStringProps.FIREWALL_TYPE,
                            firewallMap.getStringValue(Constants.FirewallConfig.FIREWALL_TYPE));
                }
                if (firewallMap.containsKey(Constants.FirewallConfig.FIREWALL_SERVER)) {
                    properties.put(Constants.ConnectionStringProps.FIREWALL_SERVER,
                            firewallMap.getStringValue(Constants.FirewallConfig.FIREWALL_SERVER));
                }
                if (firewallMap.containsKey(Constants.FirewallConfig.FIREWALL_PORT)) {
                    properties.put(Constants.ConnectionStringProps.FIREWALL_PORT,
                            firewallMap.getIntValue(Constants.FirewallConfig.FIREWALL_PORT));
                }
                if (firewallMap.containsKey(Constants.FirewallConfig.FIREWALL_USER)) {
                    properties.put(Constants.ConnectionStringProps.FIREWALL_USER,
                            firewallMap.getStringValue(Constants.FirewallConfig.FIREWALL_USER));
                }
                if (firewallMap.containsKey(Constants.FirewallConfig.FIREWALL_PASSWORD)) {
                    properties.put(Constants.ConnectionStringProps.FIREWALL_PASSWORD,
                            firewallMap.getStringValue(Constants.FirewallConfig.FIREWALL_PASSWORD));
                }
            }

            boolean isProxyPresent = options.containsKey(Constants.Options.PROXY);
            if (isProxyPresent) {
                BMap proxyMap = options.getMapValue(Constants.Options.PROXY);
                if (proxyMap.containsKey(Constants.ProxyConfig.PROXY_AUTO_DETECT)) {
                    properties.put(Constants.ConnectionStringProps.PROXY_AUTO_DETECT,
                            proxyMap.getBooleanValue(Constants.ProxyConfig.PROXY_AUTO_DETECT));
                }
                if (proxyMap.containsKey(Constants.ProxyConfig.PROXY_SERVER)) {
                    properties.put(Constants.ConnectionStringProps.PROXY_SERVER,
                            proxyMap.getStringValue(Constants.ProxyConfig.PROXY_SERVER));
                }
                if (proxyMap.containsKey(Constants.ProxyConfig.PROXY_PORT)) {
                    properties.put(Constants.ConnectionStringProps.PROXY_PORT,
                            proxyMap.getIntValue(Constants.ProxyConfig.PROXY_PORT));
                }
                if (proxyMap.containsKey(Constants.ProxyConfig.PROXY_AUTH_SCHEMA)) {
                    properties.put(Constants.ConnectionStringProps.PROXY_AUTH_SCHEMA,
                            proxyMap.getStringValue(Constants.ProxyConfig.PROXY_AUTH_SCHEMA));
                }
                if (proxyMap.containsKey(Constants.ProxyConfig.PROXY_USER)) {
                    properties.put(Constants.ConnectionStringProps.PROXY_USER,
                            proxyMap.getStringValue(Constants.ProxyConfig.PROXY_USER));
                }
                if (proxyMap.containsKey(Constants.ProxyConfig.PROXY_PASSWORD)) {
                    properties.put(Constants.ConnectionStringProps.PROXY_PASSWORD,
                            proxyMap.getStringValue(Constants.ProxyConfig.PROXY_PASSWORD));
                }
                if (proxyMap.containsKey(Constants.ProxyConfig.PROXY_SSL_TYPE)) {
                    properties.put(Constants.ConnectionStringProps.PROXY_SSL_TYPE,
                            proxyMap.getStringValue(Constants.ProxyConfig.PROXY_SSL_TYPE));
                }
                if (proxyMap.containsKey(Constants.ProxyConfig.PROXY_EXCEPTIONS)) {
                    properties.put(Constants.ConnectionStringProps.PROXY_EXCEPTIONS,
                            proxyMap.getStringValue(Constants.ProxyConfig.PROXY_EXCEPTIONS));
                }
            }

            boolean isLoggingPresent = options.containsKey(Constants.Options.LOGGING);
            if (isLoggingPresent) {
                BMap loggingMap = options.getMapValue(Constants.Options.LOGGING);
                if (loggingMap.containsKey(Constants.LoggingConfig.LOG_FILE)) {
                    properties.put(Constants.ConnectionStringProps.LOG_FILE,
                            loggingMap.getStringValue(Constants.LoggingConfig.LOG_FILE));
                }
                if (loggingMap.containsKey(Constants.LoggingConfig.VERBOSITY)) {
                    properties.put(Constants.ConnectionStringProps.VERBOSITY,
                            loggingMap.getStringValue(Constants.LoggingConfig.VERBOSITY));
                }
                if (loggingMap.containsKey(Constants.LoggingConfig.LOG_MODULES)) {
                    properties.put(Constants.ConnectionStringProps.LOG_MODULES,
                            loggingMap.getStringValue(Constants.LoggingConfig.LOG_MODULES));
                }
                if (loggingMap.containsKey(Constants.LoggingConfig.MAX_LOG_FILE_SIZE)) {
                    properties.put(Constants.ConnectionStringProps.MAX_LOG_FILE_SIZE,
                            loggingMap.getStringValue(Constants.LoggingConfig.MAX_LOG_FILE_SIZE));
                }
                if (loggingMap.containsKey(Constants.LoggingConfig.MAX_LOG_FILE_COUNT)) {
                    properties.put(Constants.ConnectionStringProps.MAX_LOG_FILE_COUNT,
                            loggingMap.getStringValue(Constants.LoggingConfig.MAX_LOG_FILE_COUNT));
                }
            }

            boolean isMiscellaneousPresent = options.containsKey(Constants.Options.MISCELLANEOUS);
            if (isMiscellaneousPresent) {
                BMap miscellaneousMap = options.getMapValue(Constants.Options.SSL);
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.BATCH_SIZE)) {
                    properties.put(Constants.ConnectionStringProps.BATCH_SIZE,
                            miscellaneousMap.getIntValue(Constants.MiscellaneousConfig.BATCH_SIZE));
                }
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.CONNECTION_LIFE_TIME)) {
                    properties.put(Constants.ConnectionStringProps.CONNECTION_LIFE_TIME,
                            miscellaneousMap.getIntValue(Constants.MiscellaneousConfig.CONNECTION_LIFE_TIME));
                    poolProperties = new Properties();
                    poolProperties.setProperty(Constants.POOL_CONNECTION_TIMEOUT,
                            properties.get(Constants.ConnectionStringProps.CONNECTION_LIFE_TIME).toString());
                }
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.CONNECT_ON_OPEN)) {
                    properties.put(Constants.ConnectionStringProps.CONNECT_ON_OPEN,
                            miscellaneousMap.getBooleanValue(Constants.MiscellaneousConfig.CONNECT_ON_OPEN));
                }
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.MAX_ROWS)) {
                    properties.put(Constants.ConnectionStringProps.MAX_ROWS,
                            miscellaneousMap.getIntValue(Constants.MiscellaneousConfig.MAX_ROWS));
                }
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.OTHER)) {
                    properties.put(Constants.ConnectionStringProps.OTHER,
                            miscellaneousMap.getStringValue(Constants.MiscellaneousConfig.OTHER));
                }
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.POOL_IDLE_TIMEOUT)) {
                    properties.put(Constants.ConnectionStringProps.POOL_IDLE_TIMEOUT,
                            miscellaneousMap.getIntValue(Constants.MiscellaneousConfig.POOL_IDLE_TIMEOUT));
                }
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.POOL_MAX_SIZE)) {
                    properties.put(Constants.ConnectionStringProps.POOL_MAX_SIZE,
                            miscellaneousMap.getIntValue(Constants.MiscellaneousConfig.POOL_MAX_SIZE));
                }
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.POOL_MIN_SIZE)) {
                    properties.put(Constants.ConnectionStringProps.POOL_MIN_SIZE,
                            miscellaneousMap.getIntValue(Constants.MiscellaneousConfig.POOL_MIN_SIZE));
                }
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.POOL_WAIT_TIME)) {
                    properties.put(Constants.ConnectionStringProps.POOL_WAIT_TIME,
                            miscellaneousMap.getIntValue(Constants.MiscellaneousConfig.POOL_WAIT_TIME));
                }
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.PSEUDO_COLUMNS)) {
                    properties.put(Constants.ConnectionStringProps.PSEUDO_COLUMNS,
                            miscellaneousMap.getStringValue(Constants.MiscellaneousConfig.PSEUDO_COLUMNS));
                }
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.QUERY_PASS_THROUGH)) {
                    properties.put(Constants.ConnectionStringProps.QUERY_PASS_THROUGH,
                            miscellaneousMap.getBooleanValue(Constants.MiscellaneousConfig.QUERY_PASS_THROUGH));
                }
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.RTK)) {
                    properties.put(Constants.ConnectionStringProps.RTK,
                            miscellaneousMap.getStringValue(Constants.MiscellaneousConfig.RTK));
                }
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.TIMEOUT)) {
                    properties.put(Constants.ConnectionStringProps.TIMEOUT,
                            miscellaneousMap.getIntValue(Constants.MiscellaneousConfig.TIMEOUT));
                }
                if (miscellaneousMap.containsKey(Constants.MiscellaneousConfig.USE_CONNECTION_POOLING)) {
                    properties.put(Constants.ConnectionStringProps.USE_CONNECTION_POOLING,
                            miscellaneousMap.getBooleanValue(Constants.MiscellaneousConfig.USE_CONNECTION_POOLING));
                }
            }
        }

        BMap connectionPool = clientConfig.getMapValue(Constants.ClientConfiguration.CONNECTION_POOL_OPTIONS);

        SQLDatasource.SQLDatasourceParams sqlDatasourceParams = new SQLDatasource.SQLDatasourceParams()
                .setUrl(url)
                .setUser(user)
                .setPassword(password)
                .setDatasourceName(datasourceName)
                .setOptions(properties)
                .setPoolProperties(poolProperties)
                .setConnectionPool(connectionPool, globalPool);

        boolean executeGKFlag = false;
        boolean batchExecuteGKFlag = false;
        switch (requestGeneratedKeys) {
            case Constants.RequestGeneratedKeysValues.EXECUTE:
                executeGKFlag = true;
                break;
            case Constants.RequestGeneratedKeysValues.BATCH_EXECUTE:
                batchExecuteGKFlag = true;
                break;
            case Constants.RequestGeneratedKeysValues.ALL:
                executeGKFlag = true;
                batchExecuteGKFlag = true;
                break;
            default:
                break;
        }

        return io.ballerina.stdlib.sql.nativeimpl.ClientProcessor.createClient(client, sqlDatasourceParams,
                                                                               executeGKFlag, batchExecuteGKFlag);
    }

    // Unable to perform a complete validation since URL differs based on the database.
    private static boolean isJdbcUrlValid(String jdbcUrl) {
        return !jdbcUrl.isEmpty() && jdbcUrl.trim().startsWith("jdbc:");
    }

    public static Object close(BObject client) {
        return io.ballerina.stdlib.sql.nativeimpl.ClientProcessor.close(client);
    }
}
