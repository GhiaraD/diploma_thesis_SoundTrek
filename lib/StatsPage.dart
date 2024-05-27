import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../resources/colors.dart' as my_colors;
import '../resources/themes.dart' as my_themes;

class StatsPage extends StatefulWidget {
  final LatLng latlng;

  StatsPage(this.latlng);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: my_colors.Colors.greyBackground,
        appBar: AppBar(
          backgroundColor: my_colors.Colors.primaryOverlay,
          automaticallyImplyLeading: true,
          title: const Text("Stats", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          bottom: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height / 10),
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
        body: Stack(
          children: [
            const TabBarView(
              children: [
                // TODO: grafice aici
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
    );
  }
}
