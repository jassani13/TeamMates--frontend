// import 'package:base_code/module/bottom/home/search/search_controller.dart';
// import 'package:base_code/package/config_packages.dart';
// import 'package:base_code/package/screen_packages.dart';
//
// class SearchScreen extends StatelessWidget {
//   SearchScreen({super.key});
//
//   final searchController =
//       Get.put<SearchScreenController>(SearchScreenController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Column(
//         children: [
//           buildSearchMethod(),
//           Gap(24),
//           Expanded(
//             child: Obx(
//               () => searchController.selectedSearchMethod.value == 0
//                   ? ListView.builder(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: 20,
//                       shrinkWrap: true,
//                       itemBuilder: (context, index) {
//                         return Container(
//                           padding: EdgeInsets.only(
//                             bottom: 14,
//                             top: 14,
//                           ),
//                           decoration: BoxDecoration(
//                             border: index == 0
//                                 ? null
//                                 : Border(
//                                     top: BorderSide(
//                                       color: AppColor.greyF6Color,
//                                     ),
//                                   ),
//                           ),
//                           child: Row(
//                             children: [
//                               SvgPicture.asset(
//                                 AppImage.pin,
//                               ),
//                               Gap(16),
//                               Expanded(
//                                 child: Text(
//                                   "Silverstone International Sports Complex",
//                                   style: TextStyle().normal16w500.textColor(
//                                         AppColor.black12Color,
//                                       ),
//                                 ),
//                               )
//                             ],
//                           ),
//                         );
//                       })
//                   : (searchController.selectedSearchMethod.value == 1 ||
//                           searchController.selectedSearchMethod.value == 3)
//                       ? ListView.builder(
//                           padding: EdgeInsets.symmetric(horizontal: 16),
//                           itemCount: 20,
//                           shrinkWrap: true,
//                           itemBuilder: (context, index) {
//                             return Container(
//                               padding: EdgeInsets.only(
//                                 bottom: 14,
//                                 top: 14,
//                               ),
//                               decoration: BoxDecoration(
//                                 border: index == 0
//                                     ? null
//                                     : Border(
//                                         top: BorderSide(
//                                           color: AppColor.greyF6Color,
//                                         ),
//                                       ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   SvgPicture.asset(
//                                     AppImage.teamFrame,
//                                   ),
//                                   Gap(16),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         searchController.selectedSearchMethod
//                                                     .value ==
//                                                 3
//                                             ? "Vibhuti"
//                                             : "Game vs Tigers",
//                                         style:
//                                             TextStyle().normal16w500.textColor(
//                                                   AppColor.black12Color,
//                                                 ),
//                                       ),
//                                       if (searchController
//                                               .selectedSearchMethod.value ==
//                                           3)
//                                         Text(
//                                           "12 / 8",
//                                           style: TextStyle()
//                                               .normal14w500
//                                               .textColor(
//                                                 AppColor.grey4EColor,
//                                               ),
//                                         ),
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             );
//                           })
//                       : ListView.builder(
//                           padding: EdgeInsets.symmetric(horizontal: 16),
//                           itemCount: 20,
//                           shrinkWrap: true,
//                           itemBuilder: (context, index) {
//                             return Container(
//                               padding: EdgeInsets.only(
//                                 bottom: 14,
//                                 top: 14,
//                               ),
//                               decoration: BoxDecoration(
//                                 border: index == 0
//                                     ? null
//                                     : Border(
//                                         top: BorderSide(
//                                           color: AppColor.greyF6Color,
//                                         ),
//                                       ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   SvgPicture.asset(
//                                     AppImage.ball,
//                                     height: 48,
//                                   ),
//                                   Gap(16),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Football",
//                                         style:
//                                             TextStyle().normal16w500.textColor(
//                                                   AppColor.black12Color,
//                                                 ),
//                                       ),
//                                       Text(
//                                         "09:00 am - 11:pm -  Friday -  Feb 10, 2025",
//                                         style:
//                                             TextStyle().normal14w500.textColor(
//                                                   AppColor.grey4EColor,
//                                                 ),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             );
//                           }),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   SizedBox buildSearchMethod() {
//     return SizedBox(
//       height: 78,
//       child: Obx(
//         () => ListView.builder(
//             controller: searchController.controller,
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             itemCount: searchController.searchList.length,
//             shrinkWrap: true,
//             scrollDirection: Axis.horizontal,
//             itemBuilder: (context, index) {
//               return AutoScrollTag(
//                 controller: searchController.controller,
//                 index: index,
//                 key: ValueKey(index),
//                 child: GestureDetector(
//                   onTap: () {
//                     searchController.selectedSearchMethod.value = index;
//                     searchController.controller.scrollToIndex(index,
//                         preferPosition: AutoScrollPosition.middle);
//                   },
//                   behavior: HitTestBehavior.translucent,
//                   child: Obx(
//                     () => Container(
//                       margin: EdgeInsets.only(left: index == 0 ? 0 : 16),
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                       decoration: BoxDecoration(
//                           color: index ==
//                                   searchController.selectedSearchMethod.value
//                               ? AppColor.black12Color
//                               : AppColor.white,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                               color: index ==
//                                       searchController
//                                           .selectedSearchMethod.value
//                                   ? AppColor.black12Color
//                                   : AppColor.greyEAColor)),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SvgPicture.asset(
//                             searchController.searchList[index].image,
//                             colorFilter: ColorFilter.mode(
//                                 searchController.selectedSearchMethod.value ==
//                                         index
//                                     ? AppColor.white
//                                     : AppColor.black12Color,
//                                 BlendMode.srcIn),
//                           ),
//                           Gap(8),
//                           Text(
//                             searchController.searchList[index].value,
//                             style: TextStyle()
//                                 .textColor(
//                                   searchController.selectedSearchMethod.value ==
//                                           index
//                                       ? AppColor.white
//                                       : AppColor.black12Color,
//                                 )
//                                 .normal14w500,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//       ),
//     );
//   }
// }
