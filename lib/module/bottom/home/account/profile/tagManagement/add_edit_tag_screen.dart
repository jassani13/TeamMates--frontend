import 'package:base_code/package/config_packages.dart';
import 'tag_management_controller.dart';

class AddEditTagScreen extends StatelessWidget {
  final bool isEditing;
  
  AddEditTagScreen({super.key, required this.isEditing});

  final TagManagementController controller = Get.find<TagManagementController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Tag' : 'Add Tag'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          Obx(() => TextButton(
            onPressed: controller.isCreating.value || controller.isUpdating.value
                ? null
                : _saveTag,
            child: Text(
              'Save',
              style: TextStyle(
                color: controller.isCreating.value || controller.isUpdating.value
                    ? Colors.grey
                    : Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag Name Section
            _buildSectionTitle('Tag Name'),
            SizedBox(height: 8),
            _buildTagNameField(),
            SizedBox(height: 24),

            // Color Selection Section
            _buildSectionTitle('Tag Color'),
            SizedBox(height: 8),
            _buildColorSelection(),
            SizedBox(height: 24),

            // Preview Section
            _buildSectionTitle('Preview'),
            SizedBox(height: 8),
            _buildPreview(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTagNameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller.tagNameController,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Enter tag name (e.g., Fitness, Goalie, Video)',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        textCapitalization: TextCapitalization.words,
        maxLength: 50,
        buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
          return Text(
            '$currentLength/$maxLength',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a color for your tag:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: controller.availableColors.map((color) {
              return _buildColorOption(color);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    return Obx(() {
      bool isSelected = controller.selectedColor.value == color;
      
      return GestureDetector(
        onTap: () => controller.selectedColor.value = color,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                )
              : null,
        ),
      );
    });
  }

  Widget _buildPreview() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How your tag will look:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Obx(() {
            String tagName = controller.tagNameController.text.trim();
            if (tagName.isEmpty) {
              tagName = 'Sample Tag';
            }
            
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: controller.selectedColor.value ?? Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tagName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _saveTag() {
    if (isEditing) {
      controller.updateEventTag();
    } else {
      controller.createEventTag();
    }
  }
}