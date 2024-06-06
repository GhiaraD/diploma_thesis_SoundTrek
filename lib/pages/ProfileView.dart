import 'package:SoundTrek/models/UsersInfo.dart';
import 'package:SoundTrek/pages/SettingsPage.dart';
import 'package:SoundTrek/services/AuthenticationService.dart';
import 'package:SoundTrek/services/MapService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../resources/colors.dart' as my_colors;
import '../resources/themes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _mapService = MapService();
  final _authService = AuthenticationService();
  UsersInfo userInfo = UsersInfo();
  int achievements = 0;

  Future<UsersInfo> getUser() async {
    String? uid = await _authService.getUID();
    return _mapService.fetchUserInfo(int.parse(uid!));
  }

  @override
  void initState() {
    super.initState();
    getUser().then((value) {
      setState(() {
        userInfo = value;
        achievements = 6;
      });
    });
  }

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(userInfo.timeMeasured.inMinutes.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Text("m", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Text("Time measured"),
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
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(userInfo.score.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Text(" pts", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Text("Score"),
                        ],
                      ),
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
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(userInfo.streak.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Text(" days", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Text("Streak"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userInfo.username.isEmpty ? "Username" : userInfo.username,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ],
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("All time stats:", style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total achievements", style: TextStyle(fontSize: 16)),
                          Text(achievements.toString(), style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Highest streak", style: TextStyle(fontSize: 16)),
                          Row(
                            children: [
                              Text(userInfo.allTimeStreak.toString(), style: const TextStyle(fontSize: 16)),
                              const Text(" days", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total time measured", style: TextStyle(fontSize: 16)),
                          Row(
                            children: [
                              Text(userInfo.allTimeMeasured.inMinutes.toString(), style: const TextStyle(fontSize: 16)),
                              const Text("m", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Most time measured / month", style: TextStyle(fontSize: 16)),
                              Text("Month", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(userInfo.maxTime.inMinutes.toString(), style: const TextStyle(fontSize: 16)),
                                  const Text("m", style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              Text(userInfo.monthMaxTime.toString(), style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Highest score / month", style: TextStyle(fontSize: 16)),
                              Text("Month", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Text(userInfo.maxScore.toString(), style: const TextStyle(fontSize: 16)),
                                  const Text(" pts", style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              Text(userInfo.monthMaxTime.toString(), style: const TextStyle(fontSize: 16)),
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
