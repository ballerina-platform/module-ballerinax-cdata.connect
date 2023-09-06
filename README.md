Ballerina CData Connect Connector
===================

[![Build](https://github.com/ballerina-platform/module-ballerinax-cdata.connect/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-cdata.connect/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/ballerina-platform/module-ballerinax-cdata.connect/branch/main/graph/badge.svg)](https://codecov.io/gh/ballerina-platform/module-ballerinax-cdata.connect)
[![Trivy](https://github.com/ballerina-platform/module-ballerinax-cdata.connect/actions/workflows/trivy-scan.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-cdata.connect/actions/workflows/trivy-scan.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-cdata.connect.svg)](https://github.com/ballerina-platform/module-ballerinax-cdata.connect/commits/master)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-cdata.connect/actions/workflows/build-with-bal-test-native.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-cdata.connect/actions/workflows/build-with-bal-test-native.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[CData Connect](https://www.cdata.com/connect) is a consolidated connectivity platform that links applications, on-premises or in the cloud to a broad ecosystem of real-time data sources through consistent, standards-compliant interfaces. CData Connect provides tools to seamlessly access data from any system, anywhere.

The CData Connect [Ballerina](https://ballerina.io/) connector allows you to programmatically access all of the CData Connect applications, databases, APIs, services via the Java Database Connectivity (JDBC) API. 
It provides operations to execute a wide range of standard DDL Commands, SQL Commands, and SQL Functions for querying data sources. 
You can find reference information for all the CData Connect SQL commands (DDL, DML, and query syntax) [here](https://cloud.cdata.com/docs/SQL-Reference.html).

For more information, go to the module(s).
- [cdata.connect](Module.md)

## Building from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 17. You can install either [OpenJDK](https://adoptopenjdk.net/) or [Oracle](https://www.oracle.com/java/technologies/downloads/).

    > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/). 

### Building the source

Execute the commands below to build from the source.

- To build the library:
    ```shell
    ./gradlew clean build
    ```
- To run the integration tests: 
    ```shell
    ./gradlew clean test
    ```

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community. 

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* Discuss the code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
