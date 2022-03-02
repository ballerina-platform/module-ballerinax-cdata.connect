// Copyright (c) 2022 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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

import ballerina/jballerina.java;
import ballerina/sql;

# The [Ballerina](https://ballerina.io/) connector for [CData Connect](https://cloud.cdata.com/docs/JDBC.html) 
# allows you to programmatically access all of the CData Connect applications, databases, APIs, and services
# across an organization via the Java Database Connectivity (JDBC) API using [Ballerina](https://ballerina.io/). 
# For detailed information on working with each data source, see [Data Sources](https://cloud.cdata.com/docs/Data-Sources.html).
# CData Connect supports a wide range of standard DDL commands, SQL commands, and SQL functions to query data sources. 
# For reference information on all the CData Connect SQL commands (i.e., DDL, DML, and query syntax), 
# see the [SQL Reference](https://cloud.cdata.com/docs/SQL-Reference.html).
@display {label: "CData Connect", iconPath: "icon.png"}
public isolated client class Client {
    *sql:Client;

    # Gets invoked to initialize the `connector`.
    # The connector initialization requires setting the CData Connect `username` and `password`.
    # If you want to connect to CData Connect Cloud, you don't need to specify the `url`. 
    # The default value will be `jdbc:cdata:connect:AuthScheme=Basic`. It uses Basic AuthSchema by default to connect.
    # Create a [CData Connect Cloud account](https://cloud.cdata.com) and obtain the CData cloud `username` and `password` 
    # from the CData Cloud dashboard. 
    # `<username>` is the email address of the user. For example `user@cdata.com`. 
    # `<password>` is a personal access token (PAT) that you generate from the **User Profile** page. 
    # For instructions on how to create a PAT to authenticate, see [Personal Access Tokens](https://cloud.cdata.com/docs/User-Profile.html#personal-access-tokens). 
    # If you want to connect to CData Connect Server, you need to specify the `url` as `jdbc:cdata:connect:URL=http://<hostname>:<port>/rest.rsc;`.
    # Replace the `<hostname>` and `<port>` with the information where your CData Cloud Connect Server is up and running.
    # `<username>` is the username you use to login to CData Cloud Connect Server.
    # `<password>` is the password you use to login to CData Cloud Connect Server.
    # Make sure to go to the [Connections](https://cloud.cdata.com/docs/Connections.html) tab in the CData Connect Cloud dashboard 
    # or in the CData Connect Server and set up any connection you need to work with the data sources. 
    # You can use the **Connections** tab to configure a data source that contains the data you want to work with. 
    # For more information on working with each data source, see [Data Sources](https://cloud.cdata.com/docs/Data-Sources.html).
    # Use the **Connection Name** and **Data Source Name** to write your SQL queries.
    # 
    # + user - The user name of the CData Connect user
    # + password - The password for the CData Connect user
    # + url - The JDBC URL to be used for the CData Connect connection
    # + options - The CData Connect connection string options
    # + connectionPool - The `sql:ConnectionPool` to be used for the connection. If there is no
    #                    `connectionPool` provided, the global connection pool (shared by all clients) will be used
    # + return - An `sql:Error` if the client creation fails
    public isolated function init(string user, string password, string url = JDBC_URL,
        Options? options = (), sql:ConnectionPool? connectionPool = ()) returns sql:Error? {
        ClientConfiguration clientConf = {
            url: url,
            user: user,
            password: password,
            options: options,
            connectionPool: connectionPool
        };
        return createClient(self, clientConf, sql:getGlobalConnectionPool());
    }

    # Executes the query, which may return multiple results.
    #
    # + sqlQuery - The SQL query such as `` `SELECT * from Album WHERE name={albumName}` ``
    # + rowType - The `typedesc` of the record to which the result needs to be returned
    # + return - Stream of records in the `rowType` type
    remote isolated function query(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>)
    returns stream<rowType, sql:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.QueryProcessor",
        name: "nativeQuery"
    } external;

    # Executes the query, which is expected to return at most one row of the result.
    # If the query does not return any results, an `sql:NoRowsError` is returned.
    #
    # + sqlQuery - The SQL query such as `` `SELECT * from Album WHERE name={albumName}` ``
    # + returnType - The `typedesc` of the record to which the result needs to be returned.
    #                It can be a basic type if the query result contains only one column
    # + return - Result in the `returnType` type or an `sql:Error`
    remote isolated function queryRow(sql:ParameterizedQuery sqlQuery, typedesc<anydata> returnType = <>)
    returns returnType|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.QueryProcessor",
        name: "nativeQueryRow"
    } external;

    # Executes the SQL query. Only the metadata of the execution is returned (not the results from the query).
    #
    # + sqlQuery - The SQL query such as `` `DELETE FROM Album WHERE artist={artistName}` ``
    # + return - Metadata of the query execution as an `sql:ExecutionResult` or an `sql:Error`
    remote isolated function execute(sql:ParameterizedQuery sqlQuery)
    returns sql:ExecutionResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.ExecuteProcessor",
        name: "nativeExecute"
    } external;

    # Executes the SQL query with multiple sets of parameters in a batch. 
    # Only the metadata of the execution is returned (not results from the query).
    # If one of the commands in the batch fails, this will return an `sql:BatchExecuteError`. However, the driver may
    # or may not continue to process the remaining commands in the batch after a failure.
    #
    # + sqlQueries - The SQL query with multiple sets of parameters
    # + return - Metadata of the query execution as an `sql:ExecutionResult[]` or an `sql:Error`
    remote isolated function batchExecute(sql:ParameterizedQuery[] sqlQueries) returns sql:ExecutionResult[]|sql:Error {
        if sqlQueries.length() == 0 {
            return error sql:ApplicationError(" Parameter 'sqlQueries' cannot be empty array");
        }
        return nativeBatchExecute(self, sqlQueries);
    }

    # Executes a SQL query, which calls a stored procedure. This may or may not return results.
    #
    # + sqlQuery - The SQL query such as `` `CALL sp_GetAlbums();` ``
    # + rowTypes - `typedesc` array of the records to which the results need to be returned
    # + return - Summary of the execution and results are returned in an `sql:ProcedureCallResult`, or an `sql:Error`
    remote isolated function call(sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes = [])
    returns sql:ProcedureCallResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.CallProcessor",
        name: "nativeCall"
    } external;

    # Closes the SQL client and shuts down the connection pool.
    #
    # + return - Possible error when closing the client
    public isolated function close() returns sql:Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.ClientProcessor",
        name: "close"
    } external;
}

