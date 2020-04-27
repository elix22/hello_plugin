import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hello_plugin/hello_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  final _controller = new HelloPlugin();
  final _width = 200.0;
  final _height = 200.0;

  @override
  void initState() {
    super.initState();
    initializeController();
  //  initPlatformState();
  }
  
  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await HelloPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('OpenGL via Texture widget example'),
        ),
        body: new Center(
          child: new Container(
            width: _width,
            height: _height,
            child: _controller.isInitialized
                ? new Texture(textureId: _controller.textureId)
                : null,
          ),
        ),
      ),
    );
  }

  Future<Null> initializeController() async {
    await _controller.initialize(_width, _height);
    setState(() {});
  }
}
