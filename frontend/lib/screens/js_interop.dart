// lib/js_interop.dart
library js_interop;

import 'package:js/js_util.dart' as js_util;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui';                     // ← Rect 사용을 위해 추가

/// ─── Mic Recording ───

Future<void> startMicRecording() {
  final jsPromise = js_util.callMethod(js_util.globalThis, 'startMicRecording', []);
  if (jsPromise == null) {
    throw StateError('JS function startMicRecording not found');
  }
  return js_util.promiseToFuture<void>(jsPromise);
}

Future<Uint8List> stopMicRecording() async {
  final jsPromise = js_util.callMethod(js_util.globalThis, 'stopMicRecording', []);
  if (jsPromise == null) {
    throw StateError('JS function stopMicRecording not found');
  }
  final base64Str = await js_util.promiseToFuture<String>(jsPromise);
  return base64Decode(base64Str);
}

/// ─── Eye Tracking ───

Future<void> startEyeTracking() {
  final jsPromise = js_util.callMethod(js_util.globalThis, 'startEyeTracking', []);
  if (jsPromise == null) {
    throw StateError('JS function startEyeTracking not found');
  }
  return js_util.promiseToFuture<void>(jsPromise);
}

Future<List<Map<String, dynamic>>> stopEyeTracking() async {
  final jsPromise = js_util.callMethod(js_util.globalThis, 'stopEyeTracking', []);
  if (jsPromise == null) {
    throw StateError('JS function stopEyeTracking not found');
  }
  final raw = await js_util.promiseToFuture<List<dynamic>>(jsPromise);
  return raw.map((item) => {
        'x': js_util.getProperty(item, 'x') as double?,
        'y': js_util.getProperty(item, 'y') as double?,
        't': (js_util.getProperty(item, 't') as num?)?.toInt(),
      }).toList();
}

/// ① HTML側 collectWordBoxes() 호출해서
///    `.word` span들의 박스를 JS 전역(window._wordBoxes)에 저장
void collectWordBoxes() {
  js_util.callMethod(js_util.globalThis, 'collectWordBoxes', <Object>[]);
}

/// ② 저장된 박스 배열을 가져와 List<Rect>로 반환
Future<List<Rect>> getWordBoxes() async {
  // JS global getWordBoxes() 호출
  final raw = js_util.callMethod(js_util.globalThis, 'getWordBoxes', <Object>[]);
  final list = (raw as List).cast<dynamic>();
  return list.map((item) {
    final left   = js_util.getProperty(item, 'left')   as num;
    final top    = js_util.getProperty(item, 'top')    as num;
    final right  = js_util.getProperty(item, 'right')  as num;
    final bottom = js_util.getProperty(item, 'bottom') as num;
    return Rect.fromLTRB(
      left.toDouble(), top.toDouble(),
      right.toDouble(), bottom.toDouble(),
    );
  }).toList();
}