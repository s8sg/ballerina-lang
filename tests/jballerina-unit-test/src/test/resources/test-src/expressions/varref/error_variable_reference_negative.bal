// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

type SMS error <string, record {| string...; |}>;
type SMA error <string, record {| string|boolean...; |}>;

function testBasicErrorVariableWithMapDetails() {
    SMS err1 = error("Error One", message = "Msg One", detail = "Detail Msg");
    SMA err2 = error("Error Two", message = "Msg Two", fatal = true);

    boolean reason11; // expected 'boolean', found 'string'
    map<int> detail11; // expected 'map<int>', found 'map<string>'
    string reason12;
    string? message12;
    string detail12; // expected 'string', found 'string?'
    string? extra12;

    error (reason11, ... detail11) = err1;
    error (reason12, message = message12, detail = detail12, extra = extra12) = err1;

    string reason21;
    map<string> detail21; // expected 'map<string>', found 'map<any>'
    string reason22;
    any message22;
    string detail22; // expected 'string', found 'any'
    any extra22;

    error (reason21, ...detail21) = err2;
    error (reason22, message = message22, detail = detail22, extra = extra22) = err2;
    error (reason22, message = message22, detail = detail22, extra = extra22) = error("reason", a = detail11["a"]); // error constructor expression is not supported for error binding pattern
}

type Foo record {
    string message;
    boolean fatal;
};

type FooError error <string, Foo>;

function testBasicErrorVariableWithRecordDetails() {
    FooError err1 = error("Error One", message = "Something Wrong", fatal = true);
    FooError err2 = error("Error One", message = "Something Wrong", fatal = true);

    string res1;
    map<any> rec; // expected 'map', found 'Foo'
    string res2;
    boolean message; // 'boolean', found 'string'
    any fatal;

    error (res1, ...rec) = err1;
    error (res2, message = message, fatal = fatal) = err2;
}

function testErrorInTuple() {
    Foo f = { message: "fooMsg", fatal: true };
    [int, string, error, [error, Foo]] t1 = [12, "Bal", error("Err", message = "Something Wrong"),
                                                        [error("Err2", message = "Something Wrong2"), f]];

    any intVar;
    string stringVar;
    map<any> errorVar;
    error errorVar2;
    any fooVar;

    [intVar, stringVar, errorVar, [errorVar2, fooVar]] = t1; // expected '(any,string,map,(error,any))', found '(int,string,error,(error,Foo))'
}

type Bar record {
    int x;
    error e;
};

function testErrorInRecordWithDestructure() {
    Bar b = { x: 1000, e: error("Err3", message = "Something Wrong3") };
    int x;
    boolean reason;
    Bar detail;
    map<anydata|error> detail2;
    { x, e: error (reason, ... detail) } = b;
    { x, e: error (reason, ... detail2) } = b;
}

function testErrorInRecordWithDestructure2() {
    Bar b = { x: 1000, e: error("Err3", message = "Something Wrong3") };
    int x;
    string reason;
    string? message;
    anydata|error extra;
    { x, e: error (reason, message = message, extra = extra) } = b;
}

function testBasicErrorVariableWithIndexBasedRef() returns map<anydata|error> {
    FooError err1 = error("Error One", message = "Something Wrong", fatal = true);

    map<map<anydata|error>> results = {};

    error (results["res1"]["reason"], ...results["rec"]) = err1;
    error (results["res2"]["reason"], message = results["detail"]["message"], fatal = results["detail"]["fatal"]) = err1;

    return results;
}
