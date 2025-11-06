import 'package:flutter/material.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../../../utils/catched_network_image.dart';
import '../../../../utils/common_function.dart';

typedef ReactionTap = void Function(String messageId, String reaction);

class MessageBubble extends StatelessWidget {
  final types.Message message;
  final bool isMe;
  final ReactionTap onReact;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final String? highlightQuery;
  final VoidCallback? onReactionsTap;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.onReact,
    this.onLongPress,
    this.onTap,
    this.highlightQuery,
    this.onReactionsTap,
  }) : super(key: key);

  bool get _isDeleted => (message.metadata?['deleted_at'] != null);
  bool get _isEdited => (message.metadata?['edited'] == true);

  String _reactionToEmoji(String reaction) {
    if (reaction.isEmpty) return reaction;
    if (!reaction.contains('U+')) return reaction;
    final parts =
        reaction.split(RegExp(r'\s+')).where((p) => p.trim().isNotEmpty);
    final codePoints = <int>[];
    for (final p in parts) {
      final hex = p.toUpperCase().replaceFirst('U+', '');
      final val = int.tryParse(hex, radix: 16);
      if (val != null) codePoints.add(val);
    }
    return codePoints.isEmpty ? reaction : String.fromCharCodes(codePoints);
  }

  TextSpan _highlightSpan(String source, String query, TextStyle baseStyle,
      TextStyle highlightStyle) {
    if (query.trim().isEmpty) return TextSpan(text: source, style: baseStyle);
    try {
      final pattern = RegExp(RegExp.escape(query), caseSensitive: false);
      final matches = pattern.allMatches(source).toList();
      if (matches.isEmpty) return TextSpan(text: source, style: baseStyle);

      final spans = <TextSpan>[];
      int lastIndex = 0;
      for (final m in matches) {
        if (m.start > lastIndex) {
          spans.add(TextSpan(
              text: source.substring(lastIndex, m.start), style: baseStyle));
        }
        spans.add(TextSpan(
            text: source.substring(m.start, m.end), style: highlightStyle));
        lastIndex = m.end;
      }
      if (lastIndex < source.length) {
        spans
            .add(TextSpan(text: source.substring(lastIndex), style: baseStyle));
      }
      return TextSpan(children: spans);
    } catch (_) {
      return TextSpan(text: source, style: baseStyle);
    }
  }

  Widget _buildMessageText(BuildContext context, String text) {
    final query = highlightQuery ?? '';
    final baseStyle = const TextStyle(color: Colors.black);
    final highlightStyle =
        baseStyle.copyWith(backgroundColor: Colors.yellow.withOpacity(0.6));
    if (query.trim().isEmpty) {
      return Text(text, style: baseStyle);
    }
    return RichText(
      text: TextSpan(
        children: [_highlightSpan(text, query, baseStyle, highlightStyle)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = message.metadata ?? {};
    final msgType = meta['msg_type'] ?? 'text';
    final reactions = meta['reactions'] as List? ?? [];
    final isFlagged = meta['flagged'] == true;
    final isPinned = meta['pinned'] == true;

    if (_isDeleted) {
      // Keep deleted bubbles left-aligned and maintain consistent leading spacing
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ClipOval(
                child: getImageView(
                    height: 30,
                    width: 30,
                    finalUrl: message.author.imageUrl ?? '',
                    fit: BoxFit.cover,
                    errorWidget: const Icon(Icons.account_circle, size: 30)),
              ),
            )
          else
            const SizedBox(width: 38), // 30 avatar + 8 spacing
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColor.greyF6Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'This message was deleted.',
                  style: TextStyle(
                      color: Colors.black45, fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget content;
    if (msgType == 'image') {
      final url = meta['file_url'] ?? '';
      content = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: getImageView(
            finalUrl: url, height: 200, width: 200, fit: BoxFit.cover),
      );
    } else if (msgType == 'file' || msgType == 'pdf') {
      final url = meta['file_url'] ?? '';
      final title = meta['raw_msg'] ??
          (message is types.FileMessage
              ? (message as types.FileMessage).name
              : 'Document');
      content = GestureDetector(
        onTap: () => openPdf(url),
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
              color: AppColor.greyF6Color,
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColor.black12Color),
                  child: _buildMessageText(context, title),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final text = meta['raw_msg'] ??
          (message is types.TextMessage
              ? (message as types.TextMessage).text
              : '');
      content = Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
            color: AppColor.greyF6Color,
            borderRadius: BorderRadius.circular(10)),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageText(context, text),
            if (_isEdited)
              const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('Edited',
                      style: TextStyle(fontSize: 10, color: Colors.black38)),
                ),
              )
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ClipOval(
                child: getImageView(
                    height: 30,
                    width: 30,
                    finalUrl: message.author.imageUrl ?? '',
                    fit: BoxFit.cover,
                    errorWidget: const Icon(Icons.account_circle, size: 30)),
              ),
            )
          else
            const SizedBox(width: 38),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 4, right: 6, left: 6),
                    child: Text(message.author.firstName ?? '',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54)),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      content,
                      // Small badges for pinned/flagged
                      if (isFlagged || isPinned)
                        Positioned(
                          top: 4,
                          right: 6,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isPinned)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.push_pin,
                                      size: 14, color: Colors.amber),
                                ),
                              if (isFlagged)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(Icons.flag,
                                      size: 14, color: Colors.redAccent),
                                ),
                            ],
                          ),
                        ),
                      if (reactions.isNotEmpty)
                        GestureDetector(
                          onTap: onReactionsTap,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Wrap(
                              spacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                ...reactions.take(2).map((r) {
                                  final reactionString =
                                      (r['reaction'] ?? '').toString();
                                  final emoji =
                                      _reactionToEmoji(reactionString);
                                  final toShow =
                                      emoji.isNotEmpty ? emoji : reactionString;
                                  return Text(toShow,
                                      style: const TextStyle(fontSize: 12));
                                }),
                                if (reactions.length > 2)
                                  Text('+${reactions.length - 2}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.black12Color)),
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
