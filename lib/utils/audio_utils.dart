import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:salas_beats/utils/exceptions.dart';
import 'package:salas_beats/utils/permissions.dart';

enum AudioFormat {
  mp3,
  wav,
  aac,
  m4a,
  ogg,
  flac,
}

enum AudioQuality {
  low(64),
  medium(128),
  high(192),
  veryHigh(256),
  lossless(320);
  
  const AudioQuality(this.bitrate);
  final int bitrate;
}

enum PlaybackState {
  stopped,
  playing,
  paused,
  buffering,
  error,
}

enum RecordingState {
  idle,
  recording,
  paused,
  stopped,
}

class AudioMetadata {
  
  const AudioMetadata({
    this.title,
    this.artist,
    this.album,
    this.genre,
    this.duration,
    this.bitrate,
    this.sampleRate,
    this.channels,
    this.format,
    this.fileSize,
    this.dateCreated,
    this.artwork,
    this.additionalData,
  });
  final String? title;
  final String? artist;
  final String? album;
  final String? genre;
  final Duration? duration;
  final int? bitrate;
  final int? sampleRate;
  final int? channels;
  final AudioFormat? format;
  final int? fileSize;
  final DateTime? dateCreated;
  final String? artwork;
  final Map<String, dynamic>? additionalData;
  
  String get displayTitle => title ?? 'Unknown Title';
  String get displayArtist => artist ?? 'Unknown Artist';
  String get displayAlbum => album ?? 'Unknown Album';
  
  @override
  String toString() => 'AudioMetadata(title: $title, artist: $artist, duration: $duration)';
}

class AudioPlayerManager {
  
  AudioPlayerManager._();
  static AudioPlayerManager? _instance;
  static AudioPlayerManager get instance => _instance ??= AudioPlayerManager._();
  
  final AudioPlayer _player = AudioPlayer();
  final StreamController<PlaybackState> _stateController = 
      StreamController<PlaybackState>.broadcast();
  final StreamController<Duration> _positionController = 
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController = 
      StreamController<Duration>.broadcast();
  final StreamController<double> _volumeController = 
      StreamController<double>.broadcast();
  
  PlaybackState _currentState = PlaybackState.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _currentDuration = Duration.zero;
  double _currentVolume = 1;
  String? _currentSource;
  AudioMetadata? _currentMetadata;
  
  // Getters
  Stream<PlaybackState> get stateStream => _stateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<double> get volumeStream => _volumeController.stream;
  
  PlaybackState get state => _currentState;
  Duration get position => _currentPosition;
  Duration get duration => _currentDuration;
  double get volume => _currentVolume;
  String? get currentSource => _currentSource;
  AudioMetadata? get currentMetadata => _currentMetadata;
  
  bool get isPlaying => _currentState == PlaybackState.playing;
  bool get isPaused => _currentState == PlaybackState.paused;
  bool get isStopped => _currentState == PlaybackState.stopped;
  bool get isBuffering => _currentState == PlaybackState.buffering;
  
  // Initialize player
  Future<void> initialize() async {
    try {
      // Listen to player state changes
      _player.onPlayerStateChanged.listen((state) {
        switch (state) {
          case PlayerState.playing:
            _updateState(PlaybackState.playing);
            break;
          case PlayerState.paused:
            _updateState(PlaybackState.paused);
            break;
          case PlayerState.stopped:
            _updateState(PlaybackState.stopped);
            break;
          case PlayerState.completed:
            _updateState(PlaybackState.stopped);
            break;
          default:
            _updateState(PlaybackState.stopped);
            break;
        }
      });
      
      // Listen to position changes
      _player.onPositionChanged.listen((position) {
        _currentPosition = position;
        _positionController.add(position);
      });
      
      // Listen to duration changes
      _player.onDurationChanged.listen((duration) {
        _currentDuration = duration;
        _durationController.add(duration);
      });
      
      debugPrint('AudioPlayerManager initialized');
    } catch (e) {
      debugPrint('Error initializing AudioPlayerManager: $e');
      throw AudioException.initializationError('Failed to initialize audio player');
    }
  }
  