// The JDBC URL to be used for the CData cloud connect connection
const string JDBC_URL = "jdbc:cdata:connect:AuthScheme=Basic";

# The connection string properties are the various options that can be used to establish a connection.
#
# + ssl - SSL properties
# + firewall - Firewall properties 
# + proxy - Proxy properties
# + logging - Logging properties 
# + miscellaneous - Miscellaneous properties
public type Options record {|
    SSL ssl?;
    Firewall firewall?;
    Proxy proxy?;
    Logging logging?;
    Miscellaneous miscellaneous?;
|};

# SSL properties you can configure in the connection string for this provider.
#
# + sslServerCert - The certificate to be accepted from the server when connecting using TLS/SSL
public type SSL record {|
    string sslServerCert = "";
|};

# Firewall properties you can configure in the connection string for this provider. 
#
# + firewallType - The protocol used by a proxy-based firewall 
# + firewallServer - The name or IP address of a proxy-based firewall
# + firewallPort - The TCP port for a proxy-based firewall
# + firewallUser - The user name to use to authenticate with a proxy-based firewall
# + firewallPassword - A password used to authenticate to a proxy-based firewall
public type Firewall record {|
    FirewallType firewallType = NONE;
    string firewallServer = "";
    int firewallPort = 0;
    string firewallUser = "";
    string firewallPassword = "";
|};

