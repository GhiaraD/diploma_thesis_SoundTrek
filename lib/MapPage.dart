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
      latitude: 44.4994,
      longitude: 26.0581,
      radius: [
        GeofenceRadius(id: 'radius_1000m', length: 5000),
      ],
    ),
    Geofence(
      id: 'place_2',
      latitude: 44.4558,
      longitude: 26.1456,
      radius: [
        GeofenceRadius(id: 'radius_1000m', length: 3450),
      ],
    ),
    Geofence(
      id: 'place_3',
      latitude: 44.4035,
      longitude: 26.1915,
      radius: [
        GeofenceRadius(id: 'radius_1000m', length: 3400),
      ],
    ),
    Geofence(
      id: 'place_4',
      latitude: 44.3590,
      longitude: 26.1405,
      radius: [
        GeofenceRadius(id: 'radius_1000m', length: 3000),
      ],
    ),
    Geofence(
      id: 'place_5',
      latitude: 44.4064,
      longitude: 26.0864,
      radius: [
        GeofenceRadius(id: 'radius_1000m', length: 3800),
      ],
    ),
    Geofence(
      id: 'place_6',
      latitude: 44.4338,
      longitude: 26.0022,
      radius: [
        GeofenceRadius(id: 'radius_1000m', length: 3550),
      ],
    ),
  ];

  var _geofenceColors = <Color>[
    Colors.yellow.withOpacity(0.35),
    Colors.red.withOpacity(0.2),
    Colors.green.withOpacity(0.25),
    Colors.blue.withOpacity(0.2),
    Colors.deepPurple.withOpacity(0.2),
    Colors.orange.withOpacity(0.2),
  ];

  // map
  final mapController = MapController();
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
                  _markerPoz = LatLng(double.parse(latlng.latitude.toStringAsFixed(4)),
                      double.parse(latlng.longitude.toStringAsFixed(4)));
                });
                modalBottomSheet();
              },
              initialZoom: 10.5,
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
                      color: _geofenceColors[0]),
                  CircleMarker(
                    point: LatLng(_geofenceList[1].latitude, _geofenceList[1].longitude),
                    radius: _geofenceList[1].radius[0].length,
                    useRadiusInMeter: true,
                    color: _geofenceColors[1],
                  ),
                  CircleMarker(
                    point: LatLng(_geofenceList[2].latitude, _geofenceList[2].longitude),
                    radius: _geofenceList[2].radius[0].length,
                    useRadiusInMeter: true,
                    color: _geofenceColors[2],
                  ),
                  CircleMarker(
                    point: LatLng(_geofenceList[3].latitude, _geofenceList[3].longitude),
                    radius: _geofenceList[3].radius[0].length,
                    useRadiusInMeter: true,
                    color: _geofenceColors[3],
                  ),
                  CircleMarker(
                    point: LatLng(_geofenceList[4].latitude, _geofenceList[4].longitude),
                    radius: _geofenceList[4].radius[0].length,
                    useRadiusInMeter: true,
                    color: _geofenceColors[4],
                  ),
                  CircleMarker(
                    point: LatLng(_geofenceList[5].latitude, _geofenceList[5].longitude),
                    radius: _geofenceList[5].radius[0].length,
                    useRadiusInMeter: true,
                    color: _geofenceColors[5],
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
                    minOpacity: 1,
                    blurFactor: 0.5,
                    layerOpacity: 0.75,
                    radius: 35,
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
                          '+100 pts/min',
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
                  tutorialDialog();
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
                  if (_geofenceColors[0].opacity != 0) {
                    setState(() {
                      _geofenceColors[0] = Colors.yellow.withOpacity(0);
                      _geofenceColors[1] = Colors.red.withOpacity(0);
                      _geofenceColors[2] = Colors.green.withOpacity(0);
                      _geofenceColors[3] = Colors.blue.withOpacity(0);
                      _geofenceColors[4] = Colors.deepPurple.withOpacity(0);
                      _geofenceColors[5] = Colors.orange.withOpacity(0);
                    });
                  } else {
                    setState(() {
                      _geofenceColors[0] = Colors.yellow.withOpacity(0.35);
                      _geofenceColors[1] = Colors.red.withOpacity(0.2);
                      _geofenceColors[2] = Colors.green.withOpacity(0.25);
                      _geofenceColors[3] = Colors.blue.withOpacity(0.2);
                      _geofenceColors[4] = Colors.deepPurple.withOpacity(0.2);
                      _geofenceColors[5] = Colors.orange.withOpacity(0.2);
                    });
                  }
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
                if (mapController.camera.rotation != 0) {
                  setState(() {
                    mapController.rotate(0);
                  });
                }
              },
              child: Image.asset(
                'lib/assets/images/north100.png',
              ), // Needed when having multiple FABs
            ),
          ),
          Positioned(
            top: 32,
            left: 16,
            child: Container(
              color: my_colors.Colors.greyBackground,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          color: Colors.green,
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          color: Colors.yellow.shade700,
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("30"),
                        Text("50"),
                        Text("70"),
                        Text("90 db(A)"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
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
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: my_colors.Colors.primary),
                      Text(' ${_markerPoz.latitude.toStringAsFixed(4)}, ${_markerPoz.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
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

  Future<void> tutorialDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How it works'),
          backgroundColor: my_colors.Colors.greyBackground,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      const TextSpan(
                        text: 'You\'re viewing a sound map with color-coded noise levels.\n\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(
                        text: 'Press anywhere on the map to see the noise details for that point.\n\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(
                        text: 'Contributing to the map:\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(
                        text: '- record sound for one minute\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(
                        text: '- get points to compete with friends\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(
                        text: '- monthly competitions - score resets, score zones change, leaders are rewarded ',
                        style: TextStyle(color: Colors.black),
                      ),
                      WidgetSpan(
                        child: Image.asset('lib/assets/images/trophy.png', width: 16, height: 16),
                      ),
                      const TextSpan(
                        text: '\n- score zones give you multipliers\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(
                        text: '- collect all the achievements\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(
                        text: '- contribute daily and try to get the longest streak\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(
                        text: '- have fun and help the community!\n\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(text: 'Current zones:\n'),
                      const TextSpan(
                        text: 'Yellow',
                        style: TextStyle(color: Color(0xFFC2C21F), fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' - ×1.1\n'),
                      const TextSpan(
                        text: 'Red',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' and '),
                      const TextSpan(
                        text: 'Orange',
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' - ×1.2\n'),
                      const TextSpan(
                        text: 'Green',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' - ×1.3\n'),
                      const TextSpan(
                        text: 'Blue',
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' - ×1.4\n'),
                      const TextSpan(
                        text: 'Purple',
                        style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' - ×1.5'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Got it!',
                style: TextStyle(color: my_colors.Colors.primary),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