  // Update playback state
  void _updateState(PlaybackState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _stateController.add(newState);
    }
  }
  
  // Play audio from file
  Future<void> playFile(File audioFile) async {
    try {
      _updateState(PlaybackState.buffering);
      _currentSource = audioFile.path;
      
      await _player.play(DeviceFileSource(audioFile.path));
      
      // Get metadata
      _currentMetadata = await AudioUtils.getAudioMetadata(audioFile);
    } catch (e) {
      _updateState(PlaybackState.error);
      throw AudioException.playbackError('Failed to play audio file: $e');
    }
  }
  
  // Play audio from URL
  Future<void> playUrl(String url) async {
    try {
      _updateState(PlaybackState.buffering);
      _currentSource = url;
      
      await _player.play(UrlSource(url));
    } catch (e) {
      _updateState(PlaybackState.error);
      throw AudioException.playbackError('Failed to play audio URL: $e');
    }
  }
  
  // Play audio from assets
  Future<void> playAsset(String assetPath) async {
    try {
      _updateState(PlaybackState.buffering);
      _currentSource = assetPath;
      
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      _updateState(PlaybackState.error);
      throw AudioException.playbackError('Failed to play audio asset: $e');
    }
  }
  
  // Pause playback
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      throw AudioException.playbackError('Failed to pause: $e');
    }
  }
  
  // Resume playback
  Future<void> resume() async {
    try {
      await _player.resume();
    } catch (e) {
      throw AudioException.playbackError('Failed to resume: $e');
    }
  }
  
  // Stop playback
  Future<void> stop() async {
    try {
      await _player.stop();
      _currentSource = null;
      _currentMetadata = null;
      _currentPosition = Duration.zero;
      _currentDuration = Duration.zero;
    } catch (e) {
      throw AudioException.playbackError('Failed to stop: $e');
    }
  }
  
  // Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      throw AudioException.playbackError('Failed to seek: $e');
    }
  }
  
  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _player.setVolume(clampedVolume);
      _currentVolume = clampedVolume;
      _volumeController.add(clampedVolume);
    } catch (e) {
      throw AudioException.playbackError('Failed to set volume: $e');
    }
  }
  
  // Set playback rate
  Future<void> setPlaybackRate(double rate) async {
    try {
      await _player.setPlaybackRate(rate);
    } catch (e) {
      throw AudioException.playbackError('Failed to set playback rate: $e');
    }
  }
  
  // Dispose player
  void dispose() {
    _player.dispose();
    _stateController.close();
    _positionController.close();
    _durationController.close();
    _volumeController.close();
  }
}

class AudioRecorderManager {
  
  AudioRecorderManager._();
  static AudioRecorderManager? _instance;
  static AudioRecorderManager get instance => _instance ??= AudioRecorderManager._();
  
  final AudioRecorder _recorder = AudioRecorder();
  final StreamController<RecordingState> _stateController = 
      StreamController<RecordingState>.broadcast();
  final StreamController<Duration> _durationController = 
      StreamController<Duration>.broadcast();
  final StreamController<double> _amplitudeController = 
      StreamController<double>.broadcast();
  
  RecordingState _currentState = RecordingState.idle;
  Duration _recordingDuration = Duration.zero;
  Timer? _durationTimer;
  String? _currentRecordingPath;
  
  // Getters
  Stream<RecordingState> get stateStream => _stateController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<double> get amplitudeStream => _amplitudeController.stream;
  
  RecordingState get state => _currentState;
  Duration get recordingDuration => _recordingDuration;
  String? get currentRecordingPath => _currentRecordingPath;
  
  bool get isRecording => _currentState == RecordingState.recording;
  bool get isPaused => _currentState == RecordingState.paused;
  bool get isIdle => _currentState == RecordingState.idle;
  
  // Initialize recorder
  Future<void> initialize() async {
    try {
      // Check microphone permission
      final micPermission = await PermissionManager.requestPermission(
        PermissionType.microphone,
      );
      if (!micPermission.isGranted) {
        throw AudioException.permissionDenied('Microphone permission required');
      }
      
      debugPrint('AudioRecorderManager initialized');
    } catch (e) {
      debugPrint('Error initializing AudioRecorderManager: $e');
      throw AudioException.initializationError('Failed to initialize audio recorder');
    }
  }
  
