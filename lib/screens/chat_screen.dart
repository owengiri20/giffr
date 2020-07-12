import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    print("222");
    print(loggedInUser);
    print(_firestore.app);
  }

  void getCurrentUser() async {
    try {
      final currentUser = await _auth.currentUser();
      if (currentUser != null) {
        loggedInUser = currentUser;
      }

      print(loggedInUser.email);
    } catch (e) {
      print(e);
    }
  }

  void getMessages() async {
    final messages = await _firestore.collection("messages").getDocuments();
    for (var message in messages.documents) {
      print(message.data);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection("messages").snapshots()) {
      for (var message in snapshot.documents) {
        print(message.data);
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                getCurrentUser();
                //Implement logout functionality
//                _auth.signOut();
//                Navigator.pop(context);
//                messagesStream();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      print(_firestore.app.name);
                      _firestore
                          .collection("messages")
                          .getDocuments()
                          .then((value) => print(value));
                      //Implement send functionality.
                      _firestore.collection('messages').add({
                        "createdAt": new DateTime.now(),
                        "text": messageText,
                        "sender": loggedInUser.email,
                      });
                      messageTextController.clear();
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

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("messages").orderBy("createdAt").snapshots(),
      builder: (context, snapshot) {
        List<Widget> messageBubbles = [];

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final messages = snapshot.data.documents.reversed;
        for (var message in messages) {
          final messageText = message.data["text"];
          final messageSender = message.data["sender"];

//            print(loggedInUser);
          final currentUser = loggedInUser.email;

          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});
  final String sender;
  final String text;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              sender,
              style: TextStyle(color: Colors.black54),
            ),
            Material(
                borderRadius: BorderRadius.only(
                    topLeft: isMe ?  Radius.circular(0) : Radius.circular(30) ,
                    bottomLeft: isMe ? Radius.circular(30):  Radius.circular(30),
                    bottomRight: isMe? Radius.circular(30) : Radius.circular(30),
                  topRight: isMe? Radius.circular(30) : Radius.circular(0),
                ),

                elevation: 7,
                color: isMe ? Colors.white:  Colors.blueAccent,
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    child: Text(
                      "$text",
                      style: TextStyle(color: isMe ? Colors.black87:  Colors.white, fontSize: 15),
                    )))
          ],
        ));
  }
}
