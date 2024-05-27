import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geofence_service/geofence_service.dart';

import 'resources/colors.dart' as my_colors;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<StatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();

  final _geofenceService = GeofenceService.instance.setup(
      interval: 1000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: false,
      printDevLog: true,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  // Create a [Geofence] list.
  final _geofenceList = <Geofence>[
    Geofence(
      id: 'place_1',
      latitude: 44.44576,
      longitude: 26.0527769,
      radius: [
        GeofenceRadius(id: 'radius_1000m', length: 4000),
      ],
    ),
    Geofence(
      id: 'place_2',
      latitude: 44.4328758,
      longitude: 26.1027512,
      radius: [
        GeofenceRadius(id: 'radius_25m', length: 25),
        GeofenceRadius(id: 'radius_100m', length: 100),
        GeofenceRadius(id: 'radius_200m', length: 200),
        GeofenceRadius(id: 'radius_1000m', length: 1000),
      ],
    ),
  ];

  // This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(
      Geofence geofence, GeofenceRadius geofenceRadius, GeofenceStatus geofenceStatus, Location location) async {
    print('geofence: ${geofence.toJson()}');
    print('geofenceRadius: ${geofenceRadius.toJson()}');
    print('geofenceStatus: ${geofenceStatus.toString()}');
    _geofenceStreamController.sink.add(geofence);
  }

// This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    print('prevActivity: ${prevActivity.toJson()}');
    print('currActivity: ${currActivity.toJson()}');
    _activityStreamController.sink.add(currActivity);
  }

// This function is to be called when the location has changed.
//   void _onLocationChanged(Location location) {
//     print('location: ${location.toJson()}');
//     latitude = location.latitude;
//     longitude = location.longitude;
//
//     if (_alignPositionOnUpdate) {
//       setState(() {
//         mapController.move(LatLng(latitude, longitude), mapController.camera.zoom);
//       });
//     }
//   }

// This function is to be called when a location services status change occurs
// since the service was started.
  void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

// This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      // _geofenceService.addLocationChangeListener(_onLocationChanged);
      _geofenceService.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
      _geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start(_geofenceList).catchError(_onError);
    });
  }

  @override
  void dispose() {
    _geofenceService.removeGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    // _geofenceService.removeLocationChangeListener(_onLocationChanged);
    _geofenceService.removeLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
    _geofenceService.removeActivityChangeListener(_onActivityChanged);
    _geofenceService.removeStreamErrorListener(_onError);
    _geofenceService.clearAllListeners();
    _geofenceService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A widget used when you want to start a foreground task when trying to minimize or close the app.
    // Declare on top of the [Scaffold] widget.
    return WillStartForegroundTask(
      onWillStart: () async {
        // You can add a foreground task start condition.
        return _geofenceService.isRunningService;
      },
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'geofence_service_notification_channel',
        channelName: 'Geofence Service Notification',
        channelDescription: 'This notification appears when the geofence service is running in the background.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        isSticky: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: const ForegroundTaskOptions(),
      notificationTitle: 'Geofence Service is running',
      notificationText: 'Tap to return to the app',
      child: Scaffold(
        body: _buildContentView(),
      ),
    );
  }

  // Widget _buildContentView() {
  //   return Scaffold(body: Text('Geofence Service is running...'));
  // }

  Widget _buildContentView() {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton(
                elevation: 0,
                backgroundColor: my_colors.Colors.greyBackground,
                onPressed: () {
                  setState(() {});
                },
                child: const Icon(
                  Icons.my_location,
                  color: my_colors.Colors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            // alignment: Alignment.bottomCenter,
            // widthFactor: 2.9,
            bottom: 20,
            right: MediaQuery.of(context).size.width / 2 - 75,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: TextButton(
                style: ButtonStyle(
                  // elevation: MaterialStateProperty.all<double>(7),
                  // shadowColor: MaterialStateProperty.all<Color>(Colors.black),
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16)),
                  backgroundColor: MaterialStateProperty.all<Color>(my_colors.Colors.greyBackground),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                onPressed: () {
                  Fluttertoast.showToast(
                    msg: 'Start Contributing pressed!',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.mic, color: my_colors.Colors.primary),
                    Text(
                      'Start contributing',
                      style: TextStyle(color: my_colors.Colors.primary),
                    ),
                  ],
                ), // Needed when having multiple FABs
              ),
            ),
          ),
          Positioned(
            top: 32,
            right: 16,
            width: 40,
            height: 40,
            child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0)),
                  backgroundColor: MaterialStateProperty.all<Color>(my_colors.Colors.greyBackground),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                onPressed: () {
                  Fluttertoast.showToast(
                    msg: 'question mark!',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                },
                child: const Icon(
                  Icons.question_mark,
                  color: my_colors.Colors.primary,
                ) // Needed when having multiple FABs
                ),
          ),
          Positioned(
            top: 86,
            right: 16,
            width: 40,
            height: 40,
            child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0)),
                  backgroundColor: MaterialStateProperty.all<Color>(my_colors.Colors.greyBackground),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                onPressed: () {
                  Fluttertoast.showToast(
                    msg: 'zones!',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                },
                child: const Icon(
                  Icons.layers_outlined,
                  color: my_colors.Colors.primary,
                ) // Needed when having multiple FABs
                ),
          ),
          Positioned(
            top: 142,
            right: 16,
            width: 40,
            height: 40,
            child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0)),
                  backgroundColor: MaterialStateProperty.all<Color>(my_colors.Colors.greyBackground),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                onPressed: () {
                  Fluttertoast.showToast(
                    msg: 'upright!',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                },
                child: const Icon(
                  Icons.abc,
                  color: my_colors.Colors.primary,
                ) // Needed when having multiple FABs
                ),
          ),
        ],
      ),
      // Add your bottom navigation bar here
    );
  }
}
