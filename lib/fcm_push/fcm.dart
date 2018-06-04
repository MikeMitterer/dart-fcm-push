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
     
part of fcm_push;

/// FCM Option defined here: https://firebase.google.com/docs/cloud-messaging/server
/// Don't know why you should overwrite these settings but you can.
class _FCMOptions {
    String host = "fcm.googleapis.com";
    int port = 443;
    String path = '/fcm/send';
    String method = "POST";
    bool keepAlive = false;
    Map<String,dynamic> headers = new Map<String,dynamic>();
}

// JS-Version: https://github.com/nandarustam/fcm-push/blob/master/lib/fcm.js
class FCM {
    final Logger _logger = new Logger('fcm_push.FCM');

    /// FCM-Options: https://firebase.google.com/docs/cloud-messaging/server
    final _FCMOptions _options;

    factory FCM(final String serverKey) {
        return (
            new FCMBuilder()
            ..keepAlive = true
        ).build(serverKey);
    }

    /// Sends the [Message] and returns the "message_id"
    ///
    /// https://firebase.google.com/docs/cloud-messaging/http-server-ref#table4
    ///
    Future<String> send(final Message message) async {
        final String jsonMessage = message.toString();
        //_options.headers['Content-Length'] = json.

        final Uri uri = new Uri(scheme: "https", host: _options.host, port: _options.port, path: _options.path);
        _logSendInfo(message);
        
        final http.Response response = await http.post(uri,headers: _options.headers,body: jsonMessage);
        Map<String,dynamic> body;

        try {
            body = json.decode(response.body);
            _logResponse(response,body);
        } on FormatException {
            _logResponse(response);
        }

        // https://firebase.google.com/docs/cloud-messaging/http-server-ref#table4
        switch(response.statusCode) {
            case HttpStatus.HTTP_200_OK:

                if(int.parse(body["success"].toString()) == 1) {
                    return body["results"].first["message_id"];
                } else {
                    throw new FCMException(response.statusCode,response.body);
                }
                break;
                
            case HttpStatus.HTTP_503_UNAVAILABLE:
            default:
                throw new FCMException(response.statusCode,response.body);
        }
    }

    // - private -------------------------------------------------------------------------------------------------------

    FCM._private(this._options );

    List<String> _headers(final Map<String,dynamic> headers,{final bool truncate: true }) {
        final List<String> asList = new List<String>();
        headers.forEach((final String key,final value) {
                asList.add("${key}: ${truncate ? _truncate(value) : value}");
            });

        return asList;
    }

    void _logSendInfo(final Message message) {
        _logger.fine("Headers to send:");
        _logger.fine("\t" + _penInfo(_headers(_options.headers).join('\n\t')));
        _logger.fine("Payload to send: ${"\n" + _penInfo(
            _truncate(_PRETTYJSON.convert(message.toJson())))}");

    }

    void _logResponse(final http.Response response,[ final Map<String,dynamic> body ]) {
        _logger.fine("Response - Status: ${_penInfo(response.statusCode.toString())}");
        _logger.fine("Response - Header: ${_penInfo("\n\t" + _headers(response.headers).join("\n\t"))}");
        if(body != null) {
            _logger.fine("Response - Body:   ${_penInfo("\n" + _PRETTYJSON.convert(body))}");
        }
    }

    /// Truncate output and add ... to each line if the line is longer than [at]
    String _truncate(final String value,{ final int at: 80 }) {
        final List<String> values = value.split("\n");
        final bool isMultiLine = values.length > 1;

        // Makes the code cleaner
        String _privateTruncate(final String value) {
            return value.replaceAllMapped(
                new RegExp('^(.{${at}})(.*)\$'), (final Match m) {
                return m.groupCount == 2 && m[2]
                    .trim()
                    .isNotEmpty ? m[1] + "..." : m[0];
            }) + (isMultiLine ? "\n" : "");
        }

        String result = "";
        values.forEach( (final String value) {
            result = result + (_privateTruncate(value));
        });

        return result.toString();
    }
}

class FCMBuilder {
    _FCMOptions _options = new _FCMOptions();

    void set host(final String host) { _options.host = host; }
    void set port(final int port) { _options.port = port; }
    void set path(final String path) { _options.path = path; }
    void set method(final String method) { _options.method = method; }

    /// optional, enables keep-alive, defaults to false
    void set keepAlive(final bool keepAlive) { _options.keepAlive = keepAlive; }

    void set headers( Map<String,dynamic> headers) { _options.headers = headers; }

    FCM build(final String serverKey) {
        Validate.notBlank(serverKey,"ServerKey must not be blank!");

        _getDefaultHeaders(serverKey).forEach((final String key, final dynamic value) {
            _options.headers.putIfAbsent(key,() => value);
        });

        return new FCM._private(_options);
    }

    // - private -------------------------------------------------------------------------------------------------------

    Map<String,dynamic> _getDefaultHeaders(final String serverKey) {
        final Map map = <String,dynamic> {
            "Host" : _options.host,
            "Authorization" : "key=${serverKey}",
            'Content-Type': 'application/json'
        };
        if(_options.keepAlive) {
            map["Connection"] = "keep-alive";

        }
        return map;
    }
}
