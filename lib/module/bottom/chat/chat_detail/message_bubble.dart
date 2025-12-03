import 'package:base_code/components/thread_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:base_code/package/screen_packages.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
  final VoidCallback? onThreadPreviewTap;

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
    this.onThreadPreviewTap,
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

  String _formatTime(types.Message m) {
    try {
      final ms = m.createdAt;
      if (ms != null) {
        final dt =
            DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
        return DateFormat('h:mm a').format(dt);
      }
      final createdStr = m.metadata?['created_at']?.toString();
      if (createdStr != null && createdStr.isNotEmpty) {
        final dt =
            DateTime.tryParse(createdStr.replaceFirst(' ', 'T'))?.toLocal();
        if (dt != null) return DateFormat('h:mm a').format(dt);
      }
    } catch (_) {}
    return '';
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
    final repliesCount = meta['replies_count'] is int
        ? meta['replies_count'] as int
        : int.tryParse(meta['replies_count']?.toString() ?? '0') ?? 0;
    final latestReplyText = (meta['latest_reply_text'] ?? '').toString();
    final latestReplySender = (meta['latest_reply_sender'] ?? '').toString();
    final showThreadPreview = repliesCount > 0;

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
      // Wrap image in a Container that has extra bottom/right padding to avoid footer collision.
      final willShowFooter = (isMe && showReadReceipt) || isPinned || isFlagged;
      content = Container(
        padding: EdgeInsets.only(
          right: willShowFooter ? 72.0 : 20.0,
          bottom: 18.0 + 6.0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: getImageView(
              finalUrl: url, height: 200, width: 200, fit: BoxFit.cover),
        ),
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
          // Reserve space to avoid footer overlap on file/pdf bubbles as well.
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: ((isMe && showReadReceipt) || isPinned || isFlagged)
                ? 72.0
                : 28.0,
            bottom: 18.0 + 8.0,
          ),
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
      // Reserve space for the bottom-right footer (tick/time/pin/flag) to avoid overlap with text.
      final willShowFooter = (isMe && showReadReceipt) || isPinned || isFlagged;
      const footerHeightReserve = 10.0; // vertical space for footer row
      final rightReserve =
          willShowFooter ? 76.0 : 28.0; // extra space for multiple icons
      content = Container(
        padding: EdgeInsets.only(
          top: 12,
          left: 14,
          // Extra right padding so long lines don't render underneath the footer row.
          right: rightReserve,
          // Extra bottom padding so last line isn't overlapped by Positioned footer.
          bottom: footerHeightReserve + 8, // include a little breathing room
        ),
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
              ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          content,
                          Positioned(
                            bottom: 4,
                            right: 6,
                            child: _BubbleFooter(
                              timeText: _formatTime(message),
                              onMedia: msgType == 'image',
                              showRead: isMe && showReadReceipt,
                              readByCount: readBy.length,
                              onReadByTap: onReadByTap,
                              isPinned: isPinned,
                              isFlagged: isFlagged,
                            ),
                          ),
                          if (reactions.isNotEmpty)
                            Positioned(
                              bottom: 22,
                              right: 6,
                              child: GestureDetector(
                                onTap: onReactionsTap,
                                child: Wrap(
                                  spacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    ...reactions.take(2).map((r) {
                                      final reactionString =
                                          (r['reaction'] ?? '').toString();
                                      final emoji =
                                          _reactionToEmoji(reactionString);
                                      final toShow = emoji.isNotEmpty
                                          ? emoji
                                          : reactionString;
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
                        ],
                      ),
                      if (showThreadPreview)
                        ThreadPreviewWidget(
                          repliesCount: repliesCount,
                          latestReplyText: latestReplyText.isNotEmpty
                              ? latestReplyText
                              : null,
                          latestReplySender: latestReplySender.isNotEmpty
                              ? latestReplySender
                              : null,
                          margin: const EdgeInsets.only(top: 6),
                          onTap: onThreadPreviewTap ?? onTap ?? () {},
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

class _BubbleFooter extends StatelessWidget {
  final String timeText;
  final bool onMedia;
  final bool showRead;
  final int readByCount;
  final VoidCallback? onReadByTap;
  final bool isPinned;
  final bool isFlagged;

  const _BubbleFooter({
    Key? key,
    required this.timeText,
    required this.onMedia,
    required this.showRead,
    required this.readByCount,
    this.onReadByTap,
    this.isPinned = false,
    this.isFlagged = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasRead = showRead && readByCount > 0;
    final showTime = timeText.isNotEmpty;
    if (!showTime && !hasRead && !isPinned && !isFlagged) {
      return const SizedBox.shrink();
    }

    final timeWidget = Text(
      timeText,
      style: TextStyle(
        fontSize: 10,
        color: onMedia ? Colors.white : Colors.grey.shade600,
      ),
    );
    final readIcon = hasRead
        ? GestureDetector(
            onTap: onReadByTap,
            child: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.done_all, size: 14, color: Color(0xFF25D366)),
            ),
          )
        : const SizedBox.shrink();

    final pinIcon = isPinned
        ? const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(Icons.push_pin, size: 14, color: Colors.amber),
          )
        : const SizedBox.shrink();
    final flagIcon = isFlagged
        ? const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(Icons.flag, size: 14, color: Colors.redAccent),
          )
        : const SizedBox.shrink();

    // Order visually from right to left as requested:
    // rightmost: read tick, then time, then pin, then flag (leftmost)
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // leftmost
        flagIcon,
        pinIcon,
        if (showTime) timeWidget,
        // rightmost
        readIcon,
      ],
    );

    if (onMedia) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(10),
        ),
        child: row,
      );
    }
    return row;
  }
}
