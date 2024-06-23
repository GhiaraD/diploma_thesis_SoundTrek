import 'package:SoundTrek/services/AuthenticationService.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../resources/colors.dart' as my_colors;

class InfoView extends StatefulWidget {
  const InfoView({super.key});

  @override
  State<InfoView> createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {
  final AuthenticationService apiService = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: my_colors.Colors.greyBackground,
      appBar: AppBar(
        title: const Text('Info', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: my_colors.Colors.greyBackground,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: my_colors.Colors.greyBackground,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: my_colors.Colors.greyBackground,
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: ListTile(
                title: const Text(
                  'Understanding Noise Pollution',
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text:
                            'Noise pollution, or environmental noise, refers to harmful levels of noise in the environment from sources like traffic, industry, and social events. It affects both urban and rural areas, often underestimated because it\'s not visible. However, noise pollution significantly impacts the quality of life, leading to various health and environmental issues. For more information, visit the ',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      TextSpan(
                        text: 'World Health Organization.',
                        style: const TextStyle(color: Colors.blue, fontSize: 16),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrlString('https://www.who.int/health-topics/environmental-health#tab=tab_1');
                          },
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  // Handle security and privacy tap
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: ListTile(
                title: const Text(
                  'Health Impacts of Noise Pollution',
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text:
                            'Prolonged exposure to high noise levels can cause severe health problems, including hearing loss, cardiovascular issues like hypertension, and increased stress. It disrupts sleep, leading to sleep deprivation and related health problems such as weakened immunity and cognitive impairment. Noise pollution can also cause psychological stress, anxiety, and depression, significantly affecting mental health. For detailed studies, see the ',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      TextSpan(
                        text: 'National Institute on Deafness and Other Communication Disorders.',
                        style: const TextStyle(color: Colors.blue, fontSize: 16),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrlString('https://www.nidcd.nih.gov/health/noise-induced-hearing-loss');
                          },
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  // Handle security and privacy tap
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: ListTile(
                title: const Text(
                  'Noise Pollution and Urban Living',
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text:
                            'In urban areas, noise pollution is a significant issue due to traffic, construction, nightlife, and dense populations. It can reduce property values and lower the quality of life for residents. Urban planners and policymakers are addressing this by creating quiet zones, implementing noise barriers, and promoting quieter technologies. The ',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      TextSpan(
                        text: 'Environmental Protection Agency',
                        style: const TextStyle(color: Colors.blue, fontSize: 16),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrlString(
                                'https://www.epa.gov/clean-air-act-overview/clean-air-act-title-iv-noise-pollution');
                          },
                      ),
                      const TextSpan(
                        text: " outlines various strategies to manage urban noise pollution.",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  // Handle security and privacy tap
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: ListTile(
                title: const Text(
                  'Mitigation and Prevention Strategies',
                  style: TextStyle(fontSize: 20),
                ),
                subtitle: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text:
                            "Mitigating noise pollution involves technological and regulatory measures. Technological solutions include quieter machinery, improved urban planning, and soundproof materials. Regulatory approaches involve setting noise level standards and enforcing noise control laws. Personal measures like using earplugs and advocating for local noise control policies are also essential. The ",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      TextSpan(
                        text: 'The Centers for Disease Control and Prevention',
                        style: const TextStyle(color: Colors.blue, fontSize: 16),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrlString('https://www.who.int/health-topics/environmental-health#tab=tab_1');
                          },
                      ),
                      const TextSpan(
                        text: " offers guidelines on protecting yourself from noise pollution.",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  // Handle security and privacy tap
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
