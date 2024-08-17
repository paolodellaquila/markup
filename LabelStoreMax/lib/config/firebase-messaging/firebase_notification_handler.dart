import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/events/firebase_on_message_order_event.dart';
import 'package:flutter_app/app/events/order_notification_event.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/account_order_detail_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '../../app/events/product_notification_event.dart';

class FirebaseNotifications {
  FirebaseMessaging? _firebaseMessaging;
  BuildContext? context;

  void setUpFirebase(BuildContext context) {
    this.context = context;
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging!.subscribeToTopic("messaging");

    _firebaseMessaging!.getToken().then((value) async {
      //await _webRepository.registerFCMToken(value ?? "");
      print("FCM Token: $value");
    });

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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      /// WP Notify - Save notification
      event<FirebaseOnMessageOrderEvent>(data: {"RemoteMessage": message});

      if (message.data.containsKey('order_id')) {
        _maybeShowSnackBar(context, message);
      }

      print("message recieved");
      print(message.notification?.body ?? "");

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android!;

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
          title: Text("Nuova Notifica: " + (message.notification?.title ?? ""), style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message.notification?.body ?? "", style: const TextStyle(color: Colors.black)),
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

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      /// WP Notify - Product notification
      if (message.data.containsKey('product_id')) {
        event<ProductNotificationEvent>(data: {"RemoteMessage": message});
      }

      /// WP Notify - Order notification
      if (message.data.containsKey('order_id')) {
        event<OrderNotificationEvent>(data: {"RemoteMessage": message});
      }

      /// WP Notify - Save notification
      event<FirebaseOnMessageOrderEvent>(data: {"RemoteMessage": message});

      if (message.data.containsKey('order_id')) {
        _maybeShowSnackBar(context, message);
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Nuova Notifica: " + (message.notification?.title ?? ""), style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message.notification?.body ?? "", style: const TextStyle(color: Colors.black)),
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

extension FirebaseNotificationUtils on FirebaseNotifications {
  /// Attempt to show a snackbar if the user is on the same page
  _maybeShowSnackBar(BuildContext context, RemoteMessage message) async {
    if (!(await canSeeRemoteMessage(message))) {
      return;
    }
    _showSnackBar(context, message.notification?.body, onPressed: () {
      routeTo(AccountOrderDetailPage.path, data: int.parse(message.data['order_id']));
    });
  }

  _showSnackBar(BuildContext context, String? message, {Function()? onPressed}) {
    SnackBar snackBar = SnackBar(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${'New notification received'.tr()} 🚨',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          if (message != null) Text(message)
        ],
      ),
      action: onPressed == null
          ? null
          : SnackBarAction(
              label: 'View'.tr(),
              onPressed: onPressed,
            ),
      duration: Duration(milliseconds: 4500),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
