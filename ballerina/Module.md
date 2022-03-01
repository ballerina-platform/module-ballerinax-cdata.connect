## Overview
The [Ballerina](https://ballerina.io/) connector for [CData Connect Cloud](https://cloud.cdata.com/docs/JDBC.html) allows you to programmatically access all of the CData Connect Cloud applications, databases, APIs, and services across an organization via the Java Database Connectivity (JDBC) API using [Ballerina](https://ballerina.io/). 
For detailed information on working with each data source, see [Data Sources](https://cloud.cdata.com/docs/Data-Sources.html).
CData Connect Cloud supports a wide range of standard DDL commands, SQL commands, and SQL functions to query data sources. 
For reference information on all the CData Connect Cloud SQL commands (i.e., DDL, DML, and query syntax), see the [SQL Reference](https://cloud.cdata.com/docs/SQL-Reference.html).

## Prerequisites

Before using this connector in your Ballerina application, complete the following:

* Create a [CData Connect Cloud](https://cloud.cdata.com) account.
* Obtain the CData cloud `username` and `password` from the CData Cloud dashboard. 
    * `<username>` is the email address of the user. For example `user@cdata.com`.
    * `<password>` is a personal access token (PAT) that you generate from the **User Profile** page. For instructions on how to create a PAT to authenticate, see [Personal Access Tokens](https://cloud.cdata.com/docs/User-Profile.html#personal-access-tokens). The Ballerina connector for CData Connect Cloud uses Basic AuthSchema by default to connect.
* Make sure to go to the [Connections](https://cloud.cdata.com/docs/Connections.html) tab 
in the CData Cloud dashboard and set up any connection you need to work with the data sources. 
You can use the **Connections** tab to configure a data source that contains the data you want to work with. 
For more information on working with each data source, see [Data Sources](https://cloud.cdata.com/docs/Data-Sources.html).
Use the **Connection Name** and **Data Source Name** to write your SQL queries.
 
## Quickstart

To use the CData Connect Cloud connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector and driver
Import the following modules into the Ballerina project:
```ballerina
import ballerina/sql;
import ballerinax/cdata.connect as cdata;      // Get the CData connector
import ballerinax/cdata.connect.driver as _;   // Get the CData driver
```

### Step 2: Create a new connector instance
Provide the `<username>`, `<password>` to initialize the Cdata Connect client connector. 
Depending on your requirement, you can also pass optional properties and connection pool configurations during the client connector initialization. 
For more information on connection string properties, see [Connection String Options](https://cdn.cdata.com/help/LHG/jdbc/Connection.htm).

`<username>` is the email address of the user. For example `user@cdata.com`.
`<password>` is a personal access token (PAT) that you generate from the **User Profile** page.

```ballerina
string user = "<username>";
string password = "<password>";

cdata:Client cdataClient = check new (user, password);
```
You can also define `<username>` and `<password>` as configurable strings in your Ballerina program.

### Step 3: Invoke the connector operation
1. Use the Ballerina CData Connect client connector to consume the CData Connect Cloud API. For more information on working with each data source, see [Data Sources](https://cloud.cdata.com/docs/Data-Sources.html). When you write SQL queries, be sure to specify the **Connection Name** and **Data Source Name** in the [Connections](https://cloud.cdata.com/docs/Connections.html) tab of the CData Cloud dashboard.

    Now let’s take a look at a few sample operations.

    Use the `query` operation to query data from the Salesforce API. 
    Let’s assume,
    - `Salesforce1` is the connection name. 
    - `Salesforce` is the data source name. 
    - `Lead` is the table name.

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
    Let’s assume,
    - `Salesforce1` is the connection name. 
    - `Salesforce` is the data source name. 
    - `Lead` is the table name.

    Following is a sample code to insert data into a Salesforce table named `Lead`

    ```ballerina
    public function main() error? {
        sql:ParameterizedQuery sqlQuery = `INSERT INTO Salesforce1.Salesforce.Lead (FirstName,
            LastName, Company) VALUES ('Roland', 'Hewage', 'WSO2')`;
        _ = check cdataClient->execute(sqlQuery);
    }
    ```

    Use the `batchExecute` operation to perform a batch of DML and DDL operations.
    Let’s assume,
    - `Salesforce1` is the connection name. 
    - `Salesforce` is the data source name. 
    - `Lead` is the table name.

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
    Let’s assume,
    - `Salesforce1` is the connection name. 
    - `Salesforce` is the data source name. 
    - `GetUserInformation` is the stored procedure name.

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
