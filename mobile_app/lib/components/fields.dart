import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:uinlp_annotate/features/annotate_task/screens/annotate_editor_screen.dart';
import 'package:uinlp_annotate/models/annotate_task.dart';

class AnnotateTextField extends StatefulWidget {
  const AnnotateTextField({
    super.key,
    required this.field,
    required this.theme,
  });

  final AnnotateFieldStateModel field;
  final ThemeData theme;

  @override
  State<AnnotateTextField> createState() => _AnnotateTextFieldState();
}

class _AnnotateTextFieldState extends State<AnnotateTextField> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.field.value.value);
    widget.field.value.addListener(() {
      setState(() {
        controller.text = widget.field.value.value ?? "";
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onSaved: (value) {
        if (value != null && value.isNotEmpty) {
          widget.field.value.value = value;
        } else {
          widget.field.value.value = null;
        }
      },
      decoration: InputDecoration(
        labelText: widget.field.name.toTitleCase(),
        hintText: widget.field.description,
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, child) {
            return Icon(
              Icons.check_circle,
              color: widget.field.value.value == value.text
                  ? widget.theme.colorScheme.primary
                  : value.text.isNotEmpty
                  ? Colors.orange
                  : widget.theme.colorScheme.outline,
            );
          },
        ),
      ),
    );
  }
}

class AnnotateAudioField extends StatefulWidget {
  const AnnotateAudioField({super.key, required this.field});

  final AnnotateFieldStateModel field;

  @override
  State<AnnotateAudioField> createState() => _AnnotateAudioFieldState();
}

class _AnnotateAudioFieldState extends State<AnnotateAudioField> {
  late AudioRecorder _audioRecorder;
  late AudioPlayer _audioPlayer;
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isPlaying = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
    
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    widget.field.value.addListener(_onFieldValueChanged);
  }

  void _onFieldValueChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    widget.field.value.removeListener(_onFieldValueChanged);
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        _recordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        const config = RecordConfig();
        await _audioRecorder.start(config, path: _recordingPath!);
        
        setState(() {
          _isRecording = true;
          _isPaused = false;
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (path != null) {
        final file = File(path);
        final bytes = await file.readAsBytes();
        widget.field.value.value = bytes;
      }
      setState(() {
        _isRecording = false;
        _isPaused = false;
      });
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _pauseRecording() async {
    await _audioRecorder.pause();
    setState(() {
      _isPaused = true;
    });
  }

  Future<void> _resumeRecording() async {
    await _audioRecorder.resume();
    setState(() {
      _isPaused = false;
    });
  }

  Future<void> _playRecording() async {
    try {
      if (widget.field.value.value != null) {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          // If we have bytes, we might need to save to a temp file to play with audioplayers 
          // or use Source.fromBytes if supported (older versions might not have it or it might be buggy)
          // audioplayers 6.1.0 ByteSource
          await _audioPlayer.play(BytesSource(widget.field.value.value as Uint8List));
        }
      } else if (_recordingPath != null) {
         await _audioPlayer.play(DeviceFileSource(_recordingPath!));
      }
    } catch (e) {
      debugPrint('Error playing recording: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.field.value.value != null 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mic, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                widget.field.name.toTitleCase(),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (widget.field.value.value != null)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.field.description, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!_isRecording)
                IconButton.filled(
                  onPressed: _startRecording,
                  icon: const Icon(Icons.fiber_manual_record),
                  style: IconButton.styleFrom(backgroundColor: Colors.red),
                  tooltip: 'Record',
                )
              else ...[
                IconButton.filledTonal(
                  onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                  icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                  tooltip: _isPaused ? 'Resume' : 'Pause',
                ),
                IconButton.filled(
                  onPressed: _stopRecording,
                  icon: const Icon(Icons.stop),
                  style: IconButton.styleFrom(backgroundColor: Colors.red),
                  tooltip: 'Stop',
                ),
              ],
              const SizedBox(width: 16),
              IconButton.outlined(
                onPressed: (widget.field.value.value != null || _recordingPath != null) ? _playRecording : null,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                tooltip: _isPlaying ? 'Pause Playback' : 'Play',
              ),
            ],
          ),
          if (_isRecording)
             Padding(
               padding: const EdgeInsets.only(top: 8.0),
               child: Center(
                 child: Text(
                   _isPaused ? 'Recording Paused' : 'Recording...',
                   style: theme.textTheme.labelSmall?.copyWith(color: Colors.red),
                 ),
               ),
             ),
        ],
      ),
    );
  }
}

class AnnotateImageField extends StatefulWidget {
  const AnnotateImageField({super.key, required this.field});

  final AnnotateFieldStateModel field;

  @override
  State<AnnotateImageField> createState() => _AnnotateImageFieldState();
}

class _AnnotateImageFieldState extends State<AnnotateImageField> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    widget.field.value.addListener(_onValueChanged);
  }

  @override
  void dispose() {
    widget.field.value.removeListener(_onValueChanged);
    super.dispose();
  }

  void _onValueChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        widget.field.value.value = bytes;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = widget.field.value.value != null && widget.field.value.value is Uint8List;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValue ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                widget.field.name.toTitleCase(),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (hasValue)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.field.description, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          if (hasValue)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  widget.field.value.value as Uint8List,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Picture'),
              ),
              TextButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('From Gallery'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnnotateVideoField extends StatefulWidget {
  const AnnotateVideoField({super.key, required this.field});

  final AnnotateFieldStateModel field;

  @override
  State<AnnotateVideoField> createState() => _AnnotateVideoFieldState();
}

class _AnnotateVideoFieldState extends State<AnnotateVideoField> {
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initController();
    widget.field.value.addListener(_onFieldValueChanged);
  }

  void _onFieldValueChanged() {
    _initController();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initController() async {
    if (widget.field.value.value != null && widget.field.value.value is Uint8List) {
      final bytes = widget.field.value.value as Uint8List;
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_video_${DateTime.now().millisecondsSinceEpoch}.mp4');
      await tempFile.writeAsBytes(bytes);

      final oldController = _controller;
      _controller = VideoPlayerController.file(tempFile);
      
      try {
        await _controller!.initialize();
        setState(() {});
      } catch (e) {
        debugPrint('Error initializing video controller: $e');
      }
      
      if (oldController != null) {
        await oldController.dispose();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    widget.field.value.removeListener(_onFieldValueChanged);
    super.dispose();
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(source: source);
      if (video != null) {
        final bytes = await video.readAsBytes();
        widget.field.value.value = bytes;
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = widget.field.value.value != null && widget.field.value.value is Uint8List;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValue ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.videocam, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                widget.field.name.toTitleCase(),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (hasValue)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 8),
          Text(widget.field.description, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          if (hasValue && _controller != null && _controller!.value.isInitialized)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_controller!),
                      VideoProgressIndicator(_controller!, allowScrubbing: true),
                      Center(
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                            });
                          },
                          icon: Icon(
                            _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 64,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (hasValue)
             const Padding(
               padding: EdgeInsets.all(16.0),
               child: Center(child: CircularProgressIndicator()),
             ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () => _pickVideo(ImageSource.camera),
                icon: const Icon(Icons.videocam),
                label: const Text('Record Video'),
              ),
              TextButton.icon(
                onPressed: () => _pickVideo(ImageSource.gallery),
                icon: const Icon(Icons.video_library),
                label: const Text('From Gallery'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
