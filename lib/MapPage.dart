import 'dart:async';
import 'dart:convert';

import 'package:SoundTrek/StatsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:latlong2/latlong.dart';

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

  // map
  final mapController = MapController();
  double latitude = 44.44576;
  double longitude = 26.0527769;
  double zoom = 16.0;
  AlignOnUpdate _alignPositionOnUpdate = AlignOnUpdate.always;
  final StreamController<double?> _alignPositionStreamController = StreamController<double?>();

  // heatmap
  List<WeightedLatLng> data = [];
  final StreamController<void> _rebuildStream = StreamController.broadcast();

  // marker
  LatLng _markerPoz = const LatLng(-90, -180);

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
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      // _geofenceService.addLocationChangeListener(_onLocationChanged);
      _geofenceService.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
      _geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start(_geofenceList).catchError(_onError);

      _alignPositionOnUpdate = AlignOnUpdate.always;
      // _alignPositionStreamController = StreamController<double?>();
    });
  }

  _loadData() async {
    var str = await rootBundle.loadString('lib/assets/initial_data.json');
    List<dynamic> result = jsonDecode(str);

    setState(() {
      data = result.map((e) => e as List<dynamic>).map((e) => WeightedLatLng(LatLng(e[0], e[1]), 0.1)).toList();
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

    _alignPositionStreamController.close();
    _rebuildStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _rebuildStream.add(null);
    });
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
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              onTap: (point, latlng) {
                setState(() {
                  _markerPoz = latlng;
                });
                modalBottomSheet();
              },
              initialZoom: 2.5,
              onPositionChanged: (MapPosition position, bool hasGesture) {
                if (hasGesture && _alignPositionOnUpdate != AlignOnUpdate.never) {
                  setState(
                    () => _alignPositionOnUpdate = AlignOnUpdate.never,
                  );
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _markerPoz,
                    alignment: Alignment.topCenter,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: my_colors.Colors.primary,
                      size: 40,
                    ),
                  ),
                ],
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(_geofenceList[0].latitude, _geofenceList[0].longitude),
                    radius: _geofenceList[0].radius[0].length,
                    useRadiusInMeter: true,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ],
              ),
              CurrentLocationLayer(
                alignPositionOnUpdate: _alignPositionOnUpdate,
                alignDirectionOnUpdate: AlignOnUpdate.never,
                alignPositionStream: _alignPositionStreamController.stream,
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: Size(40, 40),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              if (data.isNotEmpty)
                HeatMapLayer(
                  maxZoom: 18,
                  heatMapDataSource: InMemoryHeatMapDataSource(data: data),
                  heatMapOptions: HeatMapOptions(
                    minOpacity: 0.1,
                  ),
                  reset: _rebuildStream.stream,
                ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FloatingActionButton(
                    elevation: 0,
                    backgroundColor: my_colors.Colors.greyBackground,
                    onPressed: () {
                      setState(
                        () => _alignPositionOnUpdate = AlignOnUpdate.always,
                      );
                      _alignPositionStreamController.add(18);
                    },
                    child: Icon(
                      (_alignPositionOnUpdate == AlignOnUpdate.always) ? Icons.my_location : Icons.location_searching,
                      color: my_colors.Colors.primary,
                    ),
                  ),
                ),
              ),
            ],
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
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
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
                    Column(
                      children: [
                        Text(
                          'Start contributing',
                          style: TextStyle(color: my_colors.Colors.primary),
                        ),
                        Text(
                          '+150 pts/min',
                          style: TextStyle(color: my_colors.Colors.primary),
                        ),
                      ],
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

  Future<void> modalBottomSheet() {
    return showModalBottomSheet<void>(
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: my_colors.Colors.greyBackground,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Noise in selected area',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      )),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: my_colors.Colors.primary),
                      Text(' 42.1234, 55.2345',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                          )),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.access_time, color: my_colors.Colors.primary),
                      Text(' June 24, 2024 4:55PM',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        children: [
                          Row(
                            children: [
                              Text('LAeq: ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: my_colors.Colors.primary,
                                  )),
                              Text('81.6 dB(A)',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                  )),
                            ],
                          ),
                          Row(
                            children: [
                              Text('LA50: ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: my_colors.Colors.primary,
                                  )),
                              Text('68.6 dB(A)',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                  )),
                            ],
                          ),
                        ],
                      ),
                      Center(
                        child: TextButton(
                          style: ButtonStyle(
                            // elevation: MaterialStateProperty.all<double>(7),
                            // shadowColor: MaterialStateProperty.all<Color>(Colors.black),
                            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.symmetric(horizontal: 20, vertical: 0)),
                            backgroundColor: MaterialStateProperty.all<Color>(my_colors.Colors.primaryLight),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          onPressed: () {
                            // Implement what happens when you press 'History'
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => StatsPage(_markerPoz)),
                            );
                          },
                          child: const Text(
                            'See graphs',
                            style: TextStyle(
                              color: my_colors.Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() => (setState(() {
          _markerPoz = const LatLng(-90, -180);
        })));
  }
}
