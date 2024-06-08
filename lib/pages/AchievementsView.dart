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
    await Future.delayed(const Duration(milliseconds: 500));
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
              Tab(text: "In progress"),
              Tab(text: "Completed"),
              Tab(text: "Unachieved"),
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
                      AchievementList(),
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
