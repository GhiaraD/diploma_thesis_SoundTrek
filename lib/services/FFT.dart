import 'dart:math';
import 'dart:typed_data';

import 'package:fftea/fftea.dart';

List<double> applyBandpassFilter(List<double> data, double lowCutoff, double highCutoff, int samplingRate) {
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

List<double> convertToSPL2(List<double> normalizedAudio, {double maxSPL = 120.0, double calibrationOffset = -3.0}) {
  double referencePressure = 20e-6; // Reference pressure in Pascals (20 μPa)
  double pMax = referencePressure * pow(10, maxSPL / 20); // Max pressure at full scale amplitude ±1

  List<double> splValues = [];
  for (double amplitude in normalizedAudio) {
    if (amplitude.abs() > 0) {
      // Check for non-zero amplitude
      double p = pMax * amplitude; // Calculate pressure for this sample
      double spl = 20 * log(p / referencePressure) / ln10; // Calculate SPL in dB
      spl += calibrationOffset; // Aplicarea factorului de calibrare
      splValues.add(spl);
    } else {
      splValues.add(0); // Substitute zero for log of zero amplitude
    }
  }
  return splValues;
}

double calculateLAeq(List<double> splValues) {
  if (splValues.isEmpty) return double.nan;

  double sum = 0.0;
  int validCount = 0;

  for (double spl in splValues) {
    if (spl.isFinite) {
      sum += pow(10, spl / 10);
      validCount++;
    }
  }

  if (validCount == 0) return double.nan;

  double mean = sum / validCount;
  double laeq = 10 * log(mean) / ln10;
  return laeq;
}

double calculateLA50(List<double> splValues) {
  // Filter out non-finite values
  List<double> finiteValues = splValues.where((value) => value.isFinite).toList();

  // Sort the filtered values
  List<double> sortedSPL = List.from(finiteValues)..sort();

  int n = sortedSPL.length;
  if (n == 0) return double.nan; // Handle case with no valid values

  if (n % 2 == 0) {
    // Even number of values, take the average of the two middle values
    return (sortedSPL[n ~/ 2 - 1] + sortedSPL[n ~/ 2]) / 2;
  } else {
    // Odd number of values, take the middle value
    return sortedSPL[n ~/ 2];
  }
}
