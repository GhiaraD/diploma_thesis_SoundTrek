import 'package:SoundTrek/models/Achievement.dart';
import 'package:SoundTrek/models/UsersInfo.dart';
import 'package:SoundTrek/services/AuthenticationService.dart';
import 'package:SoundTrek/services/PostgresService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../resources/colors.dart' as my_colors;
import '../resources/themes.dart';

class AchievementView extends StatefulWidget {
  const AchievementView({super.key});

  @override
  State<AchievementView> createState() => _AchievementViewState();
}

class _AchievementViewState extends State<AchievementView> {
  final _postgresService = PostgresService();
  final _authService = AuthenticationService();
  UsersInfo userInfo = UsersInfo();
  bool isLoading = true;
  List<Achievement> achievements = [];
  List<Achievement> achievementsWithZeroProgress = [];
  List<Achievement> achievementsWithNonZeroProgress = [];
  List<Achievement> achievementsWhereProgressEqualsTotal = [];

  Future<UsersInfo> getUser() async {
    String? uid = await _authService.getUID();
    return _postgresService.fetchUserInfo(int.parse(uid!));
  }

  @override
  void initState() {
    super.initState();
    getUser().then((value) {
      setState(() {
        userInfo = value;
        achievements = [
          Achievement(
            title: "First Contribution",
            description: "Make your first noise recording.",
            currentProgress: userInfo.score > 0 ? 1 : 0,
            totalSteps: 1,
            image: 'lib/assets/images/undraw_blooming.svg',
          ),
          Achievement(
            title: "Early Bird",
            description: "Record noise data between 5 and 8 AM.",
            currentProgress: 0,
            totalSteps: 1,
            image: 'lib/assets/images/undraw_bird.svg',
          ),
          Achievement(
            title: "Night Owl",
            description: "Record noise data after 10 PM.",
            currentProgress: 0,
            totalSteps: 1,
            image: 'lib/assets/images/undraw_night.svg',
          ),
          Achievement(
            title: "Nighttime Guardian",
            description: "Record noise data for 7 consecutive nights after 10 PM.",
            currentProgress: 0,
            totalSteps: 7,
            image: 'lib/assets/images/undraw_batman.svg',
          ),
          Achievement(
            title: "Batman",
            description: "Record noise data for 30 consecutive nights after 10 PM.",
            currentProgress: 0,
            totalSteps: 30,
            image: 'lib/assets/images/undraw_batman2.svg',
          ),
          Achievement(
            title: "Persistent Recorder",
            description: "Record 50 noise data samples.",
            currentProgress: userInfo.allTimeMeasured.inMinutes,
            totalSteps: 50,
            image: 'lib/assets/images/undraw_timeline.svg',
          ),
          Achievement(
            title: "Dedicated Contributor",
            description: "Record 200 noise data samples.",
            currentProgress: userInfo.allTimeMeasured.inMinutes,
            totalSteps: 200,
            image: 'lib/assets/images/undraw_recording.svg',
          ),
          Achievement(
            title: "Marathon Recorder",
            description: "Record 500 noise data samples.",
            currentProgress: userInfo.allTimeMeasured.inMinutes,
            totalSteps: 500,
            image: 'lib/assets/images/undraw_marathon.svg',
          ),
          Achievement(
            title: "High Score",
            description: "Achieve a score of 3,000 points.",
            currentProgress: userInfo.score,
            totalSteps: 10000,
            image: 'lib/assets/images/undraw_score.svg',
          ),
          Achievement(
            title: "Record Breaker",
            description: "Achieve a score of 10,000 points.",
            currentProgress: userInfo.score,
            totalSteps: 50000,
            image: 'lib/assets/images/undraw_record.svg',
          ),
          Achievement(
            title: "Streak Starter",
            description: "Achieve a 3-day streak.",
            currentProgress: userInfo.streak > 3 ? 3 : userInfo.streak,
            totalSteps: 3,
            image: 'lib/assets/images/undraw_booking.svg',
          ),
          Achievement(
            title: "Streak Veteran",
            description: "Achieve a 14-day streak.",
            currentProgress: userInfo.streak > 14 ? 14 : userInfo.streak,
            totalSteps: 14,
            image: 'lib/assets/images/undraw_journey.svg',
          ),
          Achievement(
            title: "Streak Master",
            description: "Achieve a 30-day streak.",
            currentProgress: userInfo.streak > 30 ? 30 : userInfo.streak,
            totalSteps: 30,
            image: 'lib/assets/images/undraw_calendar.svg',
          ),
          Achievement(
            title: "Community Leader",
            description: "Achieve a top 10 rank in the score or streak leaderboard.",
            currentProgress: 0,
            totalSteps: 1,
            image: 'lib/assets/images/undraw_winner.svg',
          ),
          Achievement(
            title: "Peak Performer",
            description: "Achieve the highest monthly score.",
            currentProgress: 0,
            totalSteps: 1,
            image: 'lib/assets/images/undraw_winner2.svg',
          ),
        ];
        achievementsWithZeroProgress = achievements.where((achievement) => achievement.currentProgress == 0).toList();
        achievementsWithNonZeroProgress = achievements
            .where((achievement) =>
                achievement.currentProgress != 0 && achievement.currentProgress != achievement.totalSteps)
            .toList();
        achievementsWhereProgressEqualsTotal =
            achievements.where((achievement) => achievement.currentProgress == achievement.totalSteps).toList();
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: my_colors.Colors.greyBackground,
        appBar: AppBar(
          backgroundColor: my_colors.Colors.primaryOverlay,
          automaticallyImplyLeading: false,
          title: const Text("Achievements", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: "All"),
              Tab(text: "Not started"),
              Tab(text: "In progress"),
              Tab(text: "Completed"),
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
                    children: [
                      AllAchievementList(achievements: achievements),
                      AllAchievementList(achievements: achievementsWithZeroProgress),
                      AllAchievementList(achievements: achievementsWithNonZeroProgress),
                      AllAchievementList(achievements: achievementsWhereProgressEqualsTotal),
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

// class AchievementList extends StatelessWidget {
//   const AchievementList({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: 10,
//       itemBuilder: (context, index) {
//         return Card(
//           child: ListTile(
//             tileColor: my_colors.Colors.greyBackground,
//             leading: SvgPicture.asset(
//               'lib/assets/images/undraw_test.svg',
//               semanticsLabel: 'My SVG Image',
//               height: 50,
//               width: 30,
//             ),
//             title: const Text("Title"),
//             subtitle: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text("lorem ipsum descriere lorem"),
//               SizedBox(height: 5),
//               LinearProgressIndicator(
//                 value: 1 / 2,
//                 color: my_colors.Colors.primary,
//               ),
//             ]),
//             trailing: const Text("1/2"),
//           ),
//         );
//       },
//     );
//   }
// }

class AllAchievementList extends StatefulWidget {
  List<Achievement> achievements;

  AllAchievementList({super.key, required this.achievements});

  @override
  State<AllAchievementList> createState() => _AllAchievementListState();
}

class _AllAchievementListState extends State<AllAchievementList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.achievements.length,
      itemBuilder: (context, index) {
        final achievement = widget.achievements[index];
        return Card(
          child: ListTile(
            tileColor: my_colors.Colors.greyBackground,
            leading: SizedBox(
              width: 85,
              height: 56,
              child: SvgPicture.asset(
                achievement.image,
                semanticsLabel: 'My SVG Image',
                height: 56,
                width: 85,
              ),
            ),
            title: Text(achievement.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.description),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: achievement.currentProgress / achievement.totalSteps,
                  color: my_colors.Colors.primary,
                ),
              ],
            ),
            trailing: Text("${achievement.currentProgress}/${achievement.totalSteps}"),
          ),
        );
      },
    );
  }
}

class HalfPipePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    var path = Path();

    // Start drawing from the left side
    path.moveTo(size.width * 0.1, 0);
    path.lineTo(size.width * 0.1, size.height * 0.5);

    // Draw the left curve upside down
    path.quadraticBezierTo(size.width * 0.1, size.height, size.width * 0.4, size.height * 0.5);

    // Draw the flat bottom (now top)
    path.lineTo(size.width * 0.6, size.height * 0.5);

    // Draw the right curve upside down
    path.quadraticBezierTo(size.width * 0.9, size.height, size.width * 0.9, size.height * 0.5);

    // End at the right side
    path.lineTo(size.width * 0.9, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
