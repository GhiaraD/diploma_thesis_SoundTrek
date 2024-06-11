import 'package:SoundTrek/models/UsersInfo.dart';
import 'package:SoundTrek/services/AuthenticationService.dart';
import 'package:SoundTrek/services/PostgresService.dart';
import 'package:flutter/material.dart';

import '../resources/colors.dart' as my_colors;
import '../resources/themes.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  final _postgresService = PostgresService();
  final _authService = AuthenticationService();
  List<UsersInfo> topScorers = [];
  List<UsersInfo> topStreaks = [];
  List<UsersInfo> topMaxScores = [];
  List<UsersInfo> topAllTimeStreaks = [];
  LeaderboardTime leaderboardTime = LeaderboardTime.thisMonth;

  // UsersInfo userInfo = UsersInfo();
  bool isLoading = true;

  Future<UsersInfo> getUser() async {
    String? uid = await _authService.getUID();
    return _postgresService.fetchUserInfo(int.parse(uid!));
  }

  Future<List<UsersInfo>> getLeaderboardByScore() async {
    return _postgresService.getTopUsersByScore();
  }

  Future<List<UsersInfo>> getLeaderboardByMaxScore() async {
    return _postgresService.getTopUsersByMaxScore();
  }

  Future<List<UsersInfo>> getLeaderboardByStreak() async {
    return _postgresService.getTopUsersByStreak();
  }

  Future<List<UsersInfo>> getLeaderboardByAllTimeStreak() async {
    return _postgresService.getTopUsersByAllTimeStreak();
  }

  Future<void> fetchData() async {
    final topScorers = await _postgresService.getTopUsersByScore();
    final topStreaks = await _postgresService.getTopUsersByStreak();
    final topMaxScores = await _postgresService.getTopUsersByMaxScore();
    final topAllTimeStreaks = await _postgresService.getTopUsersByAllTimeStreak();
    setState(() {
      this.topScorers = topScorers;
      this.topStreaks = topStreaks;
      this.topMaxScores = topMaxScores;
      this.topAllTimeStreaks = topAllTimeStreaks;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

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
                    onPressed: () {
                      setState(() {
                        leaderboardTime = LeaderboardTime.thisMonth;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: leaderboardTime == LeaderboardTime.thisMonth
                          ? const MaterialStatePropertyAll<Color>(my_colors.Colors.greyBackground)
                          : const MaterialStatePropertyAll<Color>(my_colors.Colors.primaryOverlay),
                    ),
                    child: const Text("This month",
                        style: TextStyle(
                          fontSize: 10,
                          color: my_colors.Colors.primary,
                        )),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        leaderboardTime = LeaderboardTime.allTime;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: leaderboardTime == LeaderboardTime.allTime
                          ? const MaterialStatePropertyAll<Color>(my_colors.Colors.greyBackground)
                          : const MaterialStatePropertyAll<Color>(my_colors.Colors.primaryOverlay),
                    ),
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
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: leaderboardTime == LeaderboardTime.thisMonth
                        ? [
                            LeaderboardList(users: topScorers, leaderboardType: LeaderboardType.score),
                            LeaderboardList(users: topStreaks, leaderboardType: LeaderboardType.streak),
                          ]
                        : [
                            LeaderboardList(users: topMaxScores, leaderboardType: LeaderboardType.maxScore),
                            LeaderboardList(users: topAllTimeStreaks, leaderboardType: LeaderboardType.allTimeStreak),
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
  const LeaderboardList({super.key, required this.users, required this.leaderboardType});

  final List<UsersInfo> users;
  final LeaderboardType leaderboardType;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        String trailingText;
        switch (leaderboardType) {
          case LeaderboardType.score:
            trailingText = "${user.score} pts";
            break;
          case LeaderboardType.streak:
            trailingText = "${user.streak} days";
            break;
          case LeaderboardType.maxScore:
            trailingText = "${user.maxScore} pts";
            break;
          case LeaderboardType.allTimeStreak:
            trailingText = "${user.allTimeStreak} days";
            break;
        }

        return Card(
          child: ListTile(
            tileColor: my_colors.Colors.greyBackground,
            leading: leading(index + 1),
            title: Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 32,
                  color: my_colors.Colors.secondaryVariant,
                ),
                const SizedBox(width: 10),
                Text(user.username),
              ],
            ),
            trailing: Text(trailingText),
          ),
        );
      },
    );
  }

  Widget leading(int index) {
    if (index == 1) {
      return const Image(image: AssetImage("lib/assets/images/gold_cup.png"), width: 24, height: 24);
    } else if (index == 2) {
      return const Image(image: AssetImage("lib/assets/images/silver_cup.png"), width: 24, height: 24);
    } else if (index == 3) {
      return const Image(image: AssetImage("lib/assets/images/bronze_cup.png"), width: 24, height: 24);
    } else {
      return Text("$index");
    }
  }
}

enum LeaderboardType { score, streak, maxScore, allTimeStreak }

enum LeaderboardTime { thisMonth, allTime }
