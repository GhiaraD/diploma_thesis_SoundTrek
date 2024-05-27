// import 'dart:async';
// import 'dart:io';
// import 'dart:isolate';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:record/record.dart';
//
// import '../RecorderView.dart';
// import 'AudioStreamingApp.dart';
//
// // The callback function should always be a top-level function.
// @pragma('vm:entry-point')
// void startCallback() {
//   // The setTaskHandler function must be called to handle the task in the background.
//   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// }
//
// class MyTaskHandler extends TaskHandler {
//   SendPort? _sendPort;
//   StreamSubscription<Amplitude>? _streamSubscription;
//   late final AudioRecorder _record;
//
//   // Amplitude? _amplitude;
//
//   @override
//   void onStart(DateTime timestamp, SendPort? sendPort) async {
//     try {
//       if (await _record.hasPermission()) {
//         const encoder = AudioEncoder.aacLc;
//
//         final devs = await _record.listInputDevices();
//         debugPrint(devs.toString());
//
//         const config = RecordConfig(encoder: encoder, numChannels: 1);
//
//         await recordStream(_record, config);
//       }
//     } catch (e) {
//       print(e);
//     }
//
//     try {
//       if (await _record.hasPermission()) {
//         print("bitches");
//         _streamSubscription = _record.onAmplitudeChanged(const Duration(milliseconds: 300)).listen((amp) {
//           FlutterForegroundTask.updateService(
//             notificationTitle: 'Recording',
//             notificationText: '${amp}',
//           );
//           // Send data to the main isolate.
//           sendPort?.send(amp);
//         });
//       }
//     } catch (e) {
//       print("no bitches? $e");
//     }
//   }
//
//   Future<void> recordStream(AudioRecorder recorder, RecordConfig config) async {
//     final stream = await recorder.startStream(config);
//
//     stream.listen(
//       (data) {
//         // ignore: avoid_print
//         print(
//           recorder.convertBytesToInt16(Uint8List.fromList(data)),
//         );
//         print(data);
//       },
//       // ignore: avoid_print
//       onDone: () {
//         // ignore: avoid_print
//         print('End of stream.');
//       },
//     );
//   }
//
//   // Called every [interval] milliseconds in [ForegroundTaskOptions].
//   @override
//   void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {}
//
//   // Called when the notification button on the Android platform is pressed.
//   @override
//   void onDestroy(DateTime timestamp, SendPort? sendPort) async {
//     print('onDestroy');
//     await _streamSubscription?.cancel();
//     await _record.cancel();
//     _record.dispose();
//   }
//
//   // Called when the notification button on the Android platform is pressed.
//   @override
//   void onNotificationButtonPressed(String id) {
//     print('onNotificationButtonPressed >> $id');
//   }
//
//   // Called when the notification itself on the Android platform is pressed.
//   //
//   // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
//   // this function to be called.
//   @override
//   void onNotificationPressed() {
//     // Note that the app will only route to "/resume-route" when it is exited so
//     // it will usually be necessary to send a message through the send port to
//     // signal it to restore state when the app is already started.
//     FlutterForegroundTask.launchApp("/resume-route");
//     _sendPort?.send('onNotificationPressed');
//   }
// }
//
// class MapPageView extends StatefulWidget {
//   const MapPageView({super.key});
//
//   @override
//   State<StatefulWidget> createState() => _MapPageViewState();
// }
//
// class _MapPageViewState extends State<MapPageView> {
//   ReceivePort? _receivePort;
//
//   Future<void> _requestPermissionForAndroid() async {
//     if (!Platform.isAndroid) {
//       return;
//     }
//
//     // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
//     // onNotificationPressed function to be called.
//     //
//     // When the notification is pressed while permission is denied,
//     // the onNotificationPressed function is not called and the app opens.
//     //
//     // If you do not use the onNotificationPressed or launchApp function,
//     // you do not need to write this code.
//     if (!await FlutterForegroundTask.canDrawOverlays) {
//       // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
//       await FlutterForegroundTask.openSystemAlertWindowSettings();
//     }
//
//     // Android 12 or higher, there are restrictions on starting a foreground service.
//     //
//     // To restart the service on device reboot or unexpected problem, you need to allow below permission.
//     if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
//       // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
//       await FlutterForegroundTask.requestIgnoreBatteryOptimization();
//     }
//
//     // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
//     final NotificationPermission notificationPermissionStatus =
//         await FlutterForegroundTask.checkNotificationPermission();
//     if (notificationPermissionStatus != NotificationPermission.granted) {
//       await FlutterForegroundTask.requestNotificationPermission();
//     }
//   }
//
//   void _initForegroundTask() {
//     FlutterForegroundTask.init(
//       androidNotificationOptions: AndroidNotificationOptions(
//         id: 500,
//         channelId: 'foreground_service',
//         channelName: 'Foreground Service Notification',
//         channelDescription: 'This notification appears when the foreground service is running.',
//         channelImportance: NotificationChannelImportance.DEFAULT,
//         priority: NotificationPriority.LOW,
//         iconData: const NotificationIconData(
//           resType: ResourceType.mipmap,
//           resPrefix: ResourcePrefix.ic,
//           name: 'launcher',
//           backgroundColor: Colors.orange,
//         ),
//         buttons: [
//           const NotificationButton(
//             id: 'sendButton',
//             text: 'Send',
//             textColor: Colors.orange,
//           ),
//           const NotificationButton(
//             id: 'testButton',
//             text: 'Test',
//             textColor: Colors.grey,
//           ),
//         ],
//       ),
//       iosNotificationOptions: const IOSNotificationOptions(
//         showNotification: true,
//         playSound: false,
//       ),
//       foregroundTaskOptions: const ForegroundTaskOptions(
//         isOnceEvent: true,
//         autoRunOnBoot: true,
//         allowWakeLock: true,
//         allowWifiLock: true,
//       ),
//     );
//   }
//
//   Future<bool> _startForegroundTask() async {
//     // You can save data using the saveData function.
//     await FlutterForegroundTask.saveData(key: 'data', value: 'hello');
//
//     // Register the receivePort before starting the service.
//     final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
//     final bool isRegistered = _registerReceivePort(receivePort);
//     if (!isRegistered) {
//       print('Failed to register receivePort!');
//       return false;
//     }
//
//     if (await FlutterForegroundTask.isRunningService) {
//       return FlutterForegroundTask.restartService();
//     } else {
//       return FlutterForegroundTask.startService(
//         notificationTitle: 'Foreground Service is running',
//         notificationText: 'Tap to return to the app',
//         callback: startCallback,
//       );
//     }
//   }
//
//   Future<bool> _stopForegroundTask() {
//     return FlutterForegroundTask.stopService();
//   }
//
//   bool _registerReceivePort(ReceivePort? newReceivePort) {
//     if (newReceivePort == null) {
//       return false;
//     }
//
//     _closeReceivePort();
//
//     _receivePort = newReceivePort;
//     _receivePort?.listen((data) {
//       print('uint8: ${data.toString()} ${data.runtimeType}');
//     });
//
//     return _receivePort != null;
//   }
//
//   void _closeReceivePort() {
//     _receivePort?.close();
//     _receivePort = null;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _requestPermissionForAndroid();
//       _initForegroundTask();
//
//       // You can get the previous ReceivePort without restarting the service.
//       if (await FlutterForegroundTask.isRunningService) {
//         final newReceivePort = FlutterForegroundTask.receivePort;
//         _registerReceivePort(newReceivePort);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _closeReceivePort();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // A widget that prevents the app from closing when the foreground service is running.
//     // This widget must be declared above the [Scaffold] widget.
//     return WithForegroundTask(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Flutter Foreground Task'),
//           centerTitle: true,
//         ),
//         body: _buildContentView(),
//       ),
//     );
//   }
//
//   void _goToRecordPage() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const RecordPageView()),
//     );
//   }
//
//   void _goToRecordPage2() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const AudioStreamingApp()),
//     );
//   }
//
//   Widget _buildContentView() {
//     buttonBuilder(String text, {VoidCallback? onPressed}) {
//       return ElevatedButton(
//         onPressed: onPressed,
//         child: Text(text),
//       );
//     }
//
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           buttonBuilder('start', onPressed: _startForegroundTask),
//           buttonBuilder('stop', onPressed: _stopForegroundTask),
//           buttonBuilder('recordPage', onPressed: _goToRecordPage),
//           buttonBuilder('recordPage2', onPressed: _goToRecordPage2),
//         ],
//       ),
//     );
//   }
// }
