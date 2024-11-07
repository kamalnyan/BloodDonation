

import 'dart:developer';

import 'package:brg_donation/Apis/loginApis.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'PushNotifaction.dart';

Future<List<String>> fetchPushTokensExceptMe() async {
  // Get the current user's UID
  String currentUserId = OrganLS.me.id;
    log(OrganLS.me.id);
  // Query to fetch all users except the current user
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('Users')
      .where(FieldPath.documentId, isNotEqualTo: currentUserId)
      .get();
  List<String> pushTokens = [];
  for (var doc in querySnapshot.docs) {
    if (doc.data() != null) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('pushToken')) {
        pushTokens.add(data['pushToken']);
      }
    }
  }

  return pushTokens;
}
Future<void> sendNotificationToAllUsers(String organName, bool isForRequirement , String titleName) async {
  List<String> allPushTokens = await fetchPushTokensExceptMe();
  Set<String> uniquePushTokens = allPushTokens.toSet();
  String myName = OrganLS.me.name;
  String title;
  String message;
  if (isForRequirement) {
    title = "Urgent $titleName Requirement!";
    message = "$myName urgently needs $organName. Please help if you can!";
  } else {
    title = "$titleName Availability Alert!";
    message = "$organName is now available. Check it out, brought to you by $myName.";
  }
  for (String token in uniquePushTokens) {
    await FCMService.sendPushNotification(token, title, message);
  }
}

