import 'dart:math';

import 'package:SoundTrek/services/FFT.dart';
import 'package:flutter_test/flutter_test.dart';
// Import your functions here if they are in a separate file

void main() {
  testApplyBandpassFilter();
  testApplyWindowFunction();
  testConvertToSPL2();
  testCalculateLAeq();
  testCalculateLA50();
}

void testApplyBandpassFilter() {
  test('Bandpass filter applies correctly', () {
    List<double> data = List.generate(100, (i) => sin(2 * pi * i / 100));
    int samplingRate = 100;
    double lowCutoff = 10;
    double highCutoff = 20;

    expect(() => applyBandpassFilter(data, lowCutoff, highCutoff, samplingRate), returnsNormally);
  });

  test('Bandpass filter throws with invalid cutoff frequencies', () {
    List<double> data = List.generate(100, (i) => sin(2 * pi * i / 100));
    int samplingRate = 100;

    // Test lower edge cases
    expect(() => applyBandpassFilter(data, 0, 20, samplingRate), throwsArgumentError);
    // Test higher edge cases
    expect(() => applyBandpassFilter(data, 10, 50, samplingRate), throwsArgumentError);
    // Test invalid range
    expect(() => applyBandpassFilter(data, 30, 20, samplingRate), throwsArgumentError);
  });
}

void testApplyWindowFunction() {
  test('Window function applies a Hamming window correctly', () {
    List<double> data = List.generate(10, (i) => 1.0); // Constant array
    List<double> windowedData = applyWindowFunction(data);

    expect(windowedData, isNot(contains(1.0))); // Verify no element remains unchanged (simple case)
    expect(windowedData.first, lessThan(1.0)); // Hamming window affects start and end less than mid
    expect(windowedData.last, lessThan(1.0));
  });
}

void testConvertToSPL2() {
  test('Convert to SPL2 computes SPL values correctly', () {
    List<double> normalizedAudio = [1.0, 0.5, 0.0];
    double maxSPL = 120.0;
    double calibrationOffset = 0.0;

    List<double> splValues = convertToSPL2(normalizedAudio, maxSPL: maxSPL, calibrationOffset: calibrationOffset);

    expect(splValues.length, 3);
    expect(splValues[2], equals(0)); // Zero amplitude results in zero SPL
    expect(splValues[0], greaterThan(splValues[1])); // Higher amplitudes result in higher SPL
  });
}

void testCalculateLAeq() {
  test('Calculate LAeq computes average sound level correctly', () {
    List<double> splValues = [90.0, 90.0, 90.0];

    double laeq = calculateLAeq(splValues);
    expect(laeq, equals(90.0));
  });

  test('Calculate LAeq handles empty input', () {
    List<double> splValues = [];

    double laeq = calculateLAeq(splValues);
    expect(laeq.isNaN, isTrue);
  });
}

void testCalculateLA50() {
  test('Calculate LA50 computes median sound level correctly', () {
    List<double> splValues = [85.0, 90.0, 95.0];

    double la50 = calculateLA50(splValues);
    expect(la50, equals(90.0)); // Median value
  });

  test('Calculate LA50 handles even number of values correctly', () {
    List<double> splValues = [85.0, 90.0, 95.0, 100.0];

    double la50 = calculateLA50(splValues);
    expect(la50, equals(92.5)); // Average of two middle values
  });
}
