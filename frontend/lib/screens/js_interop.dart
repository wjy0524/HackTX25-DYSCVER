// lib/js_interop.dart

@JS()
library js_interop;

import 'package:js/js.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:js/js_util.dart' as js_util;

/// JS 전역 함수 호출용 외부 선언
@JS('startMicRecording')
external dynamic _startMicRecordingJS();

@JS('stopMicRecording')
external dynamic _stopMicRecordingJS();

/// JS Promise를 기다릴 수 있는 Dart Future 래퍼
Future<void> startMicRecording() {
  return js_util.promiseToFuture(_startMicRecordingJS());
}

/// 녹음 종료 후 Promise로 받은 base64를 Uint8List로 디코딩
Future<Uint8List> stopMicRecording() async {
  final b64 = await js_util.promiseToFuture<String>(_stopMicRecordingJS());
  return base64Decode(b64);
}

@JS('startEyeTracking')
external dynamic _startEyeTrackingJS();

@JS('stopEyeTracking')
external dynamic _stopEyeTrackingJS();

/// 눈동자 트래킹 시작
Future<void> startEyeTracking() {
  return js_util.promiseToFuture(_startEyeTrackingJS());
}

/// 눈동자 트래킹 중지 후 수집된 데이터 반환
/// 반환값은 List<Map<String, dynamic>> 형태:
/// [ {'x': double?, 'y': double?, 't': int}, … ]
Future<List<Map<String, dynamic>>> stopEyeTracking() async {
  // JSPromise → Dart List<dynamic>
  final raw = await js_util.promiseToFuture(_stopEyeTrackingJS());
  // 각 항목에서 x, y, t 프로퍼티를 뽑아서 Dart Map으로 변환
  return (raw as List).map((item) {
    return {
      'x': js_util.getProperty(item, 'x') as double?,
      'y': js_util.getProperty(item, 'y') as double?,
      't': (js_util.getProperty(item, 't') as num?)?.toInt(),
    };
  }).toList();
}