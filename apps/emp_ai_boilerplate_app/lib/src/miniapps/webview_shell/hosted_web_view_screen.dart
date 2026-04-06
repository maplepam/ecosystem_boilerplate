import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Full-screen WebView for [HostedWebMiniApp]. No partner business logic here.
///
/// **Production:** restrict [uri] (HTTPS allow-list, SSO cookies, headers) — **REPLACE**
/// in your security review; this is a minimal shell.
class HostedWebViewScreen extends StatefulWidget {
  const HostedWebViewScreen({super.key, required this.uri});

  final Uri uri;

  @override
  State<HostedWebViewScreen> createState() => _HostedWebViewScreenState();
}

class _HostedWebViewScreenState extends State<HostedWebViewScreen> {
  late final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(widget.uri);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
