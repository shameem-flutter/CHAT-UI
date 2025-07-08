import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();

  void sendMessage() {
    final user = FirebaseAuth.instance.currentUser;
    final message = messageController.text.trim();
    if (message.isNotEmpty && user != null) {
      FirebaseFirestore.instance.collection('messages').add({
        'text': message,
        'userEmail': user.email,
        'userName': user.displayName ?? user.email!.split('@')[0],
        'timeStamp': FieldValue.serverTimestamp(),
      });
      messageController.clear();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Widget buildMessageBubble(Map<String, dynamic> msg, bool isme) {
    final timestamp = (msg['timeStamp'] as Timestamp?)?.toDate();
    final timeString = timestamp != null
        ? DateFormat('hh:mm a').format(timestamp)
        : '';
    return Align(
      alignment: isme ? Alignment.centerRight : Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isme ? Colors.blueAccent : Colors.blueGrey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(isme ? 16 : 0),
            bottomRight: Radius.circular(isme ? 0 : 16),
          ),
        ),
        child: Column(
          children: [
            Text(
              msg['userName'] ?? 'User',
              style: TextStyle(
                color: isme ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 04),
            Text(
              msg['text'] ?? '',
              style: TextStyle(
                fontSize: 16,
                color: isme ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 04),
            Text(
              timeString,
              style: TextStyle(
                fontSize: 10,
                color: isme ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timeStamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['userEmail'] == user?.email;
                    return buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 08),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    onPressed: sendMessage,
                    icon: Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
