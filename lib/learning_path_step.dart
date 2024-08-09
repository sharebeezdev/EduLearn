import 'package:edu_learn/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LearningPathStepPage extends StatefulWidget {
  final String url;

  LearningPathStepPage({Key? key, required this.url}) : super(key: key);

  @override
  _LearningPathStepPageState createState() => _LearningPathStepPageState();
}

class _LearningPathStepPageState extends State<LearningPathStepPage> {
  late InAppWebViewController _webViewController;
  final GlobalKey webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Learning Path'),
      body: InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(
          url: WebUri(widget.url),
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
          _initializeJavaScriptHandler();
        },
        onLoadStop: (controller, url) {
          _webViewController.evaluateJavascript(source: '''
            document.addEventListener('selectionchange', function() {
              var selectedText = window.getSelection().toString();
              if (selectedText) {
                window.flutter_inappwebview.callHandler('handleSelection', selectedText);
              }
            });
          ''');
        },
      ),
    );
  }

  void _initializeJavaScriptHandler() {
    _webViewController.addJavaScriptHandler(
      handlerName: 'handleSelection',
      callback: (args) {
        String selectedText = args[0];
        _showSelectionOptions(selectedText);
      },
    );
  }

  void _showSelectionOptions(String selectedText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selected Text'),
          content: Text(selectedText),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle "Learn More" action here
              },
              child: Text('Learn More'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
