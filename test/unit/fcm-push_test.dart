// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library fcm_push.test;

import 'package:test/test.dart';
import 'package:fcm_push/fcm_push.dart';

main() {
  group('A group of tests', () {

    setUp(() { });

    test('> Message', () {
        Message message = new Message("Mike");
        expect(message.toJson(),'{"to":"Mike}');
    }); // end of 'Message' test

    test('> Message with data', () {
        Message message = new Message("Mike");
        message.data.add(new Tuple2<String,dynamic>("your_custom_data_key","your_custom_data_value"));

        expect(message.toJson(),'{"to":"Mike","data":{"your_custom_data_key":"your_custom_data_value"}}');
    }); // end of 'Message with data' test

  });
}
