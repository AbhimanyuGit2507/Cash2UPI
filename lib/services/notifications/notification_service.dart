import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  Future<void> showPendingSmsNotification(String bank, double amount, String smsId) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'cash2upi_pending',
      'Pending SMS Classification',
      channelDescription: 'Notifications for unclassified bank SMS',
      importance: Importance.max,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction('CUSTOMER', 'Customer'),
        AndroidNotificationAction('PERSONAL', 'Personal'),
        AndroidNotificationAction('BUSINESS', 'Business'),
      ],
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _flutterLocalNotificationsPlugin.show(
      0,
      'New Transaction Detected',
      '₹$amount from $bank',
      platformChannelSpecifics,
      payload: smsId,
    );
  }
}