  // Update recording state
  void _updateState(RecordingState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _stateController.add(newState);
    }
  }
  
  // Start recording
  Future<String> startRecording({
    AudioFormat format = AudioFormat.m4a,
    AudioQuality quality = AudioQuality.medium,
    String? fileName,
  }) async {
    try {
      if (isRecording) {
        throw AudioException.recordingError('Already recording');
      }
      
      // Check if recorder has permission
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw AudioException.permissionDenied('Microphone permission required');
      }
      
      // Generate file path
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final name = fileName ?? 'recording_$timestamp';
      final filePath = path.join(tempDir.path, '$name.${format.name}');
      
      // Configure recording
      final config = RecordConfig(
        encoder: _getEncoder(format),
        bitRate: quality.bitrate * 1000, // Convert to bps
      );
      
      // Start recording
      await _recorder.start(config, path: filePath);
      
      _currentRecordingPath = filePath;
      _recordingDuration = Duration.zero;
      _updateState(RecordingState.recording);
      
      // Start duration timer
      _startDurationTimer();
      
      // Start amplitude monitoring
      _startAmplitudeMonitoring();
      
      return filePath;
    } catch (e) {
      _updateState(RecordingState.idle);
      if (e is AudioException) rethrow;
      throw AudioException.recordingError('Failed to start recording: $e');
    }
  }
  
  // Get encoder for format
  AudioEncoder _getEncoder(AudioFormat format) {
    switch (format) {
      case AudioFormat.aac:
        return AudioEncoder.aacLc;
      case AudioFormat.wav:
        return AudioEncoder.wav;
      case AudioFormat.m4a:
        return AudioEncoder.aacLc;
      case AudioFormat.ogg:
        return AudioEncoder.opus;
      default:
        return AudioEncoder.aacLc;
    }
  }
  
  // Pause recording
  Future<void> pauseRecording() async {
    try {
      if (!isRecording) {
        throw AudioException.recordingError('Not currently recording');
      }
      
      await _recorder.pause();
      _updateState(RecordingState.paused);
      _stopDurationTimer();
    } catch (e) {
      if (e is AudioException) rethrow;
      throw AudioException.recordingError('Failed to pause recording: $e');
    }
  }
  
  // Resume recording
  Future<void> resumeRecording() async {
    try {
      if (!isPaused) {
        throw AudioException.recordingError('Recording is not paused');
      }
      
      await _recorder.resume();
      _updateState(RecordingState.recording);
      _startDurationTimer();
    } catch (e) {
      if (e is AudioException) rethrow;
      throw AudioException.recordingError('Failed to resume recording: $e');
    }
  }
  
  // Stop recording
  Future<String?> stopRecording() async {
    try {
      if (isIdle) {
        throw AudioException.recordingError('Not currently recording');
      }
      
      final filePath = await _recorder.stop();
      
      _updateState(RecordingState.stopped);
      _stopDurationTimer();
      _stopAmplitudeMonitoring();
      
      final recordingPath = _currentRecordingPath;
      _currentRecordingPath = null;
      _recordingDuration = Duration.zero;
      
      return filePath ?? recordingPath;
    } catch (e) {
      _updateState(RecordingState.idle);
      if (e is AudioException) rethrow;
      throw AudioException.recordingError('Failed to stop recording: $e');
    }
  }
  
  // Start duration timer
  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _recordingDuration = Duration(milliseconds: timer.tick * 100);
      _durationController.add(_recordingDuration);
    });
  }
  
  // Stop duration timer
  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }
  
  // Start amplitude monitoring
  void _startAmplitudeMonitoring() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!isRecording) {
        timer.cancel();
        return;
      }
      
      _recorder.getAmplitude().then((amplitude) {
        _amplitudeController.add(amplitude.current);
      }).catchError((e) {
        // Ignore amplitude errors
      });
    });
  }
  
  // Stop amplitude monitoring
  void _stopAmplitudeMonitoring() {
    // Amplitude monitoring is stopped automatically when recording stops
  }
  
  // Dispose recorder
  void dispose() {
    _recorder.dispose();
    _stateController.close();
    _durationController.close();
    _amplitudeController.close();
    _stopDurationTimer();
  }
}

