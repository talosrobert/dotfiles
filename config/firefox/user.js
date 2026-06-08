// Hardware Video Decoding (VAAPI)
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("widget.dmabuf.force-enabled", true);

// GPU Compositing
user_pref("gfx.webrender.all", true);
user_pref("layers.gpu-process.enabled", true);
// Disable forced compositor — causes memory leaks on Intel iGPUs
user_pref("gfx.webrender.compositor.force-enabled", false);

// Memory & Process Management
user_pref("dom.ipc.processCount", 4);
user_pref("browser.tabs.unloadOnLowMemory", true);
user_pref("browser.low_commit_space_threshold_mb", 4096);

// WebRTC Camera Performance
// Was true; flipped false — CometLake VP9 hw decode in WebRTC freezes (Mozilla bug 1680313).
// HTML5 video (YouTube) still uses VAAPI via media.ffmpeg.vaapi.enabled.
user_pref("media.navigator.mediadatadecoder_vpx_enabled", false);
user_pref("media.webrtc.camera.allow-pipewire", true);

// WebRTC Audio Processing (disable — Google Meet handles AEC/noise/HPF itself)
user_pref("media.getusermedia.aec_enabled", false);
user_pref("media.getusermedia.noise_enabled", false);
user_pref("media.getusermedia.audio.processing.hpf.enabled", false);
