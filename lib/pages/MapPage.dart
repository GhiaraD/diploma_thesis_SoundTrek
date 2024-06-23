import 'dart:async';

import 'package:SoundTrek/models/NoiseLevel.dart';
import 'package:SoundTrek/models/UsersInfo.dart';
import 'package:SoundTrek/pages/StatsPage.dart';
import 'package:SoundTrek/services/AuthenticationService.dart';
import 'package:SoundTrek/services/FFT.dart';
import 'package:SoundTrek/services/PostgresService.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../resources/colors.dart' as my_colors;
import '../resources/themes.dart' as my_themes;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<StatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Geofences
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
      longitude: 26.0000,
      radius: [
        GeofenceRadius(id: 'radius_1000m', length: 3550),
      ],
    ),
    Geofence(
      id: 'place_7',
      latitude: 44.4395,
      longitude: 26.0529,
      radius: [
        GeofenceRadius(id: 'radius_1000m', length: 700),
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
    Colors.purpleAccent.withOpacity(0.2),
  ];
  final _geofenceMultipliers = <double>[1.1, 1.2, 1.3, 1.4, 1.5, 1.2, 1.6];
  double multiplier = 1.0;

  // backend services
  final _authService = AuthenticationService();
  final _postgresService = PostgresService();
  final _activityStreamController = StreamController<Activity>();

  // map
  final mapController = MapController();
  AlignOnUpdate _alignPositionOnUpdate = AlignOnUpdate.always;
  final StreamController<double?> _alignPositionStreamController = StreamController<double?>();
  LatLng _markerPoz = const LatLng(-90, -180);

  // This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(
      Geofence geofence, GeofenceRadius geofenceRadius, GeofenceStatus geofenceStatus, Location location) async {
    if (geofenceStatus == GeofenceStatus.ENTER) {
      (setState(() {
        multiplier = _geofenceMultipliers[_geofenceList.indexOf(geofence)];
      }));
    } else if (geofenceStatus == GeofenceStatus.EXIT) {
      (setState(() {
        multiplier = 1.0;
      }));
    }
    _geofenceStreamController.sink.add(geofence);
  }

  void _onLocationChanged(Location location) {
    myLocation = LatLng(location.latitude, location.longitude);
  }

