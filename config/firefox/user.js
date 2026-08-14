// Hardware Video Decoding (VAAPI)
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("widget.dmabuf.force-enabled", true);
// CometLake has no AV1 hw decode — software dav1d at 1080p saturates all 4 cores.
user_pref("media.av1.enabled", false);

// GPU Compositing
user_pref("gfx.webrender.all", true);
user_pref("layers.gpu-process.enabled", true);
// Compositor causes memory leaks on Intel iGPUs — disable entirely, not just force-enabled.
user_pref("gfx.webrender.compositor", false);
user_pref("gfx.webrender.compositor.force-enabled", false);

// Memory & Process Management
user_pref("browser.tabs.unloadOnLowMemory", true);
user_pref("browser.low_commit_space_threshold_mb", 4096);

// WebRTC Camera Performance
// CometLake VP9 hw decode in WebRTC froze on older Firefox (bug 1680313). Re-enabled on Firefox 153+.
user_pref("media.navigator.mediadatadecoder_vpx_enabled", true);
// AV1 in WebRTC is separate from media.av1.enabled — disable to prevent software decode in Meet.
user_pref("media.peerconnection.video.av1_enabled", false);
user_pref("media.webrtc.camera.allow-pipewire", true);

// WebRTC Audio Processing (Firefox 151+ pref names)
// AEC on — cancels echo between output→mic on USB audio where clocks drift independently.
// expect_drift — tells AEC3 the input/output clocks are unsynchronized (USB has separate clocks).
// AGC/noise/HPF off — Meet handles gain, noise gate, and high-pass itself; doubling causes pumping.
user_pref("media.getusermedia.audio.processing.aec.enabled", true);
user_pref("media.getusermedia.audio.processing.aec.expect_drift", true);
user_pref("media.getusermedia.audio.processing.agc.enabled", false);
user_pref("media.getusermedia.audio.processing.noise.enabled", false);
user_pref("media.getusermedia.audio.processing.hpf.enabled", false);
