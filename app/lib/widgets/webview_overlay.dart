import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../theme/app_theme.dart';

/// Reusable in-app browser overlay for external content
/// Shows web pages (FlightAware, Heavens-Above, MUFON) without leaving the app
class WebViewOverlay extends StatefulWidget {
  final String url;
  final String title;

  const WebViewOverlay({
    super.key,
    required this.url,
    this.title = 'Loading...',
  });

  @override
  State<WebViewOverlay> createState() => _WebViewOverlayState();

  /// Static helper to show the overlay
  static Future<void> show(BuildContext context, String url, {String? title}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => WebViewOverlay(
          url: url,
          title: title ?? 'Loading...',
        ),
      ),
    );
  }
}

class _WebViewOverlayState extends State<WebViewOverlay> {
  InAppWebViewController? _webViewController;
  double _progress = 0;
  String _currentTitle = '';

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _currentTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () => _webViewController?.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          if (_progress < 1.0)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppColors.darkSurface,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
            ),
          // WebView
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                supportZoom: true,
                builtInZoomControls: true,
                displayZoomControls: false,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _progress = 0;
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
              onLoadStop: (controller, url) async {
                setState(() {
                  _progress = 1.0;
                });
                // Update title from page
                final title = await controller.getTitle();
                if (title != null && title.isNotEmpty) {
                  setState(() {
                    _currentTitle = title;
                  });
                }
              },
              onLoadError: (controller, url, code, message) {
                setState(() {
                  _progress = 1.0;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