// This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    print('prevActivity: ${prevActivity.toJson()}');
    print('currActivity: ${currActivity.toJson()}');
    _activityStreamController.sink.add(currActivity);
  }

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

  // heatmap
  List<WeightedLatLng> lowHeatmapData = [];
  List<WeightedLatLng> mediumHeatmapData = [];
  List<WeightedLatLng> highHeatmapData = [];
  final StreamController<void> _rebuildStream = StreamController.broadcast();

  _loadData() async {
    List<NoiseLevel> noise = await _postgresService.fetchMap();
    List<NoiseLevel> greenList = [];
    List<NoiseLevel> yellowList = [];
    List<NoiseLevel> redList = [];

    for (var noiseLevel in noise) {
      if (noiseLevel.LAeq! < 50) {
        greenList.add(noiseLevel);
      } else if (noiseLevel.LAeq! >= 50 && noiseLevel.LAeq! <= 80) {
        yellowList.add(noiseLevel);
      } else if (noiseLevel.LAeq! > 80) {
        redList.add(noiseLevel);
      }
    }

    setState(() {
      lowHeatmapData = greenList
          .map((e) =>
              WeightedLatLng(LatLng(double.parse(e.latitude.toString()), double.parse(e.longitude.toString())), 1))
          .toList();

      mediumHeatmapData = yellowList
          .map((e) =>
              WeightedLatLng(LatLng(double.parse(e.latitude.toString()), double.parse(e.longitude.toString())), 1))
          .toList();

      highHeatmapData = redList
          .map((e) =>
              WeightedLatLng(LatLng(double.parse(e.latitude.toString()), double.parse(e.longitude.toString())), 1))
          .toList();
    });
  }

  // recording
  int? sampleRate;
  bool isRecording = false;
  List<double> audio = [];
  List<double> latestMinuteAudio = [];
  ValueNotifier<double> recordingTime = ValueNotifier<double>(0.0);
  StreamSubscription<List<double>>? audioSubscription;
  double cutoffHigh = 20000; // High pass filter cutoff frequency in Hz
  double cutoffLow = 20; // Low pass filter cutoff frequency in Hz
  int minutesPassed = 1;
  bool processing = false;
  late LatLng myLocation;
  late LatLng lastRecordedLocation;

  void onAudio(List<double> buffer) async {
    audio.addAll(buffer);

    // Get the actual sampling rate, if not already known.
    sampleRate ??= await AudioStreamer().actualSampleRate;
    recordingTime.value = audio.length / sampleRate!;

    latestMinuteAudio.addAll(buffer);

    if (recordingTime.value > 60 * minutesPassed && !processing) {
      // Send data to server on a separate isolate
      processing = true;
      minutesPassed++;
      NoiseLevel noiseLevel = NoiseLevel(
          latitude: double.parse(myLocation.latitude.toStringAsFixed(4)),
          longitude: double.parse(myLocation.longitude.toStringAsFixed(4)),
          LAeq: 0.0,
          LA50: 0.0,
          timestamp: DateTime.now(),
          measurementsCount: 1);

      final arg = {
        "noiseLevel": noiseLevel.toJson(),
        "latestMinuteAudio": latestMinuteAudio,
      };

      // Call compute with serialized arguments
      compute(_filterAndUpload, arg);
      latestMinuteAudio = [];
      processing = false;
    }
  }

  static Future<void> _filterAndUpload(Map<String, dynamic> arg) async {
    final postgresService = PostgresService();
    final noiseLevel = NoiseLevel.fromJson(arg['noiseLevel']);
    var localLatestMinuteAudio = List<double>.from(arg['latestMinuteAudio']);

    localLatestMinuteAudio =
        applyBandpassFilter(localLatestMinuteAudio, 20, 20000, AudioStreamer.DEFAULT_SAMPLING_RATE);
    localLatestMinuteAudio = convertToSPL2(localLatestMinuteAudio);

    noiseLevel.LAeq = double.parse(calculateLAeq(localLatestMinuteAudio).toStringAsFixed(2));
    noiseLevel.LA50 = double.parse(calculateLA50(localLatestMinuteAudio).toStringAsFixed(2));

    await postgresService.postNoiseLevel(noiseLevel);
  }

  /// Call-back on error.
  void handleRecordingError(Object error) {
    setState(() => isRecording = false);
    if (kDebugMode) {
      print(error);
    }
  }

  /// Start audio sampling.
  void startRecording() async {
    minutesPassed = 1;
    // Set the sampling rate - works only on Android.
    AudioStreamer().sampleRate = AudioStreamer.DEFAULT_SAMPLING_RATE;

    // Start listening to the audio stream.
    audioSubscription = AudioStreamer().audioStream.listen(onAudio, onError: handleRecordingError);

    setState(() => isRecording = true);
  }

  /// Stop audio sampling.
  void stopRecording() async {
    audioSubscription?.cancel();
    audio = [];
    latestMinuteAudio = [];
    recordingTime.value = 0.0;
    setState(() => isRecording = false);
    _postgresService.updateUserScore(userInfo.userId, (100 * multiplier * (minutesPassed - 1)).toInt());
    _postgresService.updateUserStreak(userInfo.userId, userInfo.streak + 1);
    _postgresService.updateUserTimeMeasured(userInfo.userId, userInfo.timeMeasured.inMinutes + minutesPassed - 1);
    _postgresService.updateUserAllTimeMeasured(userInfo.userId, userInfo.allTimeMeasured.inMinutes + minutesPassed - 1);
    if (minutesPassed > 1) completedDialog();
  }

  // userInfo
  UsersInfo userInfo = UsersInfo();

  Future<UsersInfo> getUser() async {
    String? uid = await _authService.getUID();
    return _postgresService.fetchUserInfo(int.parse(uid!));
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: my_colors.Colors.greyBackground, // Set the color you want here
      systemNavigationBarIconBrightness: Brightness.dark, // Set icon brightness
    ));
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      _geofenceService.addLocationChangeListener(_onLocationChanged);
      _geofenceService.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
      _geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start(_geofenceList).catchError(_onError);

      _alignPositionOnUpdate = AlignOnUpdate.always;

      getUser().then((value) {
        userInfo = value;
      });
      // _alignPositionStreamController = StreamController<double?>();
    });
  }

  @override
  void dispose() {
    _geofenceService.removeGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    _geofenceService.removeLocationChangeListener(_onLocationChanged);
    _geofenceService.removeLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
    _geofenceService.removeActivityChangeListener(_onActivityChanged);
    _geofenceService.removeStreamErrorListener(_onError);
    _geofenceService.clearAllListeners();
    _geofenceService.stop();

    _alignPositionStreamController.close();
    _rebuildStream.close();

    stopRecording();
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

  Widget _buildContentView() {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              onTap: (point, latlng) async {
                setState(() {
                  _markerPoz = LatLng(double.parse(latlng.latitude.toStringAsFixed(4)),
                      double.parse(latlng.longitude.toStringAsFixed(4)));
                });
                NoiseLevel noiseLevel =
                    await _postgresService.fetchNoiseLevel(_markerPoz.latitude, _markerPoz.longitude);
                modalBottomSheet(noiseLevel);
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
                  CircleMarker(
                    point: LatLng(_geofenceList[6].latitude, _geofenceList[6].longitude),
                    radius: _geofenceList[6].radius[0].length,
                    useRadiusInMeter: true,
                    color: _geofenceColors[6],
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
              if (lowHeatmapData.isNotEmpty)
                HeatMapLayer(
                  tileDisplay: const TileDisplay.instantaneous(),
                  maxZoom: 22,
                  heatMapDataSource: InMemoryHeatMapDataSource(data: lowHeatmapData),
                  heatMapOptions: my_themes.Themes.heatMapOptions({
                    0.0: Colors.green,
                    1.0: Colors.green,
                  }),
                  reset: _rebuildStream.stream,
                ),
              if (mediumHeatmapData.isNotEmpty)
                HeatMapLayer(
                  tileDisplay: const TileDisplay.instantaneous(),
                  maxZoom: 22,
                  heatMapDataSource: InMemoryHeatMapDataSource(data: mediumHeatmapData),
                  heatMapOptions: my_themes.Themes.heatMapOptions({
                    0.0: Colors.orange,
                    1.0: Colors.orange,
                  }),
                  reset: _rebuildStream.stream,
                ),
              if (highHeatmapData.isNotEmpty)
                HeatMapLayer(
                  tileDisplay: const TileDisplay.instantaneous(),
                  maxZoom: 22,
                  heatMapDataSource: InMemoryHeatMapDataSource(data: highHeatmapData),
                  heatMapOptions: my_themes.Themes.heatMapOptions({
                    0.0: Colors.red,
                    1.0: Colors.red,
                  }),
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
            bottom: 20,
            right: MediaQuery.of(context).size.width / 2 - 75,
            child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: ValueListenableBuilder<double>(
                    valueListenable: recordingTime,
                    builder: (BuildContext context, double value, Widget? child) {
                      return TextButton(
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
                        onPressed: () async {
                          isRecording ? stopRecording() : startRecording();
                          setState(() {
                            _loadData();
                          });
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Icon(isRecording ? Icons.square : Icons.mic, color: my_colors.Colors.primary),
                            ),
                            //111.8 72.8
                            Padding(
                              padding:
                                  isRecording ? const EdgeInsets.only(left: 32, right: 32) : const EdgeInsets.all(0.0),
                              child: Column(
                                children: [
                                  Text(
                                    isRecording ? "${recordingTime.value.toStringAsFixed(2)} s" : 'Start contributing',
                                    style: const TextStyle(color: my_colors.Colors.primary),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '+',
                                        style: TextStyle(color: my_colors.Colors.primary),
                                      ),
                                      Text(
                                        isRecording
                                            ? ((100 * multiplier) * (minutesPassed - 1)).toStringAsFixed(0)
                                            : (100 * multiplier).toStringAsFixed(0),
                                        style: const TextStyle(color: my_colors.Colors.primary),
                                      ),
                                      Text(
                                        isRecording ? " pts" : ' pts/min',
                                        style: const TextStyle(color: my_colors.Colors.primary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ), // Needed when having multiple FABs
                      );
                    })),
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
                      _geofenceColors[6] = Colors.orange.withOpacity(0);
                    });
                  } else {
                    setState(() {
                      _geofenceColors[0] = Colors.yellow.withOpacity(0.35);
                      _geofenceColors[1] = Colors.red.withOpacity(0.2);
                      _geofenceColors[2] = Colors.green.withOpacity(0.25);
                      _geofenceColors[3] = Colors.blue.withOpacity(0.2);
                      _geofenceColors[4] = Colors.deepPurple.withOpacity(0.2);
                      _geofenceColors[5] = Colors.orange.withOpacity(0.2);
                      _geofenceColors[6] = Colors.purpleAccent.withOpacity(0.2);
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
                        Text("<30"),
                        Text("50"),
                        Text("80"),
                        Text(">100 db(A)"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 136,
            left: 16,
            child: Container(
              color: my_colors.Colors.greyBackground,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("--.-", style: TextStyle(fontSize: 24)),
                    Text(" dB(A)", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Add your bottom navigation bar here
    );
  }

  Future<void> modalBottomSheet(NoiseLevel noiseLevel) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');

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
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 5.0),
                        child: Icon(Icons.access_time, color: my_colors.Colors.primary),
                      ),
                      Text(formatter.format(noiseLevel.timestamp),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('LAeq: ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: my_colors.Colors.primary,
                                  )),
                              Text(noiseLevel.LAeq!.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black54,
                                  )),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('LA50: ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: my_colors.Colors.primary,
                                  )),
                              Text(noiseLevel.LA50!.toStringAsFixed(2),
                                  style: const TextStyle(
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
                            if (noiseLevel.LAeq != 0.0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => StatsPage(_markerPoz, noiseLevel.timestamp)),
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: 'No data available for this location',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: my_colors.Colors.greyDark,
                                textColor: my_colors.Colors.white,
                                fontSize: 16.0,
                              );
                            }
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
                        text: '- 1 minute of recording = points\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(
                        text: '- compete with friends\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(
                        text: '- score zones give you multipliers\n',
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
                        text: '\n- collect all the achievements\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(
                        text: '- contribute daily and try to get the biggest streak\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(
                        text: '- have fun and help the community!\n\n',
                        style: TextStyle(color: Colors.black),
                      ),
                      const TextSpan(text: 'Current score zones:\n'),
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
                      const TextSpan(text: ' - ×1.5\n'),
                      const TextSpan(
                        text: 'Pink',
                        style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' - ×1.6\n\n'),
                      const TextSpan(text: 'Don\'t forget to calibrate your smartphone for accurate results!'),
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

  Future<void> completedDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congrats!'),
          backgroundColor: my_colors.Colors.greyBackground,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SvgPicture.asset(
                  'lib/assets/images/undraw_map.svg',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '+ ${minutesPassed - 1} minutes contributed\n',
                        style: const TextStyle(color: Colors.black54, fontSize: 20),
                      ),
                      TextSpan(
                        text: '+ ${100 * (minutesPassed - 1) * multiplier} points achieved\n',
                        style: const TextStyle(color: Colors.black54, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Great!',
                style: TextStyle(color: my_colors.Colors.primary, fontSize: 20),
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
