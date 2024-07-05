import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';
  final String chatName;
  final String bidPrice;
  final String image;
  final WebSocketChannel channel;

  ChatScreen({
    required this.chatName,
    required this.bidPrice,
    required this.image,
    required this.channel,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<String> _messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.channel.stream.listen((message) {
      setState(() {
        _messages.add(message);
      });
    });
  }

  @override
  void dispose() {
    widget.channel.sink.close(status.goingAway);
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) {
      return;
    }
    widget.channel.sink.add(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(widget.image),
            ),
            SizedBox(width: 5),
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(widget.image),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.chatName),
                Text(
                  '낙찰가 : '+widget.bidPrice,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  print('Styled Text Button Pressed');
                },
                child: Text('거래완료'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  textStyle: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}