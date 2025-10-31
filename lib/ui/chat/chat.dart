import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:async';

// Update Message class
class Message {
  final String text;
  final bool isUser;
  final bool shouldAnimate;
  final String id;
  bool hasAnimated;

  Message(this.text, this.isUser, {this.shouldAnimate = false})
      : id = DateTime.now().millisecondsSinceEpoch.toString(),
        hasAnimated = false;
}

class AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final MarkdownStyleSheet? markdownStyleSheet;

  const AnimatedText({
    super.key,
    required this.text,
    this.style,
    this.markdownStyleSheet,
  });

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  String _displayText = '';
  bool _isDone = false;
  Timer? _timer;
  bool _hasStartedAnimation = false;

  @override
  void initState() {
    super.initState();
    if (!_hasStartedAnimation) {
      _hasStartedAnimation = true;
      _startAnimation();
    }
  }

  void _startAnimation() {
    var index = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (index < widget.text.length) {
        setState(() {
          _displayText = widget.text.substring(0, index + 1);
        });
        index++;
      } else {
        setState(() => _isDone = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDone) {
      return MarkdownBody(
        data: widget.text,
        styleSheet: widget.markdownStyleSheet,
      );
    }
    return Text(
      _displayText,
      style: widget.markdownStyleSheet?.p ??
          const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _animControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    _animations = _animControllers.map((controller) {
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    for (var i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _animControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          left: 8,
          right: 64,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    shape: BoxShape.circle,
                  ),
                  transform: Matrix4.translationValues(
                    0,
                    _animations[index].value,
                    0,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class ChatBackground extends StatelessWidget {
  const ChatBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("assets/images/chat_background.jpg"),
          repeat: ImageRepeat.repeat,
          opacity: 0.4,
        ),
      ),
    );
  }
}

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();

    setState(() {
      _messages.add(Message(text, true));
      _isLoading = true;
    });

    _scrollToBottom(); // 👈 scroll immediately after user sends

    try {
      final response = await http.post(
        Uri.parse('http://192.168.29.189:8000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'mode': 'Fast',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add(Message(data['response'], false, shouldAnimate: true));
        });
        _scrollToBottom(); // 👈 scroll when AI reply arrives
      } else {
        setState(() {
          _messages.add(Message('Sorry, I encountered an error.', false));
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.add(Message('Network error occurred.', false));
      });
      _scrollToBottom();
    } finally {
      setState(() {
        _isLoading = false;
      });
      _textController.clear();
    }
  }

  // Update _buildMessageBubble to check hasAnimated
  Widget _buildMessageBubble(Message message) {
    if (message.shouldAnimate && !message.hasAnimated) {
      message.hasAnimated = true;
      return Align(
        alignment:
            message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            left: message.isUser ? 64 : 8,
            right: message.isUser ? 8 : 64,
            top: 4,
            bottom: 4,
          ),
          decoration: BoxDecoration(
            color: message.isUser
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(message.isUser ? 16 : 0),
              bottomRight: Radius.circular(message.isUser ? 0 : 16),
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    message.isUser
                        ? Text(
                            message.text,
                            style: const TextStyle(color: Colors.black),
                          )
                        : AnimatedText(
                            key: ValueKey(message.id),
                            text: message.text,
                            markdownStyleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              strong: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              listBullet: const TextStyle(color: Colors.black),
                            ),
                          ),
                    const SizedBox(height: 15), // Space for timestamp
                  ],
                ),
              ),
              Positioned(
                bottom: 4,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.isUser) ...[
                      Icon(
                        Icons.done_all,
                        size: 16,
                        color: Colors.black,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Return non-animated version
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: message.isUser ? 64 : 8,
          right: message.isUser ? 8 : 64,
          top: 4,
          bottom: 4,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.secondary
              : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 0),
            bottomRight: Radius.circular(message.isUser ? 0 : 16),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  message.isUser
                      ? Text(
                          message.text,
                          style: const TextStyle(color: Colors.black),
                        )
                      : MarkdownBody(
                          data: message.text,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            strong: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            listBullet: const TextStyle(color: Colors.black),
                          ),
                        ),
                  const SizedBox(height: 15), // Space for timestamp
                ],
              ),
            ),
            Positioned(
              bottom: 4,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isUser) ...[
                    Icon(
                      Icons.done_all,
                      size: 16,
                      color: Colors.black,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          "Chat with AI",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Stack(
        children: [
          // Background
          const ChatBackground(),
          // Chat content
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true, // 👈 makes new messages appear at the bottom
                  padding: const EdgeInsets.all(8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[
                        _messages.length - 1 - index]; // 👈 reverse order
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              if (_isLoading) const TypingIndicator(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, -1),
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Container(
                          color: Colors.grey.shade100,
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                            ),
                            onSubmitted: (text) => _sendMessage(text),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.black),
                        onPressed: () => _sendMessage(_textController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
