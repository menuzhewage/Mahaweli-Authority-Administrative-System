import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mahaweli_admin_system/services/resource_mapping/data/models/resource.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference resourceCollection =
      FirebaseFirestore.instance.collection('resources');

  Future<DocumentReference<Object?>> addResource(Resource resource) async {
    return await resourceCollection.add(resource.toMap());
  }

  Future<void> updateResource(Resource resource) async {
    return await resourceCollection.doc(resource.id).update(resource.toMap());
  }

  Future<void> deleteResource(String id) async {
    return await resourceCollection.doc(id).delete();
  }

  Stream<List<Resource>> get resources {
    return resourceCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Resource.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<List<Resource>> getAllResources() async {
    QuerySnapshot snapshot = await resourceCollection.get();
    return snapshot.docs
        .map((doc) => Resource.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}