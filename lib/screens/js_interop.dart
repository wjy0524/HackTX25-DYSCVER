@JS()
library js_interop;

import 'package:js/js.dart';

@JS('startMicRecording')
external void startMicRecording();

@JS('stopMicRecording')
external dynamic stopMicRecording(); // Will return a JS Promise (Future)
