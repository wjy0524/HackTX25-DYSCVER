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