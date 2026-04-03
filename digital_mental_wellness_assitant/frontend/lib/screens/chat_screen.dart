import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';
import '../services/voice_service.dart';
import '../widgets/app_section_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_Message> _messages = [
    const _Message(
      text:
          "Hi, I'm your wellness companion. Tell me what's on your mind today.",
      isUser: false,
    ),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;
  bool _isListening = false;
  double _soundLevel = 0.0;
  final ApiService _api = ApiService();
  final VoiceService _voiceService = VoiceService();

  String? _buildInsightLine(Map<String, dynamic> result) {
    final emotion = (result['emotion'] ?? '').toString().trim();
    final sentiment = (result['sentiment'] ?? '').toString().trim();
    final intent = (result['intent'] ?? '').toString().trim();
    final bool isCrisis = result['is_crisis'] == true;
    final confidenceRaw = result['confidence'];
    final double confidence = confidenceRaw is num
        ? confidenceRaw.toDouble()
        : double.tryParse(confidenceRaw?.toString() ?? '') ?? 0.0;

    if (isCrisis) {
      return 'If you are in immediate danger or thinking about harming yourself, please contact local emergency services or a trusted person right away.';
    }

    switch (intent) {
      case 'sleep_issue':
        return 'It sounds like you’re dealing with sleep trouble. Want quick tips for falling asleep or staying asleep?';
      case 'anxiety':
        return 'It sounds like anxiety is showing up. If you want, we can do a quick grounding exercise together.';
      case 'stress':
        return 'It sounds like stress is building up. Want a 60‑second reset technique?';
      case 'motivation':
        return 'It sounds like motivation is low today. Want a tiny, doable first step?';
    }

    if (emotion.isEmpty && sentiment.isEmpty) return null;

    final tone = sentiment.isNotEmpty ? sentiment : 'mixed';

    if (confidence > 0 && confidence < 0.55) {
      return 'I’m not fully sure, but I sense a $tone tone in what you shared.';
    }
    if (emotion.isNotEmpty) {
      return 'I picked up a sense of $emotion with a $tone tone.';
    }
    return 'I sense a $tone tone in what you shared.';
  }

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
  }

  void _initializeVoiceService() {
    _voiceService.onListeningStarted = () {
      if (mounted) {
        setState(() {
          _isListening = true;
        });
      }
    };

    _voiceService.onListeningStopped = () {
      if (mounted) {
        setState(() {
          _isListening = false;
          _soundLevel = 0.0;
        });
      }
    };

    _voiceService.onTextRecognized = (text) {
      if (mounted) {
        setState(() {
          _controller.text = text;
        });
      }
    };

    _voiceService.onSoundLevelChanged = (level) {
      if (mounted) {
        setState(() {
          _soundLevel = level;
        });
      }
    };

    _voiceService.onError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice error: $error')),
        );
      }
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<int?> _getUserId() async {
    try {
      return await ProfileService.getUserId();
    } catch (_) {
      return null;
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    if (_sending) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _controller.clear();
      _sending = true;
    });
    _scrollToEnd();

    try {
      final userId = await _getUserId();
      final result = await _api.sendChatMessage(message: text, userId: userId);

      String reply;
      String? insightLine;
      if (result != null && result['response'] is String) {
        reply = result['response'] as String;

        insightLine = _buildInsightLine(result);
      } else {
        reply =
            'Thank you for sharing. I had trouble reaching the server, so I will just keep listening.';
      }

      if (!mounted) return;
      setState(() {
        _messages.add(_Message(text: reply, isUser: false));
        if (insightLine != null && insightLine.trim().isNotEmpty) {
          _messages.add(
            _Message(text: insightLine, isUser: false, isHighlight: true),
          );
        }
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          const _Message(
            text:
                'Something went wrong while sending. Please try again in a moment.',
            isUser: false,
            isHighlight: true,
          ),
        );
      });
      _scrollToEnd();
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      await _voiceService.stopListening();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _controller.text.isNotEmpty) {
          _send();
        }
      });
    } else {
      final initialized = await _voiceService.initialize();
      if (initialized) {
        await _voiceService.startListening();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voice recognition is not available on this device'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bubbleMaxWidth = (MediaQuery.of(context).size.width * 0.86).clamp(
      280.0,
      720.0,
    );
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.primary,
              child: Icon(Icons.psychology, size: 18, color: cs.onPrimary),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness Companion',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Chat safely about how you feel',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.surfaceContainerHighest.withValues(alpha: 0.75),
                    cs.surface,
                  ],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  if (m.isHighlight) {

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: bubbleMaxWidth - 60,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Text(
                            m.text,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (m.isUser) {

                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          m.text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    );
                  }


                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: cs.primary,
                        child: Icon(
                          Icons.smart_toy,
                          size: 18,
                          color: cs.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Text(
                            m.text,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: AppSectionCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              gradient: AppSectionCard.gradientFromScheme(
                cs,
                a: cs.surfaceContainerHighest,
                b: cs.surface,
                aAlpha: 0.85,
                bAlpha: 0.60,
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _QuickChip(
                    label: 'I feel anxious',
                    onTap: _sending
                        ? null
                        : () {
                            _controller.text =
                                'I am feeling very anxious today.';
                            _send();
                          },
                  ),
                  _QuickChip(
                    label: 'I can\'t sleep',
                    onTap: _sending
                        ? null
                        : () {
                            _controller.text =
                                'I am struggling with sleep and insomnia.';
                            _send();
                          },
                  ),
                  _QuickChip(
                    label: 'I feel sad',
                    onTap: _sending
                        ? null
                        : () {
                            _controller.text =
                                'I have been feeling really sad and low.';
                            _send();
                          },
                  ),
                  _QuickChip(
                    label: 'I need motivation',
                    onTap: _sending
                        ? null
                        : () {
                            _controller.text =
                                'I need some motivation to get through today.';
                            _send();
                          },
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: AppSectionCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                gradient: AppSectionCard.gradientFromScheme(
                  cs,
                  a: cs.surfaceContainerHighest,
                  b: cs.surface,
                  aAlpha: 0.90,
                  bAlpha: 0.65,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isListening)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            Text(
                              'Listening...',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _soundLevel,
                                minHeight: 4,
                                backgroundColor: cs.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cs.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 5,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            decoration: const InputDecoration(
                              hintText: 'Type a message…',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _sending ? null : _toggleVoiceInput,
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? cs.error : null,
                          ),
                          tooltip: _isListening
                              ? 'Stop listening'
                              : 'Speak instead of type',
                        ),
                        const SizedBox(width: 4),
                        FilledButton.icon(
                          onPressed: _sending ? null : _send,
                          icon: _sending
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(_sending ? 'Sending…' : 'Send'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final bool isHighlight;

  const _Message({
    required this.text,
    required this.isUser,
    this.isHighlight = false,
  });
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _QuickChip({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: cs.surface.withValues(alpha: 0.80),
      side: BorderSide(color: cs.primary.withValues(alpha: 0.55)),
      labelStyle: theme.textTheme.labelLarge?.copyWith(color: cs.primary),
      elevation: 0,
    );
  }
}