class AudioUtils {
  // Get audio metadata
  static Future<AudioMetadata> getAudioMetadata(File audioFile) async {
    try {
      final stat = await audioFile.stat();
      final fileName = path.basename(audioFile.path);
      final extension = path.extension(audioFile.path).toLowerCase();
      
      AudioFormat? format;
      switch (extension) {
        case '.mp3':
          format = AudioFormat.mp3;
          break;
        case '.wav':
          format = AudioFormat.wav;
          break;
        case '.aac':
          format = AudioFormat.aac;
          break;
        case '.m4a':
          format = AudioFormat.m4a;
          break;
        case '.ogg':
          format = AudioFormat.ogg;
          break;
        case '.flac':
          format = AudioFormat.flac;
          break;
      }
      
      // This is a simplified implementation
      // In practice, you'd use a proper audio metadata library
      return AudioMetadata(
        title: path.basenameWithoutExtension(fileName),
        format: format,
        fileSize: stat.size,
        dateCreated: stat.changed,
      );
    } catch (e) {
      throw AudioException.metadataError('Failed to get audio metadata: $e');
    }
  }
  
  // Convert audio format
  static Future<File> convertAudioFormat(
    File inputFile,
    AudioFormat targetFormat, {
    AudioQuality quality = AudioQuality.medium,
  }) async {
    try {
      // This would require a proper audio conversion library
      // For now, just copy the file with new extension
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(inputFile.path);
      final outputPath = path.join(tempDir.path, '$fileName.${targetFormat.name}');
      
      await inputFile.copy(outputPath);
      
      return File(outputPath);
    } catch (e) {
      throw AudioException.conversionError('Failed to convert audio format: $e');
    }
  }
  
  // Compress audio
  static Future<File> compressAudio(
    File inputFile, {
    AudioQuality quality = AudioQuality.medium,
  }) async {
    try {
      // This would require a proper audio compression library
      // For now, just return the original file
      return inputFile;
    } catch (e) {
      throw AudioException.compressionError('Failed to compress audio: $e');
    }
  }
  
  // Trim audio
  static Future<File> trimAudio(
    File inputFile,
    Duration startTime,
    Duration endTime,
  ) async {
    try {
      // This would require a proper audio editing library
      // For now, just return the original file
      return inputFile;
    } catch (e) {
      throw AudioException.editingError('Failed to trim audio: $e');
    }
  }
  
  // Merge audio files
  static Future<File> mergeAudioFiles(
    List<File> audioFiles, {
    AudioFormat outputFormat = AudioFormat.m4a,
  }) async {
    try {
      if (audioFiles.isEmpty) {
        throw AudioException.editingError('No audio files to merge');
      }
      
      // This would require a proper audio editing library
      // For now, just return the first file
      return audioFiles.first;
    } catch (e) {
      throw AudioException.editingError('Failed to merge audio files: $e');
    }
  }
  
  // Extract audio from video
  static Future<File> extractAudioFromVideo(
    File videoFile, {
    AudioFormat format = AudioFormat.m4a,
    AudioQuality quality = AudioQuality.medium,
  }) async {
    try {
      // This would require a video processing library
      // For now, throw an error
      throw AudioException.conversionError('Audio extraction not implemented');
    } catch (e) {
      throw AudioException.conversionError('Failed to extract audio: $e');
    }
  }
  
  // Generate waveform data
  static Future<List<double>> generateWaveform(
    File audioFile, {
    int samples = 100,
  }) async {
    try {
      // This would require audio analysis libraries
      // For now, generate mock waveform data
      final waveform = <double>[];
      for (var i = 0; i < samples; i++) {
        waveform.add((i % 10) / 10.0);
      }
      return waveform;
    } catch (e) {
      throw AudioException.analysisError('Failed to generate waveform: $e');
    }
  }
  
  // Analyze audio spectrum
  static Future<Map<String, dynamic>> analyzeAudioSpectrum(
    File audioFile,
  ) async {
    try {
      // This would require audio analysis libraries
      // For now, return mock data
      return {
        'frequencies': List.generate(20, (i) => i * 1000.0),
        'amplitudes': List.generate(20, (i) => (i % 5) / 5.0),
        'dominantFrequency': 440.0,
        'averageAmplitude': 0.5,
      };
    } catch (e) {
      throw AudioException.analysisError('Failed to analyze audio spectrum: $e');
    }
  }
  
