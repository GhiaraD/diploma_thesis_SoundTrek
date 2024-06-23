import 'package:SoundTrek/models/Achievement.dart';
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
  bool isLoading = true;

  Future<void> fetchData() async {
    await Future.delayed(const Duration(milliseconds: 50));
    setState(() {
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
                : const TabBarView(
                    children: [
                      AllAchievementList(),
                      AchievementList(),
                      AchievementList(),
                      AchievementList(),
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

class AchievementList extends StatelessWidget {
  const AchievementList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            tileColor: my_colors.Colors.greyBackground,
            leading: SvgPicture.asset(
              'lib/assets/images/undraw_test.svg',
              semanticsLabel: 'My SVG Image',
              height: 50,
              width: 30,
            ),
            title: const Text("Title"),
            subtitle: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("lorem ipsum descriere lorem"),
              SizedBox(height: 5),
              LinearProgressIndicator(
                value: 1 / 2,
                color: my_colors.Colors.primary,
              ),
            ]),
            trailing: const Text("1/2"),
          ),
        );
      },
    );
  }
}

List<Achievement> achievements = [
  Achievement(
    title: "First Contribution",
    description: "Make your first noise recording.",
    currentProgress: 1,
    totalSteps: 1,
    image: 'lib/assets/images/undraw_blooming.svg',
  ),
  Achievement(
    title: "Score Multiplier",
    description: "Earn a score multiplier by recording in a score zone.",
    currentProgress: 1,
    totalSteps: 1,
    image: 'lib/assets/images/undraw_circle.svg',
  ),
  Achievement(
    title: "Neighborhood Watcher",
    description: "Record noise data in 3 different score zones.",
    currentProgress: 1,
    totalSteps: 3,
    image: 'lib/assets/images/undraw_circles.svg',
  ),
  Achievement(
    title: "City Explorer",
    description: "Record noise data in all score zones.",
    currentProgress: 1,
    totalSteps: 6,
    image: 'lib/assets/images/undraw_all_data.svg',
  ),
  Achievement(
    title: "Early Bird",
    description: "Record noise data between 5 and 8 AM.",
    currentProgress: 1,
    totalSteps: 1,
    image: 'lib/assets/images/undraw_bird.svg',
  ),
  Achievement(
    title: "Night Owl",
    description: "Record noise data after 10 PM.",
    currentProgress: 1,
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
    currentProgress: 20,
    totalSteps: 50,
    image: 'lib/assets/images/undraw_timeline.svg',
  ),
  Achievement(
    title: "Dedicated Contributor",
    description: "Record 200 noise data samples.",
    currentProgress: 100,
    totalSteps: 200,
    image: 'lib/assets/images/undraw_recording.svg',
  ),
  Achievement(
    title: "Marathon Recorder",
    description: "Record 500 noise data samples.",
    currentProgress: 0,
    totalSteps: 500,
    image: 'lib/assets/images/undraw_marathon.svg',
  ),
  Achievement(
    title: "Noise Hunter",
    description: "Record the loudest noise level in a zone.",
    currentProgress: 1,
    totalSteps: 1,
    image: 'lib/assets/images/undraw_aircraft.svg',
  ),
  Achievement(
    title: "Silence Seeker",
    description: "Record the quietest noise level in a zone.",
    currentProgress: 1,
    totalSteps: 1,
    image: 'lib/assets/images/undraw_quiet.svg',
  ),
  Achievement(
    title: "High Score",
    description: "Achieve a score of 3,000 points.",
    currentProgress: 5000,
    totalSteps: 10000,
    image: 'lib/assets/images/undraw_score.svg',
  ),
  Achievement(
    title: "Record Breaker",
    description: "Achieve a score of 10,000 points.",
    currentProgress: 25000,
    totalSteps: 50000,
    image: 'lib/assets/images/undraw_record.svg',
  ),
  Achievement(
    title: "Streak Starter",
    description: "Achieve a 3-day streak.",
    currentProgress: 1,
    totalSteps: 3,
    image: 'lib/assets/images/undraw_booking.svg',
  ),
  Achievement(
    title: "Streak Veteran",
    description: "Achieve a 14-day streak.",
    currentProgress: 7,
    totalSteps: 14,
    image: 'lib/assets/images/undraw_journey.svg',
  ),
  Achievement(
    title: "Streak Master",
    description: "Achieve a 30-day streak.",
    currentProgress: 7,
    totalSteps: 14,
    image: 'lib/assets/images/undraw_calendar.svg',
  ),
  Achievement(
    title: "Community Leader",
    description: "Achieve a top 10 rank in the leaderboard.",
    currentProgress: 1,
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
  Achievement(
    title: "Busy Bee",
    description: "Record noise data every hour for 24 hours.",
    currentProgress: 0,
    totalSteps: 24,
    image: 'lib/assets/images/undraw_busy.svg',
  ),
];

class AllAchievementList extends StatelessWidget {
  const AllAchievementList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
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
