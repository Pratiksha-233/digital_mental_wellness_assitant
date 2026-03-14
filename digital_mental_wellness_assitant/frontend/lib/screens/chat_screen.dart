import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';

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
  final ApiService _api = ApiService();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
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

        final emotion = (result['emotion'] ?? '').toString();
        final sentiment = (result['sentiment'] ?? '').toString();
        final bool isCrisis = result['is_crisis'] == true;

        if (emotion.isNotEmpty || sentiment.isNotEmpty) {
          final tone = sentiment.isNotEmpty ? sentiment : 'mixed';
          if (emotion.isNotEmpty) {
            insightLine = 'I picked up a sense of $emotion with a $tone tone.';
          } else {
            insightLine = 'I sense a $tone tone in what you shared.';
          }
        }

        if (isCrisis) {
          // Add a separate gentle safety notice message
          insightLine =
              'If you are in immediate danger or thinking about harming yourself, please contact local emergency services or a trusted person right away.';
        }
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

  @override
  Widget build(BuildContext context) {
    final bubbleMaxWidth = (MediaQuery.of(context).size.width * 0.86).clamp(
      280.0,
      720.0,
    );
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF4F46E5),
              child: Icon(Icons.psychology, size: 18, color: Colors.white),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness Companion',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Chat safely about how you feel',
                  style: TextStyle(fontSize: 11),
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
                  colors: [Colors.indigo.shade50, Colors.white],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  if (m.isHighlight) {
                    // Small centered insight / system note
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
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            m.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (m.isUser) {
                    // User message (right-aligned, solid color bubble)
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
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.shade200.withOpacity(0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          m.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  // Bot message (left-aligned with avatar, like the mockup)
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF4F46E5),
                        child: Icon(
                          Icons.smart_toy,
                          size: 18,
                          color: Colors.white,
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            m.text,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
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
          // Quick suggestion chips similar to the preset buttons in the mockup
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _QuickChip(
                  label: 'I feel anxious',
                  onTap: _sending
                      ? null
                      : () {
                          _controller.text = 'I am feeling very anxious today.';
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
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
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
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    label: Text(_sending ? 'Sending…' : 'Send'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
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
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFF4F46E5)),
      labelStyle: const TextStyle(color: Color(0xFF4F46E5)),
      elevation: 0,
    );
  }
}
