// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

# LoadBalanceClient endpoint provides load balancing functionality over multiple HTTP clients.
#
# + loadBalanceClientConfig - The configurations for the load balance client endpoint
# + loadBalanceClientsArray - Array of HTTP clients for load balancing
# + lbRule - Load balancing rule
# + failover - Whether to fail over in case of a failure
public type LoadBalanceClient client object {

    public LoadBalanceClientEndpointConfiguration loadBalanceClientConfig;
    public Client?[] loadBalanceClientsArray;
    public LoadBalancerRule lbRule;
    public boolean failover;

    # Load Balancer adds an additional layer to the HTTP client to make network interactions more resilient.
    #
    # + loadBalanceClientConfig - The configurations for the load balance client endpoint
    public function __init(LoadBalanceClientEndpointConfiguration loadBalanceClientConfig) {
        self.loadBalanceClientConfig = loadBalanceClientConfig;
        self.failover = loadBalanceClientConfig.failover;
        var lbClients = createLoadBalanceHttpClientArray(loadBalanceClientConfig);
        if (lbClients is error) {
            panic lbClients;
        } else {
            self.loadBalanceClientsArray = lbClients;
            var lbRule = loadBalanceClientConfig.lbRule;
            if (lbRule is LoadBalancerRule) {
                self.lbRule = lbRule;
            } else {
                LoadBalancerRounRobinRule loadBalancerRounRobinRule = new;
                self.lbRule = loadBalancerRounRobinRule;
            }
        }
    }

    # The POST remote function implementation of the LoadBalancer Connector.
    #
    # + path - Resource path
    # + message - An HTTP request or any payload of type `string`, `xml`, `json`, `byte[]`, `io:ReadableByteChannel`
    #             or `mime:Entity[]`
    # + return - The response or an `http:ClientError` if failed to fulfill the request
    public remote function post(string path, RequestMessage message) returns Response|ClientError {
        Request req = buildRequest(message);
        return performLoadBalanceAction(self, path, req, HTTP_POST);
    }

    # The HEAD remote function implementation of the LoadBalancer Connector.
    #
    # + path - Resource path
    # + message - An optional HTTP request or any payload of type `string`, `xml`, `json`, `byte[]`,
    #             `io:ReadableByteChannel` or `mime:Entity[]`
    # + return - The response or an `http:ClientError` if failed to fulfill the request
    public remote function head(string path, public RequestMessage message = ()) returns Response|ClientError {
        Request req = buildRequest(message);
        return performLoadBalanceAction(self, path, req, HTTP_HEAD);
    }

    # The PATCH remote function implementation of the LoadBalancer Connector.
    #
    # + path - Resource path
    # + message - An HTTP request or any payload of type `string`, `xml`, `json`, `byte[]`, `io:ReadableByteChannel`
    #             or `mime:Entity[]`
    # + return - The response or an `http:ClientError` if failed to fulfill the request
    public remote function patch(string path, RequestMessage message) returns Response|ClientError {
        Request req = buildRequest(message);
        return performLoadBalanceAction(self, path, req, HTTP_PATCH);
    }

    # The PUT remote function implementation of the Load Balance Connector.
    #
    # + path - Resource path
    # + message - An HTTP request or any payload of type `string`, `xml`, `json`, `byte[]`, `io:ReadableByteChannel`
    #             or `mime:Entity[]`
    # + return - The response or an `http:ClientError` if failed to fulfill the request
    public remote function put(string path, RequestMessage message) returns Response|ClientError {
        Request req = buildRequest(message);
        return performLoadBalanceAction(self, path, req, HTTP_PUT);
    }

    # The OPTIONS remote function implementation of the LoadBalancer Connector.
    #
    # + path - Resource path
    # + message - An optional HTTP request or any payload of type `string`, `xml`, `json`, `byte[]`,
    #             `io:ReadableByteChannel` or `mime:Entity[]`
    # + return - The response or an `http:ClientError` if failed to fulfill the request
    public remote function options(string path, public RequestMessage message = ()) returns Response|ClientError {
        Request req = buildRequest(message);
        return performLoadBalanceAction(self, path, req, HTTP_OPTIONS);
    }

    # The FORWARD remote function implementation of the LoadBalancer Connector.
    #
    # + path - Resource path
    # + request - An optional HTTP request
    # + return - The response or an `http:ClientError` if failed to fulfill the request
    public remote function forward(string path, Request request) returns Response|ClientError {
        return performLoadBalanceAction(self, path, request, HTTP_FORWARD);
    }

    # The EXECUTE remote function implementation of the LoadBalancer Connector.
    # The Execute remote function can be used to invoke an HTTP call with the given HTTP verb.
    #
    # + httpVerb - HTTP method to be used for the request
    # + path - Resource path
    # + message - An HTTP request or any payload of type `string`, `xml`, `json`, `byte[]`, `io:ReadableByteChannel`
    #             or `mime:Entity[]`
    # + return - The response or an `http:ClientError` if failed to fulfill the request
    public remote function execute(string httpVerb, string path, RequestMessage message) returns Response|ClientError {
        Request req = buildRequest(message);
        return performLoadBalanceExecuteAction(self, path, req, httpVerb);
    }

    # The DELETE remote function implementation of the LoadBalancer Connector.
    #
    # + path - Resource path
    # + message - An HTTP request or any payload of type `string`, `xml`, `json`, `byte[]`, `io:ReadableByteChannel`
    #             or `mime:Entity[]`
    # + return - The response or an `http:ClientError` if failed to fulfill the request
    public remote function delete(string path, public RequestMessage message = ()) returns Response|ClientError {
        Request req = buildRequest(message);
        return performLoadBalanceAction(self, path, req, HTTP_DELETE);
    }

    # The GET remote function implementation of the LoadBalancer Connector.

    # + path - Resource path
    # + message - An optional HTTP request or any payload of type `string`, `xml`, `json`, `byte[]`,
    #             `io:ReadableByteChannel` or `mime:Entity[]`
    # + return - The response or an `http:ClientError` if failed to fulfill the request
    public remote function get(string path, public RequestMessage message = ()) returns Response|ClientError {
        Request req = buildRequest(message);
        return performLoadBalanceAction(self, path, req, HTTP_GET);
    }

    # The submit implementation of the LoadBalancer Connector.
    #
    # + httpVerb - The HTTP verb value
    # + path - The resource path
    # + message - An HTTP outbound request message or any payload of type `string`, `xml`, `json`, `byte[]`,
    #             `io:ReadableByteChannel` or `mime:Entity[]`
    # + return - An `HttpFuture` that represents an asynchronous service invocation, or an `http:ClientError` if the submission
    #            fails
    public remote function submit(string httpVerb, string path, RequestMessage message) returns HttpFuture|ClientError {
        string errorMessage = "Load balancer client not supported for submit action";
        UnsupportedActionError err = error(UNSUPPORTED_ACTION, message = errorMessage);
        return err;
    }

    # The getResponse implementation of the LoadBalancer Connector.
    #
    # + httpFuture - The `HttpFuture` related to a previous asynchronous invocation
    # + return - An HTTP response message, or an `http:ClientError` if the invocation fails
    public remote function getResponse(HttpFuture httpFuture) returns Response|ClientError {
        string errorMessage = "Load balancer client not supported for getResponse action";
        UnsupportedActionError err = error(UNSUPPORTED_ACTION, message = errorMessage);
        return err;
    }

    # The hasPromise implementation of the LoadBalancer Connector.
    #
    # + httpFuture - The `HttpFuture` relates to a previous asynchronous invocation
    # + return - A `boolean` that represents whether a `PushPromise` exists
    public remote function hasPromise(HttpFuture httpFuture) returns boolean {
        return false;
    }

    # The getNextPromise implementation of the LoadBalancer Connector.
    #
    # + httpFuture - The `HttpFuture` relates to a previous asynchronous invocation
    # + return - An HTTP Push Promise message, or an `http:ClientError` if the invocation fails
    public remote function getNextPromise(HttpFuture httpFuture) returns PushPromise|ClientError {
        string errorMessage = "Load balancer client not supported for getNextPromise action";
        UnsupportedActionError err = error(UNSUPPORTED_ACTION, message = errorMessage);
        return err;
    }

    # The getPromisedResponse implementation of the LoadBalancer Connector.
    #
    # + promise - The related `PushPromise`
    # + return - A promised HTTP `Response` message, or an `http:ClientError` if the invocation fails
    public remote function getPromisedResponse(PushPromise promise) returns Response|ClientError {
        string errorMessage = "Load balancer client not supported for getPromisedResponse action";
        UnsupportedActionError err = error(UNSUPPORTED_ACTION, message = errorMessage);
        return err;
    }

    # The rejectPromise implementation of the LoadBalancer Connector.
    #
    # + promise - The Push Promise to be rejected
    public remote function rejectPromise(PushPromise promise) {}
};

