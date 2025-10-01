import 'package:base_code/package/config_packages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../res/color_schema.dart';

class WebViewScreen extends StatefulWidget {

  const WebViewScreen({super.key});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? webViewController;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    String? title = args?['title']??"";
    String? url = args?['url']??"";
    return Scaffold(
      appBar: AppBar(title: Text(title??'Teamates'),),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(url??"")),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true; // Show loader when page starts loading
              });
              print("Started loading: $url");
            },
            onLoadStop: (controller, url) async {
              setState(() {
                _isLoading = false;

              });
              print("Finished loading: $url");
            },
            onLoadError: (controller, url, code, message) {
              setState(() {
                _isLoading = false;

              });
              print("Error: $message");
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColor.black12Color,
              ),
            ),

        ],
      ),
    );
  }
}