  // Detect silence in audio
  static Future<List<Duration>> detectSilence(
    File audioFile, {
    double threshold = 0.01,
    Duration minDuration = const Duration(seconds: 1),
  }) async {
    try {
      // This would require audio analysis libraries
      // For now, return empty list
      return [];
    } catch (e) {
      throw AudioException.analysisError('Failed to detect silence: $e');
    }
  }
  
  // Check if file is valid audio
  static Future<bool> isValidAudio(File file) async {
    try {
      final extension = path.extension(file.path).toLowerCase();
      const validExtensions = ['.mp3', '.wav', '.aac', '.m4a', '.ogg', '.flac'];
      return validExtensions.contains(extension);
    } catch (e) {
      return false;
    }
  }
  
  // Get audio duration
  static Future<Duration?> getAudioDuration(File audioFile) async {
    try {
      // This would require an audio metadata library
      // For now, return null
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Calculate audio file hash
  static String generateAudioHash(File audioFile) {
    final fileName = path.basename(audioFile.path);
    final fileSize = audioFile.lengthSync();
    return '${fileName}_$fileSize'.hashCode.toString();
  }
}

// Audio exceptions
class AudioException extends AppException {
  const AudioException(super.message, {super.code});
  
  factory AudioException.initializationError([String? message]) => AudioException(
      message ?? 'Failed to initialize audio system',
      code: 'AUDIO_INIT_ERROR',
    );
  
  factory AudioException.playbackError([String? message]) => AudioException(
      message ?? 'Audio playback error',
      code: 'AUDIO_PLAYBACK_ERROR',
    );
  
  factory AudioException.recordingError([String? message]) => AudioException(
      message ?? 'Audio recording error',
      code: 'AUDIO_RECORDING_ERROR',
    );
  
  factory AudioException.permissionDenied([String? message]) => AudioException(
      message ?? 'Audio permission denied',
      code: 'AUDIO_PERMISSION_DENIED',
    );
  
  factory AudioException.metadataError([String? message]) => AudioException(
      message ?? 'Failed to read audio metadata',
      code: 'AUDIO_METADATA_ERROR',
    );
  
  factory AudioException.conversionError([String? message]) => AudioException(
      message ?? 'Audio conversion error',
      code: 'AUDIO_CONVERSION_ERROR',
    );
  
  factory AudioException.compressionError([String? message]) => AudioException(
      message ?? 'Audio compression error',
      code: 'AUDIO_COMPRESSION_ERROR',
    );
  
  factory AudioException.editingError([String? message]) => AudioException(
      message ?? 'Audio editing error',
      code: 'AUDIO_EDITING_ERROR',
    );
  
  factory AudioException.analysisError([String? message]) => AudioException(
      message ?? 'Audio analysis error',
      code: 'AUDIO_ANALYSIS_ERROR',
    );
}

// Audio file extensions
extension AudioFileExtension on File {
  Future<AudioMetadata> getMetadata() => AudioUtils.getAudioMetadata(this);
  
  Future<File> convertFormat(
    AudioFormat format, {
    AudioQuality quality = AudioQuality.medium,
  }) => AudioUtils.convertAudioFormat(this, format, quality: quality);
  
  Future<File> compress({
    AudioQuality quality = AudioQuality.medium,
  }) => AudioUtils.compressAudio(this, quality: quality);
  
  Future<File> trim(Duration startTime, Duration endTime) =>
      AudioUtils.trimAudio(this, startTime, endTime);
  
  Future<bool> get isValidAudio => AudioUtils.isValidAudio(this);
  
  String get audioHash => AudioUtils.generateAudioHash(this);
  
  Future<Duration?> get duration => AudioUtils.getAudioDuration(this);
  
  Future<List<double>> generateWaveform({int samples = 100}) =>
      AudioUtils.generateWaveform(this, samples: samples);
  
  Future<Map<String, dynamic>> analyzeSpectrum() =>
      AudioUtils.analyzeAudioSpectrum(this);
}