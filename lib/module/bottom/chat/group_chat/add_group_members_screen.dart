import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

import 'group_chat_controller.dart';

class AddGroupMembersScreen extends StatefulWidget {
  const AddGroupMembersScreen({super.key});

  @override
  State<AddGroupMembersScreen> createState() => _AddGroupMembersScreenState();
}

class _AddGroupMembersScreenState extends State<AddGroupMembersScreen> {
  final groupCtrl = Get.put<GroupChatController>(GroupChatController());

  String? conversationId;
  List<dynamic> rawPlayers = [];
  late final List<String> initialSelected;

  // State
  final TextEditingController searchCtrl = TextEditingController();
  final RxString query = ''.obs;
  final RxSet<String> selected = <String>{}.obs;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments ?? {};
    conversationId = args['conversation_id']?.toString();
    rawPlayers = (args['players'] as List?) ?? [];
    initialSelected = ((args['initialSelected'] as List?) ?? [])
        .map((e) => e.toString())
        .toList();
    selected.addAll(initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hideKeyboard,
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: AppBar(
          backgroundColor: AppColor.white,
          title: Text('Add Members',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: CommonTextField(
                controller: searchCtrl,
                prefixIcon:
                    const Icon(Icons.search, color: AppColor.grey4EColor),
                hintText: 'Search player...',
                onChange: (v) => query.value = (v ?? '').trim().toLowerCase(),
              ),
            ),
            Expanded(child: Obx(() => _buildList())),
            Obx(() => _buildBottomBar(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final q = query.value;
    // normalize data into a shape with id, firstName, lastName, profile
    final players = rawPlayers.map<Map<String, dynamic>>((p) {
      if (p is Map) {
        return {
          'userId': (p['userId'] ?? p['user_id'] ?? '').toString(),
          'firstName': (p['firstName'] ?? p['first_name'] ?? '')?.toString(),
          'lastName': (p['lastName'] ?? p['last_name'] ?? '')?.toString(),
          'profile': (p['profile'] ?? p['profile_url'] ?? '')?.toString(),
        };
      } else {
        // If you pass PlayerTeams objects, adapt this with getters
        final obj = p;
        return {
          'userId': obj.userId.toString(),
          'firstName': obj.firstName?.toString() ?? '',
          'lastName': obj.lastName?.toString() ?? '',
          'profile': obj.profile?.toString() ?? '',
        };
      }
    }).where((m) {
      final full = ('${m['firstName']} ${m['lastName']}').toLowerCase();
      return q.isEmpty || full.contains(q);
    }).toList();

    if (players.isEmpty) {
      return _empty();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: players.length,
      separatorBuilder: (_, __) => Divider(color: AppColor.greyF6Color),
      itemBuilder: (_, i) {
        final m = players[i];
        final id = (m['userId'] ?? '').toString();
        final isSelected = selected.contains(id);
        final imageUrl = (m['profile'] ?? '').toString();
        final name = '${m['firstName'] ?? ''} ${m['lastName'] ?? ''}'.trim();

        return GestureDetector(
          onTap: () {
            if (isSelected) {
              selected.remove(id);
            } else {
              selected.add(id);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColor.greyF6Color : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: getImageView(
                    finalUrl: imageUrl,
                    fit: BoxFit.cover,
                    height: 48,
                    width: 48,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle()
                        .normal20w500
                        .textColor(AppColor.black12Color),
                  ),
                ),
                const SizedBox(width: 12),
                isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.radio_button_unchecked,
                        color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _empty() => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: Get.height / 3.3),
            child: buildNoData(text: 'No Player Found'),
          ),
        ),
      );

  Widget _buildBottomBar(BuildContext context) {
    final count = selected.length;
    final disabled = count == 0;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ]),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$count selected',
                style: TextStyle().normal14w500.textColor(AppColor.grey4EColor),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      disabled ? AppColor.greyF6Color : AppColor.black12Color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: disabled
                    ? null
                    : () async {
                        //selected.toList()
                        dynamic payload = {
                          "conversation_id": conversationId,
                          "owner_id": AppPref().userId
                        };
                        for (int i = 0; i < selected.length; i++) {
                          payload["member_ids[$i]"] = selected.elementAt(i);
                        }
                        Get.back(result: payload);
                      },
                child: Text(
                  "Continue",
                  style: TextStyle(
                    color: disabled ? Colors.black54 : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
