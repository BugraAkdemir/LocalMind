import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import '../../../../app/theme/app_colors.dart';
import 'package:mobile_locallm/core/localization/app_i18n.dart';

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
        onError: (val) {
          debugPrint('Speech Error: ${val.errorMsg}');
          if (mounted) {
            setState(() => _isListening = false);
          }
        },
        onStatus: (val) {
          debugPrint('Speech Status: $val');
          if (val == 'done' || val == 'notListening') {
            if (mounted) {
              setState(() => _isListening = false);
            }
          }
        },
      );
      return _speechEnabled;
    } catch (e) {
      debugPrint('Speech Init Error: $e');
      _speechEnabled = false;
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
          try {
            await _speech.listen(
              onResult: (val) {
                if (mounted) {
                  setState(() {
                    _controller.text = val.recognizedWords;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                  });
                }
              },
              listenOptions: stt.SpeechListenOptions(
                cancelOnError: true,
                partialResults: true,
              ),
            );
          } catch (e) {
            debugPrint('Speech Listen Error: $e');
            if (mounted) {
              setState(() => _isListening = false);
            }
          }
        } else {
          // Re-initialize if previously failed
          _speechEnabled = await _initSpeech();
          if (_speechEnabled) {
            _listen();
          }
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppI18n.of(context).microphonePermissionRequired)),
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
        final l10n = AppI18n.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.textPrimary),
                title: Text(l10n.takePhoto),
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
                title: Text(l10n.chooseFromGallery),
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
    final l10n = AppI18n.of(context);
    final hasInput = _controller.text.trim().isNotEmpty || _attachedImagePath != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_attachedImagePath != null)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_attachedImagePath!),
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.imageAttached,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _attachedImagePath = null),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.30),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: widget.isLoading ? null : _handleAttach,
                        icon: const Icon(Icons.add_rounded),
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 140),
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText:
                                  _isListening ? l10n.listening : l10n.messageHint,
                              hintStyle: TextStyle(
                                color:
                                    _isListening ? AppColors.accentLight : AppColors.textMuted,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (_) {
                              if (!widget.isLoading) _handleSend();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (!hasInput && !widget.isLoading)
                        IconButton(
                          onPressed: _listen,
                          icon: Icon(
                            _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          ),
                          color: _isListening ? AppColors.accentLight : AppColors.textSecondary,
                        ),
                      const SizedBox(width: 2),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (hasInput || widget.isLoading)
                              ? AppColors.accent
                              : AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          onPressed: widget.isLoading
                              ? widget.onStop
                              : (hasInput ? _handleSend : null),
                          icon: widget.isLoading
                              ? const Icon(Icons.stop_rounded, size: 20)
                              : const Icon(Icons.arrow_upward_rounded, size: 20),
                          color: (hasInput || widget.isLoading)
                              ? AppColors.surface
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
