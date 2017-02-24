import 'dart:async';
import 'package:fcm_push/fcm_push.dart';

Future main(List<String> arguments) async {
    print("Hello fcm-push");

    final String serverKey = "AAAA8XGDNkg:APA91bG2XDiR10b9ZUrzv-2LAvlJMr_gSaoGQxyo9clvFeazYeyLGKDdJdoB0QyT2z0vguCmQgWjdrKo5oehwY5CJuwAAVIHqP8E7I2eohfwfzDfxtOtRrzcFtZegYemdt0n4eHcTr-c";

    final String token = "fOutRnJla9w:APA91bGLSZzvUoy4c2Dm1im2efga5x2MI7dCGU_Urlj1UodiGONOHVlKRk4S1MEI3KVAlX2tKbhw1Xfis-s-on6vdmv0DkjNNxYNa0Pn7fY-CR9ubC1se-Ao9PPiSvZlHMMq8uWJkLM5";

    final FCM fcm = new FCM(serverKey);

    //print(message.toString());

    final String messageID = await fcm.send(
        new Message(token)
            ..collapseKey = "your_collapse_key"
            ..data.add(new Tuple2<String,dynamic>("your_custom_data_key", 'your_custom_data_value'))
            ..title = "Title - From DART 1"
            ..body = "Body"
    );

    print("MessageID: ${messageID}");
}