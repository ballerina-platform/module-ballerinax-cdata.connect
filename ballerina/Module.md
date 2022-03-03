## Overview
The [Ballerina](https://ballerina.io/) connector for [CData Connect](https://cloud.cdata.com/docs/JDBC.html) allows you to programmatically access all of the CData Connect applications, databases, APIs, and services across an organization via the Java Database Connectivity (JDBC) API using [Ballerina](https://ballerina.io/). 
For detailed information on working with each data source, see [Data Sources](https://cloud.cdata.com/docs/Data-Sources.html).
CData Connect supports a wide range of standard DDL commands, SQL commands, and SQL functions to query data sources. 
For reference information on all the CData Connect SQL commands (i.e., DDL, DML, and query syntax), see the [SQL Reference](https://cloud.cdata.com/docs/SQL-Reference.html).

## Prerequisites

Before using this connector in your Ballerina application, complete the following:

### To connect to CData Connect Cloud

* Create a [CData Connect Cloud](https://cloud.cdata.com) account.
* Obtain the CData Connect Cloud `username` and `password` from the CData Connect Cloud dashboard. 
    * `<username>` is the email address of the user. For example `user@cdata.com`.
    * `<password>` is a personal access token (PAT) that you generate from the **User Profile** page. For instructions on how to create a PAT to authenticate, see [Personal Access Tokens](https://cloud.cdata.com/docs/User-Profile.html#personal-access-tokens). The CData Connect Connector uses Basic AuthScheme.
* Make sure to go to the [Connections](https://cloud.cdata.com/docs/Connections.html) tab 
in the CData Connect Cloud dashboard and set up any connection you need to work with the data sources. 
You can use the **Connections** tab to configure a data source that contains the data you want to work with.

### To connect to CData Connect Server

* Run the CData Connect Server.
* Obtain the CData Connect Server `username` and `password`.
    * `<username>` is the username you use to login to CData Cloud Connect Server.
    * `<password>` is the password you use to login to CData Cloud Connect Server.
* Obtain the `<hostname>` and `<port>` where your CData Connect Server is up and running.
* Make sure to go to the `Connections` tab in the CData Connect Server dashboard and set up any connection you need to work with the data sources. 
You can use the **Connections** tab to configure a data source that contains the data you want to work with. 
 
## Quickstart

To use the CData Connect connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector and driver
Import the following modules into the Ballerina project:
```ballerina
import ballerina/sql;
import ballerinax/cdata.connect as cdata;      // Get the CData connector
import ballerinax/cdata.connect.driver as _;   // Get the CData driver
```

### Step 2: Create a new connector instance
Provide the `<username>`, `<password>` to initialize the Cdata Connect connector. 
Depending on your requirement, you can also pass optional properties and connection pool configurations during the client connector initialization. 
For more information on connection string properties, see [Connection String Options](https://cdn.cdata.com/help/LHG/jdbc/Connection.htm).

If you want to connect to CData Connect Cloud, you don't need to specify the `url`. 
The default value will be `jdbc:cdata:connect:AuthScheme=Basic`.

`<username>` is the email address of the user. For example `user@cdata.com`.
`<password>` is a personal access token (PAT) that you generate from the **User Profile** page.

```ballerina
string user = "<username>";
string password = "<password>";

cdata:Client cdataClient = check new (user, password);
```

If you want to connect to CData Connect Server, you need to specify the `url` as `jdbc:cdata:connect:URL=http://<hostname>:<port>/rest.rsc;`.
Replace the `<hostname>` and `<port>` with the information where your CData Cloud Connect Server is up and running.
`<username>` is the username you use to login to CData Cloud Connect Server.
`<password>` is the password you use to login to CData Cloud Connect Server.

```ballerina
string user = "<username>";
string password = "<password>";
string url = "jdbc:cdata:connect:URL=http://<hostname>:<port>/rest.rsc;";

cdata:Client cdataClient = check new (user, password, url);
```

You can also define `<username>`, `<password>` and `<url>` as configurable strings in your Ballerina program.

### Step 3: Invoke the connector operation
1. Use the CData Connect connector to consume the CData Connect API. When you write SQL queries, be sure to specify the **Connection Name** and **Data Source Name** in the [Connections](https://cloud.cdata.com/docs/Connections.html) tab of the CData Connect Cloud dashboard or in the CData Connect Server.

    Now let’s take a look at a few sample operations.

    Let’s assume,
    - `Salesforce1` is the connection name. 
    - `Salesforce` is the data source name. 

    Use the `query` operation to query data from the Salesforce API. 

    Following is a sample code to query data from a Salesforce table named `Lead`.

    ```ballerina
    public function main() error? {
        sql:ParameterizedQuery sqlQuery = `SELECT * FROM Salesforce1.Salesforce.Lead LIMIT 10`;
        stream<record {}, error?> resultStream = cdataClient->query(sqlQuery);

        check from record{} result in resultStream
            do {
                io:println("Full Lead details: ", result);
            };
    }
    ``` 

    Use the `execute` operation to perform DML and DDL operations.

    Following is a sample code to insert data into a Salesforce table named `Lead`

    ```ballerina
    public function main() error? {
        sql:ParameterizedQuery sqlQuery = `INSERT INTO Salesforce1.Salesforce.Lead (FirstName,
            LastName, Company) VALUES ('Roland', 'Hewage', 'WSO2')`;
        _ = check cdataClient->execute(sqlQuery);
    }
    ```

    Use the `batchExecute` operation to perform a batch of DML and DDL operations.

    Following is a sample code to insert multiple records into a Salesforce table named `Lead`

    ```ballerina
    public function main() error? {
        var insertRecords = [
            {
                FirstName: "Gloria",
                LastName: "Shania",
                Company: "ABC"
            }, 
            {
                FirstName: "Shane",
                LastName: "Warny",
                Company: "BCA"
            }, 
            {
                FirstName: "Neo",
                LastName: "Mark",
                Company: "CAB"
            }
        ];

        sql:ParameterizedQuery[] insertQueries = 
            from var data in insertRecords
            select `INSERT INTO Salesforce1.Salesforce.Lead
                    (FirstName, LastName, Company)
                    VALUES (${data.FirstName}, ${data.LastName}, ${data.Company})`;

        _ = check cdataClient->batchExecute(insertQueries);
    }
    ```
    Use the `call` operation to execute a stored procedure.

    Following is a sample code to execute the Salesforce stored procedure named `GetUserInformation`

    ```ballerina
    public function main() error? {
        sql:ParameterizedCallQuery sqlQuery = `{CALL Salesforce1.Salesforce.GetUserInformation()}`;
        sql:ProcedureCallResult retCall = check cdataClient->call(sqlQuery);

        stream<record {}, sql:Error?>? result = retCall.queryResult;
        if result is stream<record {}, sql:Error?> {
            stream<record {}, sql:Error?> informationStream = <stream<record {}, sql:Error?>>result;
            check from record {} information in informationStream
                do {
                    io:println("User details: ", information);
                };
        }

        check retCall.close();
    }
    ```

2. Use `bal run` command to compile and run the Ballerina program.