# Represents an error occurred in an remote function of the Load Balance connector.
#
# + message - An error message explaining about the error
# + statusCode - HTTP status code of the LoadBalanceActionError
# + httpActionErr - Array of errors occurred at each endpoint
public type LoadBalanceActionErrorData record {|
    string message = "";
    int statusCode = 0;
    error?[] httpActionErr = [];
|};

public type LoadBalanceActionError error<string, LoadBalanceActionErrorData>;

// Performs execute action of the Load Balance connector. extract the corresponding http integer value representation
// of the http verb and invokes the perform action method.
function performLoadBalanceExecuteAction(LoadBalanceClient lb, string path, Request request,
                                         string httpVerb) returns Response|ClientError {
    HttpOperation connectorAction = extractHttpOperation(httpVerb);
    if (connectorAction != HTTP_NONE) {
        return performLoadBalanceAction(lb, path, request, connectorAction);
    } else {
        string message = "Load balancer client not supported for http method: " + httpVerb;
        UnsupportedActionError err = error(UNSUPPORTED_ACTION, message = message);
        return err;
    }
}

// Handles all the actions exposed through the Load Balance connector.
function performLoadBalanceAction(LoadBalanceClient lb, string path, Request request, HttpOperation requestAction)
             returns Response|ClientError {
    int loadBalanceTermination = 0; // Tracks at which point failover within the load balancing should be terminated.
    //TODO: workaround to initialize a type inside a function. Change this once fix is available.
    LoadBalanceActionErrorData loadBalanceActionErrorData = {statusCode: 500, message: "", httpActionErr:[]};
    int lbErrorIndex = 0;
    Request loadBalancerInRequest = request;
    mime:Entity requestEntity = new;

    if (lb.failover) {
        if (isMultipartRequest(loadBalancerInRequest)) {
            loadBalancerInRequest = check populateMultipartRequest(loadBalancerInRequest);
        } else {
            // When performing passthrough scenarios using Load Balance connector,
            // message needs to be built before trying out the load balance endpoints to keep the request message
            // to load balance the messages in case of failure.
            var binaryPayload = loadBalancerInRequest.getBinaryPayload();
            requestEntity = check loadBalancerInRequest.getEntity();
        }
    }

    while (loadBalanceTermination < lb.loadBalanceClientsArray.length()) {
        var loadBalanceClient = lb.lbRule.getNextClient(lb.loadBalanceClientsArray);
        if (loadBalanceClient is Client) {
            var serviceResponse = invokeEndpoint(path, request, requestAction, loadBalanceClient);
            if (serviceResponse is Response) {
                return serviceResponse;
            } else if (serviceResponse is HttpFuture) {
                return getInvalidTypeError();
            } else {
                if (lb.failover) {
                    loadBalancerInRequest = check createFailoverRequest(loadBalancerInRequest, requestEntity);
                    loadBalanceActionErrorData.httpActionErr[lbErrorIndex] = serviceResponse;
                    lbErrorIndex += 1;
                    loadBalanceTermination = loadBalanceTermination + 1;
                } else {
                    return serviceResponse;
                }
            }
        } else {
            return loadBalanceClient;
        }
    }
    return populateGenericLoadBalanceActionError(loadBalanceActionErrorData);
}

