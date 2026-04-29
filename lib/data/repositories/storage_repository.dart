// lib/data/repositories/storage_repository.dart

import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class StorageRepository {
  final FirebaseFirestore _db;
  StorageRepository(this._db);

  Future<String> uploadProfilePhoto({
    required String uid,
    required File file,
  }) async {
    // Compress to keep well under Firestore's 1MB doc limit
    final compressed = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 256,
      minHeight: 256,
      quality: 70,
      format: CompressFormat.jpeg,
    );
    if (compressed == null) throw Exception('Image compression failed');

    final base64Str = base64Encode(compressed);
    // Store as a data URI so Image.memory / Image.network both work
    final dataUri = 'data:image/jpeg;base64,$base64Str';

    await _db.collection('users').doc(uid).update({
      'personal.photoUrl': dataUri,
      'meta.updatedAt': FieldValue.serverTimestamp(),
    });

    return dataUri;
  }

  Future<void> deleteProfilePhoto(String uid) async {
    await _db.collection('users').doc(uid).update({
      'personal.photoUrl': FieldValue.delete(),
      'meta.updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(FirebaseFirestore.instance);
});
