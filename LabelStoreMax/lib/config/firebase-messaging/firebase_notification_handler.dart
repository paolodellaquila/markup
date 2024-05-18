import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotifications {
  FirebaseMessaging? _firebaseMessaging;
  BuildContext? context;

  void setUpFirebase(BuildContext context) {
    this.context = context;
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging!.subscribeToTopic("messaging");

    /*_firebaseMessaging!.getToken().then((value) async {
      await _webRepository.registerFCMToken(value ?? "");
    });*/

    firebaseCloudMessaging_Listeners(context);
  }

  Future onSelectNotification(String? payload) async {}

  Future onDidReceiveLocalNotification(int? id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context!,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text("Nuova Notifica" + (title ?? "")),
        content: Text(body ?? ""),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  void firebaseCloudMessaging_Listeners(BuildContext context) {
    //ask permission
    askPermission();

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('launch_background');
    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (dynamic payload) {
      debugPrint('notification payload: $payload');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification?.body ?? "");

      RemoteNotification? notification = event.notification;
      AndroidNotification? android = event.notification?.android!;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                "messaging",
                "messaging",
                importance: Importance.max,
                priority: Priority.high,
                icon: 'launch_background',
              ),
            ));
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Nuova Notifica: " + (event.notification?.title ?? ""), style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(event.notification?.body ?? "", style: const TextStyle(color: Colors.black)),
                const SizedBox(height: 30.0),
                //dialogImage((Platform.isIOS) ? event.notification?.apple!.imageUrl ?? "" : event.notification?.android!.imageUrl ?? "", context)
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              color: Colors.black,
              child: Text('Ok', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Nuova Notifica: " + (event.notification?.title ?? ""), style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(event.notification?.body ?? "", style: const TextStyle(color: Colors.black)),
                const SizedBox(height: 30.0),
                //dialogImage((Platform.isIOS) ? event.notification?.apple!.imageUrl ?? "" : event.notification?.android!.imageUrl ?? "", context)
              ],
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              color: Colors.black,
              child: Text('Ok', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    });
  }

  Widget dialogImage(String link, BuildContext context) {
    ImageErrorListener? imageError;
    precacheImage(
      NetworkImage(link),
      context,
      onError: imageError,
    );
    return Image.network(link);
  }

  void askPermission() {
    _firebaseMessaging!.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      sound: true,
    );
  }
}
