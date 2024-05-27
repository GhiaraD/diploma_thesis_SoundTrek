import 'dart:async';

import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AudioStreamingApp extends StatefulWidget {
  const AudioStreamingApp({super.key});

  @override
  State<AudioStreamingApp> createState() => _AudioStreamingAppState();
}

class _AudioStreamingAppState extends State<AudioStreamingApp> {
  // recording
  int? sampleRate;
  bool isRecording = false;
  List<double> audio = [];

  // List<double>? latestBuffer;
  double? recordingTime;
  StreamSubscription<List<double>>? audioSubscription;

  // filter
  int? cutoffHigh = 20000; // High pass filter cutoff frequency in Hz
  int? cutoffLow = 20; // Low pass filter cutoff frequency in Hz

  /// Call-back on audio sample.
  void onAudio(List<double> buffer) async {
    audio.addAll(buffer);

    // Get the actual sampling rate, if not already known.
    sampleRate ??= await AudioStreamer().actualSampleRate;
    recordingTime = audio.length / sampleRate!;

    if (recordingTime! >= 60) {
      // send data to server
      audio = [];
    }

    // setState(() => latestBuffer = buffer);
  }

  /// Call-back on error.
  void handleError(Object error) {
    setState(() => isRecording = false);
    if (kDebugMode) {
      print(error);
    }
  }

  /// Start audio sampling.
  void start() async {
    // TODO: Check permission to use the microphone

    // Set the sampling rate - works only on Android.
    AudioStreamer().sampleRate = AudioStreamer.DEFAULT_SAMPLING_RATE;

    // Start listening to the audio stream.
    audioSubscription = AudioStreamer().audioStream.listen(onAudio, onError: handleError);

    setState(() => isRecording = true);
  }

  /// Stop audio sampling.
  void stop() async {
    audioSubscription?.cancel();
    setState(() => isRecording = false);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Container(
                margin: const EdgeInsets.all(25),
                child: Column(children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Text(isRecording ? "Mic: ON" : "Mic: OFF",
                        style: const TextStyle(fontSize: 25, color: Colors.blue)),
                  ),
                  const Text(''),
                  // Text('Max amp: ${latestBuffer?.reduce(max)}'),
                  // Text('Min amp: ${latestBuffer?.reduce(min)}'),
                  Text('${recordingTime?.toStringAsFixed(2)} seconds recorded.'),
                ])),
          ])),
          floatingActionButton: FloatingActionButton(
            backgroundColor: isRecording ? Colors.red : Colors.green,
            onPressed: isRecording ? stop : start,
            child: isRecording ? const Icon(Icons.stop) : const Icon(Icons.mic),
          ),
        ),
      );
}
