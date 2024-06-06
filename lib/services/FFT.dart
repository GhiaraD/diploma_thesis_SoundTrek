import 'dart:math';
import 'dart:typed_data';

import 'package:fftea/fftea.dart';

List<double> applyLowPassFilter(List<double> data, double cutoffFrequency, double samplingRate) {
  int N = data.length;
  double nyquist = samplingRate / 2;
  int cutoffIndex = (cutoffFrequency / nyquist * (N / 2)).floor();

  // FFT
  var fft = FFT(N);
  var freqDomain = fft.realFft(data);

  // Zero out frequencies above the cutoff
  for (int i = cutoffIndex; i < freqDomain.length - cutoffIndex; i++) {
    freqDomain[i] = Float64x2.zero();
  }

  // IFFT
  List<double> filteredData = fft.realInverseFft(freqDomain).toList();
  return filteredData;
}

List<double> applyHighPassFilter(List<double> data, double cutoffFrequency, double samplingRate) {
  int N = data.length;
  double nyquist = samplingRate / 2;
  int cutoffIndex = (cutoffFrequency / nyquist * (N / 2)).floor();

  // FFT
  var fft = FFT(N);
  var freqDomain = fft.realFft(data);

  // Zero out frequencies below the cutoff
  for (int i = 0; i < cutoffIndex; i++) {
    freqDomain[i] = Float64x2.zero();
    freqDomain[freqDomain.length - i - 1] = Float64x2.zero();
  }

  // IFFT
  List<double> filteredData = fft.realInverseFft(freqDomain).toList();
  return filteredData;
}

List<double> applyBandpassFilter(List<double> data, double lowCutoff, double highCutoff, double samplingRate) {
  int N = data.length;

  if (lowCutoff <= 0 || highCutoff >= samplingRate / 2 || lowCutoff >= highCutoff) {
    throw ArgumentError('Invalid cutoff frequencies');
  }

  double nyquist = samplingRate / 2;
  int lowCutoffIndex = (lowCutoff / nyquist * (N / 2)).floor();
  int highCutoffIndex = (highCutoff / nyquist * (N / 2)).floor();

  List<double> windowedData = applyWindowFunction(data);

  // FFT
  var fft = FFT(N);
  var freqDomain = fft.realFft(windowedData);

  // Attenuate frequencies outside the passband
  // Zero out frequencies below the lower cutoff and above the upper cutoff
  for (int i = 0; i < N / 2; i++) {
    if (i < lowCutoffIndex || i > highCutoffIndex) {
      freqDomain[i] = Float64x2.zero(); // Zero out the positive frequencies
      freqDomain[N - i - 1] = Float64x2.zero(); // Zero out the corresponding negative frequencies
    }
  }

  // IFFT
  List<double> filteredData = fft.realInverseFft(freqDomain).toList();
  return filteredData;
}

List<double> applyWindowFunction(List<double> data) {
  int N = data.length;
  List<double> windowedData = List<double>.filled(N, 0.0);
  for (int i = 0; i < N; i++) {
    // Applying a Hamming window
    windowedData[i] = data[i] * (0.54 - 0.46 * cos(2 * pi * i / (N - 1)));
  }
  return windowedData;
}

List<double> convertToSPL(List<double> normalizedAudio, {double maxSPL = 120.0}) {
  double referencePressure = 20e-6; // Reference pressure in Pascals (20 μPa)
  double pMax = referencePressure * pow(10, maxSPL / 20); // Max pressure at full scale amplitude ±1

  List<double> splValues = [];
  for (double amplitude in normalizedAudio) {
    if (amplitude != 0) {
      double p = pMax * amplitude; // Calculate pressure for this sample
      double spl = 20 * log(p / referencePressure) / ln10; // Calculate SPL in dB
      splValues.add(spl);
    } else {
      splValues.add(-double.infinity); // Logarithm of zero amplitude gives negative infinity
    }
  }
  return splValues;
}
