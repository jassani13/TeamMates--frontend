import 'package:base_code/package/config_packages.dart';
import 'package:base_code/model/event_tag_model.dart';
import 'package:base_code/package/screen_packages.dart';

class TagManagementController extends GetxController {
  // Observable lists and states
  var isLoading = false.obs;
  var tags = <EventTag>[].obs;
  // REMOVED: var selectedTeamId = 0.obs; - No longer needed
  
  // Form controllers for add/edit
  final tagNameController = TextEditingController();
  final tagColorController = TextEditingController();
  var selectedColor = Rxn<Color>(Colors.blue);
  var isCreating = false.obs;
  var isUpdating = false.obs;
  var editingTagId = 0.obs;

  // Predefined colors for tag creation
  final List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.deepOrange,
    Colors.lightGreen,
    Colors.deepPurple,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void onInit() {
    super.onInit();
    // Tags are coach-specific, no need for team_id
    getEventTags();
  }

  @override
  void onClose() {
    tagNameController.dispose();
    tagColorController.dispose();
    super.onClose();
  }

  /// Get all tags for the current coach
  Future<void> getEventTags() async {
    try {
      isLoading(true);
      
      var data = {
        "user_id": AppPref().userId,
        // Remove team_id - tags are coach-specific now
      };

      var res = await callApi(
        dio.post(
          ApiEndPoint.getEventTags,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        if (jsonData['ResponseCode'] == 1) {
          tags.clear();
          if (jsonData['tags'] != null) {
            List<dynamic> tagList = jsonData['tags'];
            for (var tagJson in tagList) {
              tags.add(EventTag.fromJson(tagJson));
            }
          }
        } else {
          showErrorSnackBar(jsonData['ResponseMsg'] ?? 'Failed to load tags');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showErrorSnackBar('Error loading tags: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Create a new tag
  Future<void> createEventTag() async {
    if (!_validateTagForm()) return;

    try {
      isCreating(true);

      var data = {
        "user_id": AppPref().userId,
        // Remove team_id - tags are coach-specific now
        "tag_name": tagNameController.text.trim(),
        "tag_color": colorToHex(selectedColor.value ?? Colors.blue),
      };

      var res = await callApi(
        dio.post(
          ApiEndPoint.createEventTag,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        if (jsonData['ResponseCode'] == 1) {
          // Add the new tag to the list
          if (jsonData['tag'] != null) {
            EventTag newTag = EventTag.fromJson(jsonData['tag']);
            tags.add(newTag);
          }
          
          // Stop loading and reset form
          isCreating(false);
          _resetForm();
          
          // Go back first
          Get.back();
          
          // Use a delayed snackbar to ensure it shows on the previous screen
          Future.delayed(Duration(milliseconds: 100), () {
            Get.snackbar(
              'Success',
              'Tag created successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: Duration(seconds: 4), // Even longer duration
              snackPosition: SnackPosition.TOP,
              margin: EdgeInsets.all(16),
              borderRadius: 8,
              isDismissible: true,
              dismissDirection: DismissDirection.horizontal,
              forwardAnimationCurve: Curves.easeOutBack,
              reverseAnimationCurve: Curves.easeInBack,
            );
          });
        } else {
          showErrorSnackBar(jsonData['ResponseMsg'] ?? 'Failed to create tag');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showErrorSnackBar('Error creating tag: $e');
    } finally {
      isCreating(false);
    }
  }

  /// Update an existing tag
  Future<void> updateEventTag() async {
    if (!_validateTagForm()) return;

    try {
      isUpdating(true);

      var data = {
        "user_id": AppPref().userId,
        "tag_id": editingTagId.value,
        "tag_name": tagNameController.text.trim(),
        "tag_color": colorToHex(selectedColor.value ?? Colors.blue),
      };

      var res = await callApi(
        dio.post(
          ApiEndPoint.updateEventTag,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        if (jsonData['ResponseCode'] == 1) {
          // Update the tag in the list
          int index = tags.indexWhere((tag) => tag.tagId == editingTagId.value);
          if (index != -1) {
            if (jsonData['tag'] != null) {
              tags[index] = EventTag.fromJson(jsonData['tag']);
            } else {
              // Update manually if API doesn't return updated tag
              tags[index] = tags[index].copyWith(
                tagName: tagNameController.text.trim(),
                tagColor: colorToHex(selectedColor.value ?? Colors.blue),
              );
            }
          }
          
          // Stop loading and reset form
          isUpdating(false);
          _resetForm();
          
          // Go back first
          Get.back();
          
          // Use a delayed snackbar to ensure it shows on the previous screen
          Future.delayed(Duration(milliseconds: 100), () {
            Get.snackbar(
              'Success',
              'Tag updated successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: Duration(seconds: 4), // Even longer duration
              snackPosition: SnackPosition.TOP,
              margin: EdgeInsets.all(16),
              borderRadius: 8,
              isDismissible: true,
              dismissDirection: DismissDirection.horizontal,
              forwardAnimationCurve: Curves.easeOutBack,
              reverseAnimationCurve: Curves.easeInBack,
            );
          });
        } else {
          showErrorSnackBar(jsonData['ResponseMsg'] ?? 'Failed to update tag');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showErrorSnackBar('Error updating tag: $e');
    } finally {
      isUpdating(false);
    }
  }

  /// Delete a tag
  Future<void> deleteEventTag(int tagId) async {
    try {
      // Show confirmation dialog
      bool? confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: Colors.white, // ADD THIS - Set dialog background
          title: Text(
            'Delete Tag',
            style: TextStyle(
              color: Colors.black87, // ADD THIS - Fix invisible title
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this tag? This action cannot be undone.',
            style: TextStyle(
              color: Colors.grey[700], // ADD THIS - Fix invisible content
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600], // ADD THIS - Fix button text
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red, // This was already there but ensure it's visible
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      var data = {
        "user_id": AppPref().userId,
        "tag_id": tagId,
      };

      var res = await callApi(
        dio.post(
          ApiEndPoint.deleteEventTag,
          data: data,
        ),
        false,
      );

      if (res?.statusCode == 200) {
        var jsonData = res?.data;
        if (jsonData['ResponseCode'] == 1) {
          // Remove tag from the list
          tags.removeWhere((tag) => tag.tagId == tagId);
          showSuccessSnackBar('Tag deleted successfully');
        } else {
          showErrorSnackBar(jsonData['ResponseMsg'] ?? 'Failed to delete tag');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      showErrorSnackBar('Error deleting tag: $e');
    }
  }

  /// Set up form for editing a tag
  void startEditTag(EventTag tag) {
    editingTagId.value = tag.tagId ?? 0;
    tagNameController.text = tag.tagName ?? '';
    selectedColor.value = tag.color;
    tagColorController.text = tag.tagColor ?? '';
  }

  /// Reset form to initial state
  void _resetForm() {
    tagNameController.clear();
    tagColorController.clear();
    selectedColor.value = Colors.blue;
    editingTagId.value = 0;
  }

  /// Validate tag form
  bool _validateTagForm() {
    if (tagNameController.text.trim().isEmpty) {
      showErrorSnackBar('Please enter a tag name');
      return false;
    }
    
    if (tagNameController.text.trim().length > 50) {
      showErrorSnackBar('Tag name must be 50 characters or less');
      return false;
    }

    // Check for duplicate tag names for this coach (excluding current tag if editing)
    bool isDuplicate = tags.any((tag) => 
      tag.tagName?.toLowerCase() == tagNameController.text.trim().toLowerCase() &&
      tag.tagId != editingTagId.value
    );

    if (isDuplicate) {
      showErrorSnackBar('You already have a tag with this name');
      return false;
    }

    return true;
  }

  /// Convert Color to hex string
  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Helper methods (updated to use your app structure)
  void showSuccessSnackBar(String message) {
    Get.snackbar(
      'Success', 
      message, 
      backgroundColor: Colors.green, 
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
    );
  }

  void showErrorSnackBar(String message) {
    Get.snackbar(
      'Error', 
      message, 
      backgroundColor: Colors.red, 
      colorText: Colors.white,
      duration: Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16),
    );
  }
}