import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:latlong2/latlong.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../resources/colors.dart' as my_colors;
import '../resources/themes.dart' as my_themes;

class StatsPage extends StatefulWidget {
  final LatLng latlng;

  const StatsPage(this.latlng, {super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<SalesData> chartData = [
      SalesData(2010, 35),
      SalesData(2011, 28),
      SalesData(2012, 34),
      SalesData(2013, 97),
      SalesData(2014, null),
      SalesData(2015, 32),
      SalesData(2016, 40),
      SalesData(2017, 32),
      SalesData(2018, 40)
    ];
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
              TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 8),
                    child: Scrollable(
                      viewportBuilder: (BuildContext context, ViewportOffset position) {
                        return SingleChildScrollView(
                          controller: ScrollController(),
                          child: Column(
                            children: [
                              const Text("LAeq"),
                              graph(chartData),
                              const SizedBox(height: 8),
                              const Text("LA50"),
                              graph(chartData),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Text("Week"),
                  const Text("Week"),
                  const Text("Week"),
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
    // return DefaultTabController(
    //   length: 4,
    //   child: Scaffold(
    //     backgroundColor: my_colors.Colors.greyBackground,
    //     appBar: AppBar(
    //       backgroundColor: my_colors.Colors.primaryOverlay,
    //       automaticallyImplyLeading: true,
    //       title: const Text("Stats", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    //       bottom: PreferredSize(
    //         preferredSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 10),
    //         child: Column(
    //           children: [
    //             Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
    //               child: Row(
    //                 children: [
    //                   const Icon(Icons.location_on, color: my_colors.Colors.primary),
    //                   Text(
    //                       '${widget.latlng.latitude.toStringAsFixed(4)}, ${widget.latlng.longitude.toStringAsFixed(4)}',
    //                       style: const TextStyle(
    //                           color: my_colors.Colors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
    //                 ],
    //               ),
    //             ),
    //             const TabBar(
    //               isScrollable: true,
    //               tabAlignment: TabAlignment.center,
    //               tabs: [
    //                 Tab(text: "Day"),
    //                 Tab(text: "Week"),
    //                 Tab(text: "Month"),
    //                 Tab(text: "Year"),
    //               ],
    //               indicatorColor: my_colors.Colors.primary,
    //               labelColor: my_colors.Colors.primary,
    //               overlayColor: MaterialStatePropertyAll<Color>(my_colors.Colors.primaryOverlay),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //     body: Stack(
    //       children: [
    //         TabBarView(
    //           children: [
    //             Padding(
    //               padding: const EdgeInsets.only(top: 16.0, right: 8),
    //               child: Scrollable(
    //                 viewportBuilder: (BuildContext context, ViewportOffset position) {
    //                   return SingleChildScrollView(
    //                     controller: ScrollController(),
    //                     child: Column(
    //                       children: [
    //                         const Text("LAeq"),
    //                         graph(chartData),
    //                         const Text("LA50"),
    //                         graph(chartData),
    //                       ],
    //                     ),
    //                   );
    //                 },
    //               ),
    //             ),
    //             const Text("Week"),
    //             const Text("Week"),
    //             const Text("Week"),
    //           ],
    //         ),
    //         Positioned(
    //           top: 0,
    //           child: CustomPaint(
    //             size: Size(MediaQuery.of(context).size.width, 40), // Specify the size of the CustomPaint area.
    //             painter: my_themes.CurvedTopPainter(),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}

Widget graph(List<SalesData> chartData) {
  return SfCartesianChart(
    primaryXAxis: const NumericAxis(),
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
      LineSeries<SalesData, int>(
        dataSource: chartData,
        xValueMapper: (SalesData sales, _) => sales.year,
        yValueMapper: (SalesData sales, _) => sales.sales,
        emptyPointSettings: const EmptyPointSettings(
          mode: EmptyPointMode.gap,
        ),
      )
    ],
  );
}

class SalesData {
  int year;
  int? sales;

  SalesData(this.year, this.sales);
}
