import 'package:SoundTrek/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../resources/colors.dart' as my_colors;
import '../resources/themes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: my_colors.Colors.primaryOverlay,
        automaticallyImplyLeading: false,
        title: const Text("Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              }),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: my_colors.Colors.primaryOverlay,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text("1500 pts", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Score"),
                    ],
                  ),
                  Column(
                    children: [
                      Text("25 days", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Streak"),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.passthrough,
              children: [
                Positioned(
                  bottom: 50,
                  right: -16,
                  child: Container(
                    height: 58,
                    width: 700,
                    color: my_colors.Colors.primaryOverlay,
                  ),
                ),
                Positioned(
                  top: 50,
                  child: CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 40), // Specify the size of the CustomPaint area.
                    painter: CurvedTopPainter(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      children: [
                        Text("10m", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Time measured"),
                      ],
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: my_colors.Colors.greyBackground,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                    const Column(
                      children: [
                        Text("5", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Zones visited"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: 0,
                  child: SvgPicture.asset(
                    allowDrawingOutsideViewBox: true,
                    fit: BoxFit.fitHeight,
                    'lib/assets/images/waves2.svg',
                    semanticsLabel: 'My SVG Image',
                    height: 350,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("All time stats:", style: TextStyle(fontSize: 20)),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total achievements", style: TextStyle(fontSize: 16)),
                          Text("27", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Highest streak", style: TextStyle(fontSize: 16)),
                          Text("35 days", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total time measured", style: TextStyle(fontSize: 16)),
                          Text("2h:31m", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Most time measured / month", style: TextStyle(fontSize: 16)),
                              Text("Month", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("42m", style: TextStyle(fontSize: 16)),
                              Text("July 2023", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Highest score / month", style: TextStyle(fontSize: 16)),
                              Text("Month", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("2600 pts", style: TextStyle(fontSize: 16)),
                              Text("July 2023", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
