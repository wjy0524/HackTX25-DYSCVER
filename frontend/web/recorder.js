// web/recorder.js

let mediaRecorder;
let chunks = [];

// 녹음 시작 (Promise를 반환하도록 수정)
async function startMicRecording() {
  const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
  mediaRecorder = new MediaRecorder(stream);
  chunks = [];
  mediaRecorder.ondataavailable = e => {
    if (e.data.size > 0) chunks.push(e.data);
  };
  mediaRecorder.start();
}

// 녹음 중지 후 base64 문자열을 resolve
function stopMicRecording() {
  return new Promise((resolve, reject) => {
    if (!mediaRecorder) {
      reject("녹음이 시작되지 않았습니다");
      return;
    }
    mediaRecorder.onstop = async () => {
      const blob = new Blob(chunks, { type: "audio/webm; codecs=opus" });
      const reader = new FileReader();
      reader.onloadend = () => {
        // dataURL 전체에서 앞부분 “data:…;base64,” 잘라내고 base64만
        const base64 = reader.result.split(",")[1];
        resolve(base64);
      };
      reader.onerror = reject;
      reader.readAsDataURL(blob);
    };
    mediaRecorder.stop();
  });
}

// Flutter에서 JS interop으로 호출할 수 있도록 전역에 노출
window.startMicRecording = startMicRecording;
window.stopMicRecording  = stopMicRecording;
