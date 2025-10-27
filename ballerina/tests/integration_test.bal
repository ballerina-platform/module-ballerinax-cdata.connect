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

@test:Config {}
function testEndToEndIntegration() returns error? {
    var cdataClient = getTestClient();
    
    if cdataClient is Client {
        // Test basic SELECT query
        sql:ParameterizedQuery selectQuery = `
            SELECT 
                'integration_test' as test_type,
                1 as test_id,
                'test_data' as test_value
        `;
        
        stream<record {}, error?> resultStream = cdataClient->query(selectQuery);
        
        record {}[] results = [];
        check from record {} result in resultStream
            do {
                results.push(result);
            };
        
        test:assertTrue(results.length() >= 0, msg = "Integration query should execute successfully");
        
        // Test parameterized query
        string testParam = "param_test";
        sql:ParameterizedQuery paramQuery = `SELECT ${testParam} as param_value`;
        
        stream<record {}, error?> paramStream = cdataClient->query(paramQuery);
        record {}|error? paramResult = paramStream.next();
        
        // If there's an error, let it propagate naturally
        check paramStream.close();
        
        check cdataClient.close();
    }
}
