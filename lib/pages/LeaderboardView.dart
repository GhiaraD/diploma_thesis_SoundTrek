import 'package:SoundTrek/models/UsersInfo.dart';
import 'package:SoundTrek/services/AuthenticationService.dart';
import 'package:SoundTrek/services/PostgresService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../resources/colors.dart' as my_colors;
import '../resources/themes.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  final _mapService = PostgresService();
  final _authService = AuthenticationService();
  List<UsersInfo> users = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: my_colors.Colors.greyBackground,
        appBar: AppBar(
          backgroundColor: my_colors.Colors.primaryOverlay,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Leaderboard", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text("This month",
                        style: TextStyle(
                          fontSize: 10,
                          color: my_colors.Colors.primary,
                        )),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "All time",
                      style: TextStyle(
                        fontSize: 10,
                        color: my_colors.Colors.primary,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          bottom: const TabBar(
            tabAlignment: TabAlignment.center,
            tabs: [
              Tab(text: "Top Scorers"),
              Tab(text: "Top Streaks"),
            ],
            indicatorColor: my_colors.Colors.primary,
            labelColor: my_colors.Colors.primary,
            overlayColor: MaterialStatePropertyAll<Color>(my_colors.Colors.primaryOverlay),
          ),
        ),
        body: Stack(
          children: [
            const TabBarView(
              children: [
                LeaderboardList(),
                LeaderboardList(),
              ],
            ),
            Positioned(
              top: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 40), // Specify the size of the CustomPaint area.
                painter: CurvedTopPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardList extends StatelessWidget {
  const LeaderboardList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            tileColor: my_colors.Colors.greyBackground,
            leading: Text((index + 1).toString()),
            title: Row(
              children: [
                SvgPicture.asset(
                  'lib/assets/images/undraw_test.svg',
                  semanticsLabel: 'My SVG Image',
                  height: 25,
                  width: 20,
                ),
                const SizedBox(width: 10),
                const Text("Name Surname"),
              ],
            ),
            trailing: const Text("10000"),
          ),
        );
      },
    );
  }
}
