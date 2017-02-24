/*
 * Copyright (c) 2017, Michael Mitterer (office@mikemitterer.at),
 * IT-Consulting and Development Limited.
 *
 * All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/// This is an awesome library. More dartdocs go here.
library fcm_push;

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';
import 'package:validate/validate.dart';
import 'package:http_utils/http_utils.dart';

export 'package:tuple/tuple.dart';

class _FCMOptions {
    String host = "fcm.googleapis.com";
    int port = 443;
    String path = '/fcm/send';
    String method = "POST";
    Map<String,dynamic> headers = new Map<String,dynamic>();
}

class FCM {
    final String _serverKey;
    final _FCMOptions _options;

    factory FCM(final String serverKey) {
        return new FCMBuilder().build(serverKey);
    }

    /// Sends the [Message] and returns the "message_id"
    Future<String> send(final Message message) async {
        final String json = message.toJson();
        //_options.headers['Content-Length'] = json.

        final Uri uri = new Uri(scheme: "https", host: _options.host, port: _options.port, path: _options.path);

        print("H ${_options.headers}");
        print("Payload ${json}");

        final http.Response response = await http.post(uri,headers: _options.headers,body: json);

        print("Status: ${response.statusCode}");
        print("Header: ${response.headers.toString()}");
        print("Body: ${response.body}");

        final Map<String,dynamic> body = JSON.decode(response.body);
        //print(body["results"].first["message_id"]);

        switch(response.statusCode) {
            case HttpStatus.HTTP_200_OK:
                return body["results"].first["message_id"];

            case HttpStatus.HTTP_503_UNAVAILABLE:
                break;
        }
    }

    // - private -------------------------------------------------------------------------------------------------------

    FCM._private(this._serverKey,this._options );
}

class FCMBuilder {
    _FCMOptions _options = new _FCMOptions();

    void set host(final String host) { _options.host = host; }
    void set port(final int port) { _options.port = port; }
    void set path(final String path) { _options.path = path; }
    void set method(final String method) { _options.method = method; }
    void set headers( Map<String,dynamic> headers) { _options.headers = headers; }

    FCM build(final String serverKey) {
        Validate.notBlank(serverKey,"ServerKey must not be blank!");

        _getDefaultHeaders(serverKey).forEach((final String key, final dynamic value) {
            _options.headers.putIfAbsent(key,() => value);
        });

        return new FCM._private(serverKey,_options);
    }

    // - private -------------------------------------------------------------------------------------------------------

    Map<String,dynamic> _getDefaultHeaders(final String serverKey) {
        return <String,dynamic> {
            "Host" : _options.host,
            "Authorization" : "key=${serverKey}",
            'Content-Type': 'application/json',
            "Connection" : "keep-alive"
        };
    }
}

class Message {
    /// Registration-Token or topic
    String to;

    String collapseKey;

    final List<Tuple2<String,dynamic>> data = new List<Tuple2<String,dynamic>>();

    String title;

    String body;

    Message(this.to);

    Map<String,dynamic> toMap() {
        final Map<String,dynamic> json = new Map<String,dynamic>();

        json["to"] = to;
        if(_hasCollapseKey) {
            json["collapse_key"] = collapseKey;
        }

        if(_hasData) {
            json["data"] = new Map<String,dynamic>();
        }
        data.forEach((final Tuple2<String,dynamic> value) {
            (json["data"] as Map<String,dynamic>)[value.item1] = value.item2;
        });


        if(_hasTitle || _hasBody) {
            json["notification"] = new Map<String, dynamic>();
            if (_hasTitle) {
                json["notification"]["title"] = title;
            }

            if (_hasBody) {
                json["notification"]["body"] = body;
            }
        }
        return json;
    }

    String toJson() => JSON.encode(toMap());

    @override
    String toString() => toJson();

    // - private -------------------------------------------------------------------------------------------------------

    bool get _hasTitle => (title ?? "").isNotEmpty;
    bool get _hasBody => (body ?? "").isNotEmpty;
    bool get _hasCollapseKey => (collapseKey ?? "").isNotEmpty;
    bool get _hasData => data.isNotEmpty;

}