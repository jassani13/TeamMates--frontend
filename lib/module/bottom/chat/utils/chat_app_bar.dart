import 'package:base_code/main.dart'; // AppPref
import 'package:base_code/package/screen_packages.dart'; // AppColor, AppRouter, Gap, etc.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import '../../../../model/conversation_item.dart';


class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.conversation,
    required this.onSearchQuery,
    this.searchHint = 'Search messages',
  });

  final ConversationItem conversation;
  final ValueChanged<String> onSearchQuery;
  final String searchHint;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  late final SearchAppBarController _c;

  @override
  void initState() {
    super.initState();
    _c = SearchAppBarController(onQuery: widget.onSearchQuery);
  }

  @override
  void dispose() {
    _c.onClose(); // dispose TextEditingController/FocusNode
    super.dispose();
  }

  bool get _canShowSettings {
    final isOwner = "${widget.conversation.ownerId}" == "${AppPref().userId}";
    return isOwner && widget.conversation.type == "group";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return _c.isSearching.value
          ? _SearchAppBar(c: _c, hintText: widget.searchHint)
          : AppBar(
        title: Text(widget.conversation.title ?? ''),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == "search") {
                _c.enter();
              } else if (val == "settings") {
                Get.toNamed(
                  AppRouter.editGroupChatScreen,
                  arguments: {"conversation": widget.conversation},
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: "search",
                child: Text(
                  "Search Chat",
                  style: TextStyle(color: AppColor.black12Color),
                ),
              ),
              if (_canShowSettings)
                PopupMenuItem<String>(
                  value: "settings",
                  child: Text(
                    "Settings",
                    style: TextStyle(color: AppColor.black12Color),
                  ),
                ),
            ],
          ),
          const Gap(12),
        ],
      );
    });
  }
}

/// Internal search AppBar used by ChatAppBar.
/// Kept private to this file; fully controlled by SearchAppBarController.
class _SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SearchAppBar({required this.c, this.hintText = 'Search messages'});

  final SearchAppBarController c;
  final String hintText;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: c.exit,
      ),
      titleSpacing: 0,
      title: TextField(
        controller: c.controller,
        focusNode: c.focusNode,
        autofocus: true,
        style: TextStyle(color: AppColor.black12Color),
        textInputAction: TextInputAction.search,
        onChanged: c.onChanged,
        onSubmitted: c.onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          isDense: true,
        ),
      ),
      actions: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: c.controller,
          builder: (_, val, __) {
            final hasText = val.text.isNotEmpty;
            return hasText
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                c.controller.clear();
                c.onChanged('');
                c.focusNode.requestFocus();
              },
            )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class SearchAppBarController extends GetxController {
  SearchAppBarController({this.onQuery});

  final void Function(String)? onQuery;

  final isSearching = false.obs;
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final RxString query = ''.obs;

  void enter() {
    isSearching.value = true;
    Future.microtask(() => focusNode.requestFocus());
  }

  void exit() {
    isSearching.value = false;
    controller.clear();
    query.value = '';
    onQuery?.call('');
  }

  void onChanged(String q) {
    query.value = q;
    onQuery?.call(q);
  }

  @override
  void onClose() {
    controller.dispose();
    focusNode.dispose();
    super.onClose();
  }
}