import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';

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
  // Fired when the read-receipt (double check) is tapped
  final VoidCallback? onReadByTap;
  final bool showReadReceipt;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.onReact,
    this.onLongPress,
    this.onTap,
    this.highlightQuery,
    this.onReactionsTap,
    this.onReadByTap,
    this.showReadReceipt = true,
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
    final linkStyle = baseStyle.copyWith(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    );

    InlineSpan span = _linkifiedHighlightedSpan(
      text,
      query,
      baseStyle,
      highlightStyle,
      linkStyle,
    );

    return RichText(text: TextSpan(children: [span]));
  }

  // Build a TextSpan that detects links (http, https, www) and applies
  // clickable recognizers that open in-app. Also highlights the search query
  // within non-link segments.
  InlineSpan _linkifiedHighlightedSpan(
    String source,
    String query,
    TextStyle base,
    TextStyle highlight,
    TextStyle link,
  ) {
    final urlRegex =
        RegExp(r'((https?:\/\/|www\.)[^\s]+)', caseSensitive: false);
    final List<InlineSpan> children = [];
    int cursor = 0;
    for (final match in urlRegex.allMatches(source)) {
      if (match.start > cursor) {
        final before = source.substring(cursor, match.start);
        children.add(_highlightSpan(before, query, base, highlight));
      }
      final urlText = match.group(0) ?? '';
      final normalized = _normalizeUrl(urlText);
      children.add(TextSpan(
        text: urlText,
        style: link,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Get.toNamed(AppRouter.webViewScreen,
                arguments: {"url": normalized});
          },
      ));
      cursor = match.end;
    }
    if (cursor < source.length) {
      final trailing = source.substring(cursor);
      children.add(_highlightSpan(trailing, query, base, highlight));
    }

    return TextSpan(children: children, style: base);
  }

  String _normalizeUrl(String raw) {
    String t = raw.trim();
    // Strip common trailing punctuation that often follows links in prose
    while (t.isNotEmpty && '.,);:!?'.contains(t[t.length - 1])) {
      t = t.substring(0, t.length - 1);
    }
    if (t.toLowerCase().startsWith('http://') ||
        t.toLowerCase().startsWith('https://')) {
      return t;
    }
    if (t.toLowerCase().startsWith('www.')) {
      return 'https://$t';
    }
    // Fallback: treat as https
    return 'https://$t';
  }

  @override
  Widget build(BuildContext context) {
    final meta = message.metadata ?? {};
    final msgType = meta['msg_type'] ?? 'text';
    final reactions = meta['reactions'] as List? ?? [];
    final isFlagged = meta['flagged'] == true;
    final isPinned = meta['pinned'] == true;
    final readBy = ((meta['read_by'] as List?)
            ?.map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList()) ??
        [];

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
                        ),
                      if (isMe && showReadReceipt && readBy.isNotEmpty)
                        Positioned(
                          bottom: 4,
                          right: reactions.isNotEmpty ? 4 : 6,
                          child: GestureDetector(
                            onTap: onReadByTap,
                            child: _ReadReceiptIndicator(
                                readByCount: readBy.length),
                          ),
                        ),
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

class _ReadReceiptIndicator extends StatelessWidget {
  final int readByCount;

  const _ReadReceiptIndicator({Key? key, required this.readByCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Single check = delivered (implicitly), double = read by >=1, show a small stacked icon.
    // If multiple readers, still show double check, tinted blue.
    bool isDouble = readByCount >= 1;
    if (!isDouble) {
      return Icon(Icons.done, size: 14, color: Colors.grey.shade600);
    }
    return const Icon(Icons.done_all, size: 14, color: Color(0xFF34B7F1));
  }
}
