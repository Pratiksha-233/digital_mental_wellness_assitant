import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
	const ChatScreen({super.key});

	@override
	State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
	final List<_Message> _messages = const [
		_Message(text: "Hi! I'm here to listen. How are you feeling today?", isUser: false),
	];
	final TextEditingController _controller = TextEditingController();
	final ScrollController _scrollController = ScrollController();
	bool _sending = false;

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

	Future<void> _send() async {
		final text = _controller.text.trim();
		if (text.isEmpty || _sending) return;
		setState(() {
			_messages.add(_Message(text: text, isUser: true));
			_controller.clear();
			_sending = true;
		});
		_scrollToEnd();

		// TODO: Replace with backend call to your Flask/Firebase endpoint
		await Future.delayed(const Duration(milliseconds: 600));
		final reply = _localReply(text);
		setState(() {
			_messages.add(_Message(text: reply, isUser: false));
			_sending = false;
		});
		_scrollToEnd();
	}

	String _localReply(String userText) {
		final u = userText.toLowerCase();
		if (u.contains('anx') || u.contains('stress')) {
			return 'It sounds stressful. Try 4-7-8 breathing and a 5‑minute walk. Want a quick self‑care tip?';
		}
		if (u.contains('sleep') || u.contains('insomnia') || u.contains('tired')) {
			return 'Sleep can be tough. Dimming lights and avoiding screens 30 min before bed often helps.';
		}
		if (u.contains('sad') || u.contains('down') || u.contains('low')) {
			return 'I’m here with you. Consider writing one thing that went okay today, however small.';
		}
		if (u.contains('angry') || u.contains('frustrat')) {
			return 'Those feelings are valid. Try a 60‑second posture reset and 10 slow breaths.';
		}
		return 'Thank you for sharing. Tell me a little more, or say “tip” for a quick self‑care suggestion.';
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Therapy Chatbot')),
			body: Column(
				children: [
					Expanded(
						child: Container(
							decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.teal.shade50, Colors.white])),
							child: ListView.builder(
								controller: _scrollController,
								padding: const EdgeInsets.all(16),
								itemCount: _messages.length,
								itemBuilder: (context, i) {
									final m = _messages[i];
									return Align(
										alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
										child: Container(
											margin: const EdgeInsets.symmetric(vertical: 6),
											padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
											constraints: const BoxConstraints(maxWidth: 720),
											decoration: BoxDecoration(
												color: m.isUser ? const Color(0xFF0F766E) : Colors.white,
												borderRadius: BorderRadius.circular(14),
												boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.07), blurRadius: 6, offset: const Offset(0, 3))],
												border: m.isUser ? null : Border.all(color: Colors.grey.shade200),
											),
											child: Text(m.text, style: TextStyle(color: m.isUser ? Colors.white : Colors.black87)),
										),
									);
								},
							),
						),
					),
					const Divider(height: 1),
					SafeArea(
						top: false,
						child: Padding(
							padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
							child: Row(children: [
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
									onPressed: _sending ? null : _send,
									icon: const Icon(Icons.send),
									label: Text(_sending ? 'Sending…' : 'Send'),
									style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white),
								)
							]),
						),
					)
				],
			),
		);
	}
}

class _Message {
	final String text;
	final bool isUser;
	const _Message({required this.text, required this.isUser});
}
