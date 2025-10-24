import 'package:base_code/package/screen_packages.dart';
import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final void Function(String) onSend;
  final VoidCallback onAttachImage;
  final VoidCallback onAttachFile;
  final void Function(String) onTextChanged;

  const ChatInput({
    Key? key,
    required this.onSend,
    required this.onAttachImage,
    required this.onAttachFile,
    required this.onTextChanged,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _canSend = false;

  void _onChanged() {
    final t = _controller.text;
    setState(() => _canSend = t.trim().isNotEmpty);
    widget.onTextChanged(t);
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    widget.onSend(t);
    _controller.clear();
    setState(() => _canSend = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            IconButton(
              onPressed: widget.onAttachImage,
              icon: const Icon(Icons.photo),
            ),
            IconButton(
              onPressed: widget.onAttachFile,
              icon: const Icon(Icons.attach_file),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColor.greyF6Color,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Type a message',
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: AppColor.black12Color)),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        style: TextStyle(
                            color: AppColor.black12Color,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    IconButton(
                      onPressed: _canSend ? _send : null,
                      icon: Icon(Icons.send,
                          color:
                              _canSend ? AppColor.primaryColor : Colors.grey),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