// Populates generic error specific to Load Balance connector by including all the errors returned from endpoints.
function populateGenericLoadBalanceActionError(LoadBalanceActionErrorData loadBalanceActionErrorData)
                                                    returns ClientError {
    int nErrs = loadBalanceActionErrorData.httpActionErr.length();
    error? er = loadBalanceActionErrorData.httpActionErr[nErrs - 1];
    error actError;
    if (er is error) {
        actError = er;
    } else {
        error err = error("Unexpected nil");
        panic err;
    }
    string lastErrorMessage = <string> actError.detail()?.message;
    string message = "All the load balance endpoints failed. Last error was: " + lastErrorMessage;
    AllLoadBalanceEndpointsFailedError err = error(ALL_LOAD_BALANCE_ENDPOINTS_FAILED,
                                                    message = message,
                                                    statusCode = INTERNAL_SERVER_ERROR_500,
                                                    httpActionError = loadBalanceActionErrorData.httpActionErr);
    return err;
}


# The configurations related to the load balance client endpoint.
#
# + httpVersion - The HTTP version to be used to communicate with the endpoint
# + http1Settings - Configurations related to HTTP/1.x protocol
# + http2Settings - Configurations related to HTTP/2 protocol
# + timeoutInMillis - The maximum time to wait (in milli seconds) for a response before closing the connection
# + forwarded - The choice of setting forwarded/x-forwarded header
# + followRedirects - Redirect related options
# + poolConfig - Configurations associated with request pooling
# + proxy - Proxy related options
# + targets - The upstream HTTP endpoints among which the incoming HTTP traffic load should be distributed
# + cache - The configurations for controlling the caching behaviour
# + compression - Specifies the way of handling compression (`accept-encoding`) header
# + auth - Configurations related to the HTTP authentication.
# + circuitBreaker - Circuit Breaker configuration
# + retryConfig - Retry related options
# + lbRule - LoadBalancing rule
# + failover - Configuration for load balancer whether to fail over in case of a failure
public type LoadBalanceClientEndpointConfiguration record {|
    string httpVersion = HTTP_1_1;
    Http1Settings http1Settings = {};
    Http2Settings http2Settings = {};
    int timeoutInMillis = 60000;
    string forwarded = "disable";
    FollowRedirects? followRedirects = ();
    ProxyConfig? proxy = ();
    PoolConfiguration? poolConfig = ();
    TargetService[] targets = [];
    CacheConfig cache = {};
    Compression compression = COMPRESSION_AUTO;
    OutboundAuthConfig? auth = ();
    CircuitBreakerConfig? circuitBreaker = ();
    RetryConfig? retryConfig = ();
    LoadBalancerRule? lbRule = ();
    boolean failover = true;
|};

