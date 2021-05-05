import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentState = "ledOff";
  IconData _currentIcon = Icons.flash_off;
  Color _currentColor = Colors.red;
  WebSocketChannel channel =
      IOWebSocketChannel.connect('wss://remote-control.stevezheng.cf');

  void _sendMessage(String message) {
    channel.sink.add(message);
  }

  @override
  void initState() {
    channel.sink.add("queryState");
    new Timer.periodic(
        Duration(seconds: 20), (timer) => _sendMessage("queryState"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Remote Control"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 24.0,
            ),
            Text("LED State:"),
            Container(
              height: 24.0,
            ),
            StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != _currentState) {
                  _currentState = snapshot.data;
                  _currentColor = snapshot.data == "ledOn"
                      ? Colors.greenAccent
                      : Colors.deepOrangeAccent;
                  _currentIcon = snapshot.data == "ledOn"
                      ? Icons.flash_on
                      : Icons.flash_off;
                }
                return Column(
                  children: [
                    Text(snapshot.data == "ledOn" ? "On" : "Off"),
                    Container(
                      height: 16.0,
                    ),
                    Container(
                      child: TextButton.icon(
                        onPressed: () {
                          if (_currentState == "ledOff") {
                            _sendMessage("ledOn");
                          } else {
                            _sendMessage("ledOff");
                          }
                        },
                        icon: Icon(
                          _currentIcon,
                          color: Colors.white,
                        ),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                _currentColor)),
                        label: Text(
                            _currentState == "ledOff" ? "Turn ON" : "Turn OFF"),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close(goingAway);
    super.dispose();
  }
}
