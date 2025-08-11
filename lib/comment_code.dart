
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   final splashController = Get.put<SplashController>(SplashController());
//
//   late AnimationController _controller;
//   late Animation<Offset> _animation1;
//   late Animation<Offset> _animation2;
//   bool isMiddle = true;
//   bool isStop = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     );
//
//     _animation1 = Tween<Offset>(
//       begin: const Offset(0, 2),
//       end: const Offset(0, 0),
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//
//     _animation2 = Tween<Offset>(
//       begin: const Offset(0, 0),
//       end: const Offset(2, 0),
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//
//     _controller.forward();
//
//     _controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed && isMiddle) {
//         isMiddle = false;
//         isStop = true;
//         setState(() {});
//         Future.delayed(const Duration(seconds: 1), () {
//           isStop = false;
//           setState(() {});
//           _controller.reset();
//           _controller.forward();
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           SvgPicture.asset(
//             AppImage.splashBg,
//             height: double.infinity,
//             width: double.infinity,
//             fit: BoxFit.cover,
//           ),
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.only(top:isStop? 50:0,bottom:isStop? 0: 100),
//                   child: Text(
//                     "TeamMates",
//                     style:
//                         TextStyle().normal36w600.textColor(AppColor.black12Color),
//                   ),
//                 ),
//                 Gap(20),
//                 if (isStop)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 100.0),
//                     child: SvgPicture.asset(
//                       AppImage.ball,
//                       height: 50,
//                       width: 50,
//                     ),
//                   ),
//                 AnimatedBuilder(
//                   animation: _controller,
//                   builder: (context, child) {
//                     Offset offset =
//                         isMiddle ? _animation1.value : _animation2.value;
//                     return Transform.translate(
//                       offset: Offset(
//                           offset.dx * MediaQuery.of(context).size.width / 2,
//                           offset.dy * MediaQuery.of(context).size.height / 3-100),
//                       child: SvgPicture.asset(
//                         AppImage.ball,
//                         height: 50,
//                         width: 50,
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Future<void> checkUserApiCall() async {
//   try {
//     var data = d.FormData.fromMap({
//       "email": emailController.text.toString(),
//     });
//     var res = await callApi(
//       dio.post(
//         ApiEndPoint.checkUser,
//         data: data,
//       ),
//       true,
//     );
//     if (res != null) {
//       await registerApiCall();
//     }
//   } catch (e) {
//     if (kDebugMode) {
//       print(e);
//     }
//   }
// }


// Container(
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(
//       8,
//     ),
//     border: Border.all(color: AppColor.greyEAColor),
//   ),
//   child: Column(
//     children: [
//       Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//             color: AppColor.redColor,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(8),
//               topRight: Radius.circular(8),
//             )),
//         child: Text(
//           "Emergency contact",
//           style: TextStyle().normal16w500.textColor(
//                 AppColor.white,
//               ),
//         ),
//       ),
//       Container(
//         margin: EdgeInsets.all(16),
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(color: AppColor.greyF6Color, borderRadius: BorderRadius.circular(8)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   "Mobile number",
//                   style: TextStyle().normal14w500.textColor(
//                         AppColor.grey4EColor,
//                       ),
//                 ),
//               ],
//             ),
//             Obx(() {
//               return Visibility(
//                 visible: profileController.isEdit.value,
//                 child: Column(
//                   children: [
//                     Gap(10),
//                     CommonTextField(
//                       bgColor: AppColor.white,
//                       controller: profileController.eMobileController,
//                       validator: (val) {
//                         if ((val ?? "").isEmpty) {
//                           return "Please enter emergency mobile number";
//                         } else if (!((val ?? "").isPhoneNumber)) {
//                           return "Please enter valid emergency mobile number";
//                         }
//                         return null;
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             }),
//             Obx(() {
//               return Visibility(
//                 visible: !profileController.isEdit.value,
//                 child: Text(
//                   profileController.eMobileController.text.isNotEmpty ? profileController.eMobileController.text : "-",
//                   style: TextStyle().normal16w500.textColor(
//                         AppColor.redColor,
//                       ),
//                 ),
//               );
//             }),
//             Gap(16),
//             Text(
//               "Gmail",
//               style: TextStyle().normal14w500.textColor(
//                     AppColor.grey4EColor,
//                   ),
//             ),
//             Obx(() {
//               return Visibility(
//                 visible: profileController.isEdit.value,
//                 child: Column(
//                   children: [
//                     Gap(10),
//                     CommonTextField(
//                       bgColor: AppColor.white,
//                       controller: profileController.eMAilController,
//                       validator: (val) {
//                         if ((val ?? "").isEmpty) {
//                           return "Please enter emergency email";
//                         } else if (!((val ?? "").isEmail)) {
//                           return "Please enter valid emergency email";
//                         }
//                         return null;
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             }),
//             Obx(() {
//               return Visibility(
//                 visible: !profileController.isEdit.value,
//                 child: Text(
//                   profileController.eMAilController.text.isNotEmpty ? profileController.eMAilController.text : "-",
//                   style: TextStyle().normal16w500.textColor(
//                         AppColor.redColor,
//                       ),
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     ],
//   ),
// ),
// Gap(20),