function createClientEPConfigFromLoalBalanceEPConfig(LoadBalanceClientEndpointConfiguration lbConfig,
                                                     TargetService target) returns ClientEndpointConfig {
    ClientEndpointConfig clientEPConfig = {
        http1Settings: lbConfig.http1Settings,
        http2Settings: lbConfig.http2Settings,
        circuitBreaker:lbConfig.circuitBreaker,
        timeoutInMillis:lbConfig.timeoutInMillis,
        httpVersion:lbConfig.httpVersion,
        forwarded:lbConfig.forwarded,
        followRedirects:lbConfig.followRedirects,
        retryConfig:lbConfig.retryConfig,
        proxy:lbConfig.proxy,
        poolConfig:lbConfig.poolConfig,
        secureSocket:target.secureSocket,
        cache:lbConfig.cache,
        compression:lbConfig.compression,
        auth:lbConfig.auth
    };
    return clientEPConfig;
}

function createLoadBalanceHttpClientArray(LoadBalanceClientEndpointConfiguration loadBalanceClientConfig)
                                                                                    returns Client?[]|error {
    Client cl;
    Client?[] httpClients = [];
    int i = 0;
    foreach var target in loadBalanceClientConfig.targets {
        ClientEndpointConfig epConfig = createClientEPConfigFromLoalBalanceEPConfig(loadBalanceClientConfig, target);
        cl =  new(target.url , epConfig);
        httpClients[i] = cl;
        i += 1;
    }
    return httpClients;
}
