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

import ballerina/lang.'object as lang;
import ballerina/java;

# Represents the NATS streaming server connection to which a subscription service should be bound in order to
# receive messages of the corresponding subscription.
public class Listener {

    *lang:Listener;

    private string url;
    private string clusterId;
    private string? clientId;
    private StreamingConfig? streamingConfig;

    # Creates a new Streaming Listener.
    #
    # + url -  The NATS Broker URL. For a clustered use case, pass the URL
    #                       as a string array.
    # + clusterId - The unique identifier of the cluster configured in the NATS server. The default value is `test-cluster`
    # + clientId - The unique identifier of the client. The `clientId` should be unique across all the subscriptions.
    #              Therefore, multilpe subscription services cannot be bound to a single listener
    # + connectionConfig - The configuration related to the NATS streaming connectivity
    public isolated function init(string url = DEFAULT_URL, string? clientId = (), string clusterId = "test-cluster",
        StreamingConfig? streamingConfig = ()) {
        self.url = url;
        self.clusterId = clusterId;
        self.clientId = clientId;
        self.streamingConfig = streamingConfig;
        streamingListenerInit(self);
    }

    # Binds a service to the `nats:Listener`.
    #
    # + s - Type descriptor of the service
    # + name - Name of the service
    # + return - `()` or else a `nats:Error` upon failure to register the listener
    public isolated function __attach(service s, string? name = ()) returns error? {
        streamingAttach(self, s, self.url);
    }

    # Stops consuming messages and detaches the service from the `nats:Listener`.
    #
    # + s - Type descriptor of the service
    # + return - `()` or else a `nats:Error` upon failure to detach the service
    public isolated function __detach(service s) returns error? {
        streamingDetach(self, s);
    }

    # Starts the `nats:Listener`.
    #
    # + return - `()` or else a `nats:Error` upon failure to start the listener
    public isolated function __start() returns error? {
         streamingSubscribe(self, self.url, self.clusterId, self.clientId, self.streamingConfig);
    }

    # Stops the `nats:Listener` gracefully.
    #
    # + return - `()` or else a `nats:Error` upon failure to stop the listener
    public isolated function __gracefulStop() returns error? {
        return ();
    }

    # Stops the `nats:Listener` forcefully.
    #
    # + return - `()` or else a `nats:Error` upon failure to stop the listener
    public isolated function __immediateStop() returns error? {
        return self.close();
    }

    isolated function close() returns error? {
        return streamingListenerClose(self);
    }
}

isolated function streamingListenerInit(Listener lis) =
@java:Method {
    'class: "org.ballerinalang.nats.streaming.consumer.Init"
} external;

isolated function streamingSubscribe(Listener streamingClient, string conn,
                            string clusterId, string? clientId, StreamingConfig? streamingConfig) =
@java:Method {
    'class: "org.ballerinalang.nats.streaming.consumer.Subscribe"
} external;

isolated function streamingAttach(Listener lis, service serviceType, string conn) =
@java:Method {
    'class: "org.ballerinalang.nats.streaming.consumer.Attach"
} external;

isolated function streamingDetach(Listener lis, service serviceType) =
@java:Method {
    'class: "org.ballerinalang.nats.streaming.consumer.Detach"
} external;

isolated function streamingListenerClose(Listener lis) returns error? =
@java:Method {
    'class: "org.ballerinalang.nats.streaming.consumer.Close"
} external;
