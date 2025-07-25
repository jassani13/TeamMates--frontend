// File: lib/module/bottom/home/account/profile/tagManagement/tag_management_screen.dart

import 'package:base_code/package/config_packages.dart';
import 'package:base_code/model/event_tag_model.dart';
import 'tag_management_controller.dart';
import 'add_edit_tag_screen.dart';

class TagManagementScreen extends StatelessWidget {
  final TagManagementController controller = Get.put(TagManagementController());

  TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Tags',
          style: TextStyle(color: Colors.black87), // FIXED
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Header section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Tags',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Create custom tags to organize your events (e.g., Fitness, Goalie, Video)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Tags list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.tags.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: controller.tags.length,
                itemBuilder: (context, index) {
                  final tag = controller.tags[index];
                  return _buildTagItem(tag);
                },
              );
            }),
          ),
        ],
      ),
      
      // Floating action button to add new tag
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddTag(),
        icon: Icon(Icons.add, color: Colors.white), // FIXED
        label: Text(
          'Add Tag',
          style: TextStyle(color: Colors.white), // FIXED
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.label_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No tags yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first tag to start organizing events',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddTag(),
            icon: Icon(Icons.add, color: Colors.white), // FIXED
            label: Text(
              'Create Tag',
              style: TextStyle(color: Colors.white), // FIXED
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagItem(EventTag tag) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tag.color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.label,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          tag.displayName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Color: ${tag.tagColor}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, tag),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Edit',
                    style: TextStyle(color: Colors.black87), // FIXED
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Delete',
                    style: TextStyle(color: Colors.black87), // FIXED
                  ),
                ],
              ),
            ),
          ],
          child: Icon(Icons.more_vert, color: Colors.grey[600]),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, EventTag tag) {
    switch (action) {
      case 'edit':
        _navigateToEditTag(tag);
        break;
      case 'delete':
        controller.deleteEventTag(tag.tagId ?? 0);
        break;
    }
  }

  void _navigateToAddTag() {
    Get.to(() => AddEditTagScreen(isEditing: false));
  }

  void _navigateToEditTag(EventTag tag) {
    controller.startEditTag(tag);
    Get.to(() => AddEditTagScreen(isEditing: true));
  }
}