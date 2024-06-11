import 'package:SoundTrek/models/NoiseLevel.dart';
import 'package:SoundTrek/services/PostgresService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../resources/colors.dart' as my_colors;
import '../../resources/themes.dart' as my_themes;

class StatsPage extends StatefulWidget {
  final LatLng latlng;
  final DateTime latestDate;

  const StatsPage(this.latlng, this.latestDate, {super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final _postgresService = PostgresService();
  late DateTime selectedDate;
  List<NoiseLevel> dayData = [];
  List<NoiseLevel> weekData = [];
  List<NoiseLevel> monthData = [];
  List<NoiseLevel> yearData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.latestDate;
    _fetchData();
  }

  Future<void> _fetchData() async {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    dayData = (await _postgresService.fetchNoiseLevelsByDay(
        widget.latlng.latitude, widget.latlng.longitude, formatter.format(selectedDate)));
    dayData.add(NoiseLevel(
      timestamp: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0),
      LAeq: null,
      LA50: null,
      latitude: widget.latlng.latitude,
      longitude: widget.latlng.longitude,
      measurementsCount: null,
    ));
    dayData.add(NoiseLevel(
      timestamp: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59),
      LAeq: null,
      LA50: null,
      latitude: widget.latlng.latitude,
      longitude: widget.latlng.longitude,
      measurementsCount: null,
    ));
    NoiseLevel.sortNoiseLevels(dayData);

    weekData = await _postgresService.fetchNoiseLevelsByWeek(
        widget.latlng.latitude, widget.latlng.longitude, formatter.format(selectedDate));
    int daysToSubtract = selectedDate.weekday - DateTime.monday;
    int daysToAdd = DateTime.sunday - selectedDate.weekday;
    weekData.add(NoiseLevel(
      timestamp: DateTime(selectedDate.year, selectedDate.month, selectedDate.day - daysToSubtract, 0, 0, 0),
      LAeq: null,
      LA50: null,
      latitude: widget.latlng.latitude,
      longitude: widget.latlng.longitude,
      measurementsCount: null,
    ));
    weekData.add(NoiseLevel(
      timestamp: DateTime(selectedDate.year, selectedDate.month, selectedDate.day + daysToAdd, 23, 59, 59),
      LAeq: null,
      LA50: null,
      latitude: widget.latlng.latitude,
      longitude: widget.latlng.longitude,
      measurementsCount: null,
    ));
    NoiseLevel.sortNoiseLevels(weekData);

    monthData = await _postgresService.fetchNoiseLevelsByMonth(
        widget.latlng.latitude, widget.latlng.longitude, formatter.format(selectedDate));
    int lastDayMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    monthData.add(NoiseLevel(
      timestamp: DateTime(selectedDate.year, selectedDate.month, 1, 0, 0, 0),
      LAeq: null,
      LA50: null,
      latitude: widget.latlng.latitude,
      longitude: widget.latlng.longitude,
      measurementsCount: null,
    ));
    monthData.add(NoiseLevel(
      timestamp: DateTime(selectedDate.year, selectedDate.month, lastDayMonth, 23, 59, 59),
      LAeq: null,
      LA50: null,
      latitude: widget.latlng.latitude,
      longitude: widget.latlng.longitude,
      measurementsCount: null,
    ));
    NoiseLevel.sortNoiseLevels(monthData);

