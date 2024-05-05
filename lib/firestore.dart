
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //get collection
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  //Create: Adding a user to userList
  Future<void> addUser(List userCreds, marketPresence) {
    return users.add({
      'name': userCreds[0],
      'phone': userCreds[1],
      'marketpresence': marketPresence,
      'timestamp': Timestamp.now(),
    });
  }

  //Read: Getting all of userList
  Stream<QuerySnapshot> getUserStream() {
    final userStream = users.orderBy('timestamp', descending: true).snapshots();
    return userStream;
  }

  //Update: Altering the true/false value

  //Delete: Removing a user
}