import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class GlobalController extends GetxController {
  void updateScheduleData(ScheduleData updatedData) {
    var scheduleController = Get.find<ScheduleController>();

    ShortedData? oldGroup;
    int oldGroupIndex = -1;
    int oldDataIndex = -1;
    for (int i = 0; i < scheduleController.sortedScheduleList.length; i++) {
      var shortedData = scheduleController.sortedScheduleList[i];
      int dataIndex = shortedData.data.indexWhere((e) => e.activityId == updatedData.activityId);

      if (dataIndex != -1) {
        oldGroup = shortedData;
        oldGroupIndex = i;
        oldDataIndex = dataIndex;
        break;
      }
    }

    if (oldGroup != null && oldGroupIndex != -1 && oldDataIndex != -1) {
      if (oldGroup.date != updatedData.eventDate) {
        oldGroup.data.removeAt(oldDataIndex);

        if (oldGroup.data.isEmpty) {
          scheduleController.sortedScheduleList.removeAt(oldGroupIndex);
        }

        int newGroupIndex = scheduleController.sortedScheduleList.indexWhere((e) => e.date == updatedData.eventDate);

        if (newGroupIndex != -1) {
          scheduleController.sortedScheduleList[newGroupIndex].data.add(updatedData);
        } else {
          scheduleController.sortedScheduleList.add(ShortedData(date: updatedData.eventDate ?? "", data: [updatedData]));
        }
      } else {
        oldGroup.data[oldDataIndex] = updatedData;
      }
    }

    scheduleController.sortedScheduleList.refresh();
  }
}