    yearData = await _postgresService.fetchNoiseLevelsByYear(
        widget.latlng.latitude, widget.latlng.longitude, formatter.format(selectedDate));
    yearData.add(NoiseLevel(
      timestamp: DateTime(selectedDate.year, 1, 1, 0, 0, 0),
      LAeq: null,
      LA50: null,
      latitude: widget.latlng.latitude,
      longitude: widget.latlng.longitude,
      measurementsCount: null,
    ));
    yearData.add(NoiseLevel(
      timestamp: DateTime(selectedDate.year, 12, 31, 23, 59, 59),
      LAeq: null,
      LA50: null,
      latitude: widget.latlng.latitude,
      longitude: widget.latlng.longitude,
      measurementsCount: null,
    ));
    NoiseLevel.sortNoiseLevels(yearData);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: my_colors.Colors.greyBackground,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: my_colors.Colors.primaryOverlay,
                automaticallyImplyLeading: true,
                expandedHeight: 136,
                floating: true,
                pinned: true,
                snap: false,
                title: const Text("Stats", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                bottom: PreferredSize(
                  preferredSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 10 + 12),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: my_colors.Colors.primary),
                            Text(
                                '${widget.latlng.latitude.toStringAsFixed(4)}, ${widget.latlng.longitude.toStringAsFixed(4)}',
                                style: const TextStyle(
                                    color: my_colors.Colors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      const TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.center,
                        tabs: [
                          Tab(text: "Day"),
                          Tab(text: "Week"),
                          Tab(text: "Month"),
                          Tab(text: "Year"),
                        ],
                        indicatorColor: my_colors.Colors.primary,
                        labelColor: my_colors.Colors.primary,
                        overlayColor: MaterialStatePropertyAll<Color>(my_colors.Colors.primaryOverlay),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: Stack(
            children: [
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        pageContent(dayData),
                        pageContent(weekData, type: 1),
                        pageContent(monthData, type: 2),
                        pageContent(yearData, type: 3),
                      ],
                    ),
              Positioned(
                top: 0,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 40), // Specify the size of the CustomPaint area.
                  painter: my_themes.CurvedTopPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pageContent(List<NoiseLevel> chartData, {int type = 0}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 8),
      child: Scrollable(
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return SingleChildScrollView(
            controller: ScrollController(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        if (type == 0) selectedDate = selectedDate.subtract(const Duration(days: 1));
                        if (type == 1) selectedDate = selectedDate.subtract(const Duration(days: 7));
                        if (type == 2) {
                          selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, selectedDate.day);
                        }
                        if (type == 3) {
                          selectedDate = DateTime(selectedDate.year - 1, selectedDate.month, selectedDate.day);
                        }
                        updateDate(selectedDate);
                      },
                    ),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Text(
                        DateFormat('dd MMM yyyy').format(selectedDate),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        if (type == 0) selectedDate = selectedDate.add(const Duration(days: 1));
                        if (type == 1) selectedDate = selectedDate.add(const Duration(days: 7));
                        if (type == 2) {
                          selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day);
                        }
                        if (type == 3) {
                          selectedDate = DateTime(selectedDate.year + 1, selectedDate.month, selectedDate.day);
                        }
                        updateDate(selectedDate);
                      },
                    ),
                  ],
                ),
                const Text("LAeq"),
                graph(chartData),
                const SizedBox(height: 8),
                const Text("LA50"),
                graph(chartData, type: false),
              ],
            ),
          );
        },
      ),
    );
  }

  // Date Picker Method
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      await updateDate(picked);
    }
  }

  Future<void> updateDate(DateTime picked) async {
    setState(() {
      isLoading = true;
    });
    selectedDate = picked;
    await _fetchData();
  }
}

Widget graph(List<NoiseLevel> chartData, {bool type = true}) {
  return SfCartesianChart(
    primaryXAxis: const DateTimeAxis(),
    zoomPanBehavior: ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      enableDoubleTapZooming: false,
      enableSelectionZooming: true,
    ),
    trackballBehavior: TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.doubleTap,
      lineType: TrackballLineType.vertical,
      hideDelay: 2000,
    ),
    series: <CartesianSeries>[
      // Renders line chart
      LineSeries<NoiseLevel, DateTime>(
        markerSettings: const MarkerSettings(isVisible: true, width: 3, height: 3),
        dataSource: chartData,
        xValueMapper: (NoiseLevel noise, _) => noise.timestamp,
        yValueMapper: (NoiseLevel noise, _) => type ? noise.LAeq : noise.LA50,
        emptyPointSettings: const EmptyPointSettings(
          mode: EmptyPointMode.gap,
        ),
      )
    ],
  );
}