# Proxy properties you can configure in the connection string for this provider. 
#
# + proxyAutoDetect - This indicates whether to use the system proxy settings or not. 
#                     This takes precedence over other proxy settings, so you'll need to set ProxyAutoDetect to FALSE 
#                     in order use custom proxy settings 
# + proxyServer - The hostname or IP address of a proxy to route HTTP traffic through
# + proxyPort - The TCP port the ProxyServer proxy is running on  
# + proxyAuthScheme - The authentication type to use to authenticate to the ProxyServer proxy
# + proxyUser - A user name to be used to authenticate to the ProxyServer proxy
# + proxyPassword - A password to be used to authenticate to the ProxyServer proxy 
# + proxySSLType - The SSL type to use when connecting to the ProxyServer proxy
# + proxyExceptions - A semicolon separated list of destination hostnames or IPs that are exempt from connecting 
#                     through the ProxyServer
public type Proxy record {|
    boolean proxyAutoDetect = false;
    string proxyServer = "";
    int proxyPort = 80;
    ProxyAuthScheme proxyAuthScheme = BASIC;
    string proxyUser = "";
    string proxyPassword = "";
    ProxySSLType proxySSLType = AUTO;
    string proxyExceptions = "";
|};

# Logging properties you can configure in the connection string for this provider. 
#
# + logfile - A filepath which designates the name and location of the log file 
# + verbosity - The verbosity level that determines the amount of detail included in the log file
# + logModules - Core modules to be included in the log file
# + maxLogFileSize - A string specifying the maximum size in bytes for a log file (for example, 10 MB)
# + maxLogFileCount - A string specifying the maximum file count of log files
public type Logging record {|
    string logfile = "";
    string verbosity = "1";
    string logModules = "";
    string maxLogFileSize = "100MB";
    int maxLogFileCount = -1;
|};

# Miscellaneous properties you can configure in the connection string for this provider. 
#
# + batchSize - The maximum size of each batch operation to submit
# + connectionLifeTime - The maximum lifetime of a connection in seconds. Once the time has elapsed, 
#                        the connection object is disposed 
# + connectOnOpen - This property species whether to connect to the CData Cloud when the connection is opened 
# + maxRows - Limits the number of rows returned rows when no aggregation or group by is used in the query. 
#             This helps avoid performance issues at design time 
# + other - These hidden properties are used only in specific use cases 
# + poolIdleTimeout - The allowed idle time for a connection before it is closed
# + poolMaxSize - The maximum connections in the pool  
# + poolMinSize - The minimum number of connections in the pool
# + poolWaitTime - The max seconds to wait for an available connection
# + pseudoColumns - This property indicates whether or not to include pseudo columns as columns to the table
# + queryPassthrough - This option passes the query to the CData Cloud server as is
# + rtk - The runtime key used for licensing  
# + timeout - The query timeout 
# + useConnectionPooling - This property enables connection pooling
public type Miscellaneous record {|
    int batchSize = 0;
    int connectionLifeTime = 0;
    boolean connectOnOpen = false;
    int maxRows = -1;
    string other = "";
    int poolIdleTimeout = 60;
    int poolMaxSize = 100;
    int poolMinSize = 1;
    int poolWaitTime = 60;
    string pseudoColumns = "";
    boolean queryPassthrough = true;
    string rtk = "";
    int timeout = 60;
    boolean useConnectionPooling = false;
|};

# Constants to represent firewall types.
public enum FirewallType {
    NONE,
    TUNNEL,
    SOCKS4,
    SOCKS5
}

# Constants to represent proxy auth schemes.
public enum ProxyAuthScheme {
    BASIC,
    DIGEST,
    NONE,
    NEGOTIATE,
    NTLM,
    PROPRIETARY
}

# Constants to represent proxy SSL types.
public enum ProxySSLType {
    AUTO,
    ALWAYS,
    NEVER,
    TUNNEL
}

# An additional set of configurations for the JDBC Client to be passed internally within the module.
#
# + url - The JDBC URL to be used for the database connection
# + user - If the database is secured, the username
# + password - The password of the database associated with the provided username
# + options - The JDBC client properties
# + connectionPool - The `sql:ConnectionPool` to be used for the connection. If there is no `connectionPool` provided,
#                    the global connection pool (shared by all clients) will be used
type ClientConfiguration record {|
    string? url;
    string? user;
    string? password;
    Options? options;
    sql:ConnectionPool? connectionPool;
|};

isolated function createClient(Client jdbcClient, ClientConfiguration clientConf,
    sql:ConnectionPool globalConnPool) returns sql:Error? = @java:Method {
    'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.ClientProcessor"
} external;

isolated function nativeBatchExecute(Client sqlClient, string[]|sql:ParameterizedQuery[] sqlQueries)
returns sql:ExecutionResult[]|sql:Error = @java:Method {
    'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.ExecuteProcessor"
} external;
