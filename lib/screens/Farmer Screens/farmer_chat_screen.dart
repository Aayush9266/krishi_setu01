import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';


class FChatScreen extends StatefulWidget {
  FChatScreen(
      {Key? key,
        required this.userdata,
        required this.RoomId,
        required this.buyer

      })
      : super(key: key);
  final Map<String, dynamic> userdata;
  String buyer;

  String RoomId;


  static const String id = 'chat_screen';
  @override
  _FChatScreenState createState() => _FChatScreenState();
}

class _FChatScreenState extends State<FChatScreen> {
  final messageEditingController = TextEditingController();

  late String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: null,

          title: Text(widget.buyer + "'s Chat Room" ,style: TextStyle(color: Colors.white),),
          centerTitle: true,
          //backgroundColor: Colors.lightBlueAccent,
          backgroundColor: Colors.green
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.RoomId)
                    .collection('chatroom')
                    .orderBy('timeStamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return ListView();
                  }

                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageData =
                      messages[index].data() as Map<String, dynamic>;
                      final messageText = messageData['message'] ?? '';
                      final messageSender = messageData['sender'] ?? 'Unknown';
                      final messageTimestamp =
                      messageData['timeStamp'] as Timestamp;
                      final messageTime = messageTimestamp.toDate();
                      final currentUserUid = widget.userdata['uid'];
                      final messageWidget = MessageBox(
                        text: messageText,
                        sender: messageSender,
                        isMe: messageData['uid'] == currentUserUid,
                        time: "${messageTime.hour}:${messageTime.minute}",
                      );

                      return messageWidget;
                    },
                  );
                },
              ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageEditingController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (messageEditingController.text.isEmpty) {
                        return;
                      }

                      String message = messageEditingController.text;
                      messageEditingController.clear();
                      final now = DateTime.now();
                      Map<String, dynamic> data = {
                        'type': 'iSentMessage',
                        'message': message,
                        'timeStamp': now,
                        'uid': widget.userdata['uid'],
                        'sender': widget.userdata['name'],
                      };
                      await FirebaseFirestore.instance.collection('chats').doc(widget.RoomId).collection('chatroom').add(data!);


                      // GetServerKey g = GetServerKey();
                      // String ServerKey =await  g.getServerKeyToken();
                      // print(ServerKey);
                      // sendNotification(widget.RoomId +  widget.userdata['name'] + message , widget.fcms);
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBox extends StatelessWidget {
  MessageBox(
      {required this.text,
        required this.sender,
        required this.isMe,
        required this.time,

      });
  final String text;
  final String sender;
  final String time;
  final bool isMe;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: 2 * (MediaQuery.of(context).size.width / 3),
            child: Card(
              shape: isMe
                  ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)))
                  : RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              color: isMe ? Colors.green : Colors.white,
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Align(
                      alignment: FractionalOffset.bottomLeft,
                      child: Text(
                        sender,
                        style: TextStyle(color: Colors.black54, fontSize: 9),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        text,
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                    Align(
                      alignment: FractionalOffset.bottomRight,
                      child: Text(
                        time,
                        style: TextStyle(color: Colors.black54, fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
