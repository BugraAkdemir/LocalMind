import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../app/theme/app_colors.dart';

class ChatInput extends ConsumerStatefulWidget {
  final Function(String text, String? imagePath) onSend;
  final VoidCallback? onStop;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.onSend,
    this.onStop,
    this.isLoading = false,
  });

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _attachedImagePath;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // If text changes from empty to not empty or vice versa, trigger rebuild to update button state
    if (_controller.text.length <= 1) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<bool> _initSpeech() async {
    try {
      _speechEnabled = await _speech.initialize(
        onError: (val) => debugPrint('Speech Error: ${val.errorMsg}'),
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
      );
      return _speechEnabled;
    } catch (e) {
      debugPrint('Speech Init Error: $e');
      return false;
    }
  }

  void _listen() async {
    if (!_isListening) {
      // Check microphone permission
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        if (!_speechEnabled) {
          await _initSpeech();
        }
        
        if (_speechEnabled) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) => setState(() {
              _controller.text = val.recognizedWords;
              // Keep cursor at the end
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            }),
            listenOptions: stt.SpeechListenOptions(cancelOnError: true),
          );
        } else {
          // Re-initialize if previously failed
             _speechEnabled = await _speech.initialize();
             if (_speechEnabled) {
                _listen();
             }
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Microphone permission is required for voice input.')),
           );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _handleSend() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
    
    final text = _controller.text.trim();
    if (text.isEmpty && _attachedImagePath == null) return;
    
    widget.onSend(text, _attachedImagePath);
    _controller.clear();
    setState(() {
      _attachedImagePath = null;
    });
    // Let focus remain so user can keep typing
  }

  final ImagePicker _picker = ImagePicker();

  void _handleAttach() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.textPrimary),
                title: const Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() => _attachedImagePath = photo.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.textPrimary),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() => _attachedImagePath = image.path);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasInput = _controller.text.trim().isNotEmpty || _attachedImagePath != null;

    return Container(
      padding: EdgeInsets.only(
        left: 16, 
        right: 16, 
        top: 12, 
        bottom: MediaQuery.of(context).padding.bottom + 12
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_attachedImagePath != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(_attachedImagePath!), fit: BoxFit.cover, width: 80, height: 80),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: InkWell(
                      onTap: () => setState(() => _attachedImagePath = null),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
            
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: widget.isLoading ? null : _handleAttach,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: _isListening ? 'Listening...' : 'Message LocalLM...',
                      hintStyle: TextStyle(
                        color: _isListening ? AppColors.accent : AppColors.textMuted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: AppColors.inputSurface,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!hasInput && !widget.isLoading) ...[
                // Microphone Button
                Container(
                  decoration: BoxDecoration(
                    color: _isListening ? AppColors.accent.withValues(alpha: 0.2) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _listen,
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none, 
                      color: _isListening ? AppColors.accent : AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                decoration: BoxDecoration(
                  color: hasInput || widget.isLoading ? AppColors.accent : AppColors.cardSurface,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: widget.isLoading ? widget.onStop : (hasInput ? _handleSend : null),
                  icon: widget.isLoading 
                      ? const Icon(Icons.stop_circle, color: AppColors.surface)
                      : Icon(
                          Icons.arrow_upward, 
                          color: hasInput ? AppColors.surface : AppColors.textMuted,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
