import 'dart:async';
import 'dart:convert';
import 'package:fcm_push/cmdline.dart';
import 'package:fcm_push/fcm_push.dart';
import 'package:ansicolor/ansicolor.dart';

/// Define some Pens to use it everywhere
final AnsiPen _penError = new AnsiPen()..red();

/// prettyPrint for JSON
const JsonEncoder _PRETTYJSON = const JsonEncoder.withIndent('   ');

Future<int> main(List<String> arguments) async {
    final Application app = new Application();

    try {
        await app.run(arguments);

    } on FCMException catch (e) {
        print("StatusCode: ${_penError(e.statusCode.toString())}");

        String message = e.message.toString();
        try {
            message = _PRETTYJSON.convert(JSON.decode(e.message));
        } finally {
            print("${_penError(message)}");
        }
    }

    return 0;
}