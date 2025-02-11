import 'package:cipher/helper/encryption.dart';
import 'package:cipher/models/chat_user.dart';
import 'package:cipher/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for storing self info
  static late ChatUser me;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static User get user => auth.currentUser!;

  // for checking user exists or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      image: user.photoURL.toString(),
      about: 'Hey there! I am using Cipher',
      createdAt: time,
      lastActive: time,
      isOnline: false,
      pushToken: '',
    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting all users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // Update user info except for image
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // Update user image in Firebase Firestore
  static Future<void> updateUserImage(String imageUrl) async {
    try {
      await firestore.collection('users').doc(user.uid).update({
        'image': imageUrl,
      });
    } catch (e) {
      print('Error updating user image: $e');
    }
  }

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // Send encrypted message
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final encryptedMsg = EncryptionUtil.encrypt(msg); // Encrypt message

    final Message message = Message(
      toId: chatUser.id,
      fromId: user.uid,
      msg: encryptedMsg, // Store encrypted message
      type: Type.text,
      read: '',
      sent: time,
    );
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().microsecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  static Future<void> deleteMessage(Message message) async {
    final messageRef = firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent);

    if (message.type == 'image') {
      await _deleteFromCloudinary(message.msg);
    }

    await messageRef.delete();
  }

  static Future<void> _deleteFromCloudinary(String imageUrl) async {
    final cloudinaryDeleteUrl =
        'https://api.cloudinary.com/v1_1/dshlsnsyt/delete_by_token';

    final response = await http.post(
      Uri.parse(cloudinaryDeleteUrl),
      body: {
        'token': imageUrl
      }, // Assuming Cloudinary allows deletion via token
    );

    if (response.statusCode == 200) {
      print('Image deleted from Cloudinary');
    } else {
      print('Failed to delete image from Cloudinary');
    }
  }

  // Store encrypted image URL from Cloudinary to Firebase based on conversation ID
  static Future<void> sendImageMessage(
      ChatUser chatUser, String imageUrl) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final encryptedUrl = EncryptionUtil.encrypt(imageUrl); // Encrypt image URL

    final Message message = Message(
      toId: chatUser.id,
      fromId: user.uid,
      msg: encryptedUrl, // Store encrypted image URL
      type: Type.image,
      read: '',
      sent: time,
    );
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }
}
