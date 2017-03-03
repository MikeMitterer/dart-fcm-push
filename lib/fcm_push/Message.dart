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

// https://firebase.google.com/docs/cloud-messaging/http-server-ref
class Message {
    /// Registration-Token or topic
    String to;

    String collapseKey;

    final List<Tuple2<String,dynamic>> data = new List<Tuple2<String,dynamic>>();

    String title;

    String body;

    Message([this.to]);

    Map<String,dynamic> toJson() {
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

    @override
    String toString() => JSON.encode(toJson());

    // - private -------------------------------------------------------------------------------------------------------

    bool get _hasTitle => (title ?? "").isNotEmpty;
    bool get _hasBody => (body ?? "").isNotEmpty;
    bool get _hasCollapseKey => (collapseKey ?? "").isNotEmpty;
    bool get _hasData => data.isNotEmpty;

}
