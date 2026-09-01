// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:opration/core/services/cache_helper/cache_helper.dart';

// class CloudSyncService {
//   static CollectionReference<Map<String, dynamic>> get _collection =>
//       FirebaseFirestore.instance.collection('users_sync');

//   static const String _updatedAtKey = 'local_last_updated_at';

//   static Future<void> touchLocalUpdate() async {
//     final now = DateTime.now().millisecondsSinceEpoch;
//     await CacheHelper.saveData(key: _updatedAtKey, value: now);
//   }

//   static Future<int> getLocalUpdatedAt() async {
//     final data = await CacheHelper.getData(_updatedAtKey);
//     return data != null ? (data as int) : 0;
//   }

//   static Future<void> smartSync({required String uid}) async {
//     try {
//       final snap = await _collection.doc(uid).get();
//       final localUpdateMillis = await getLocalUpdatedAt();

//       if (!snap.exists || snap.data() == null) {
//         await pushAllData(uid: uid);
//         return;
//       }

//       final cloudData = snap.data()!;
//       final cloudUpdateMillis = cloudData['updatedAt'] as int? ?? 0;

//       if (cloudUpdateMillis > localUpdateMillis) {
//         await pullAllData(uid: uid);
//       } else if (localUpdateMillis > cloudUpdateMillis) {
//         await pushAllData(uid: uid);
//       }
//     } catch (e) {
//       // Handle errors if necessary, e.g., log them.
//     }
//   }

//   static Future<void> pushAllData({required String uid}) async {
//     final localData = await CacheHelper.getAllData();

//     localData.remove(_updatedAtKey);

//     final normalized = _normalizeForFirestore(localData);

//     var currentLocalTime = await getLocalUpdatedAt();
//     if (currentLocalTime == 0) {
//       currentLocalTime = DateTime.now().millisecondsSinceEpoch;
//       await CacheHelper.saveData(key: _updatedAtKey, value: currentLocalTime);
//     }

//     await _collection.doc(uid).set({
//       'payload': normalized,
//       'updatedAt': currentLocalTime,
//       'schemaVersion': 1,
//     }, SetOptions(merge: true));
//   }

//   static Future<bool> pullAllData({required String uid}) async {
//     final snap = await _collection.doc(uid).get();
//     final data = snap.data();
//     if (data == null || data['payload'] == null) return false;

//     final payload = Map<String, dynamic>.from(data['payload'] as Map);
//     final cloudUpdateMillis =
//         data['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch;

//     await CacheHelper.runWithSuppressedNotifications(() async {
//       for (final entry in payload.entries) {
//         await _saveSupportedValue(entry.key, entry.value);
//       }

//       await CacheHelper.saveData(key: _updatedAtKey, value: cloudUpdateMillis);
//     });
//     return true;
//   }

//   static Future<bool> bootstrapSync({required String uid}) async {
//     final hasCloudData = await pullAllData(uid: uid);
//     if (!hasCloudData) {
//       await pushAllData(uid: uid);
//       return false;
//     }
//     return true;
//   }

//   static Map<String, dynamic> _normalizeForFirestore(
//     Map<String, dynamic> data,
//   ) {
//     final out = <String, dynamic>{};
//     for (final entry in data.entries) {
//       final key = entry.key;
//       final value = entry.value;
//       if (value is String || value is num || value is bool) {
//         out[key] = value;
//       } else if (value is List<String>) {
//         out[key] = value;
//       } else {
//         out[key] = jsonEncode(value);
//       }
//     }
//     return out;
//   }

//   static Future<void> _saveSupportedValue(String key, dynamic value) async {
//     if (value is String || value is int || value is bool || value is double) {
//       await CacheHelper.saveData(key: key, value: value);
//       return;
//     }
//     if (value is List) {
//       final asStringList = value.map((e) => e.toString()).toList();
//       await CacheHelper.saveData(key: key, value: asStringList);
//       return;
//     }
//     await CacheHelper.saveData(key: key, value: jsonEncode(value));
//   }

//   static Future<void> deleteCloudData({required String uid}) async {
//     await _collection.doc(uid).delete();
//   }
// }
