import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Kullanıcı profil modeli
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Kullanıcı kayıt olma
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    required int age,
    required String country,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı profil bilgilerini Firestore'a kaydet
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'gender': gender,
        'age': age,
        'country': country,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      debugPrint('Kayıt hatası: $e');
      rethrow;
    }
  }

  // Kullanıcı giriş yapma
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Giriş hatası: $e');
      rethrow;
    }
  }

  // Çıkış yapma
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Kullanıcı profil bilgilerini getirme
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Profil getirme hatası: $e');
      return null;
    }
  }

  // Kullanıcı profil bilgilerini güncelleme
  Future<void> updateUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? gender,
    int? age,
    String? country,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (gender != null) updateData['gender'] = gender;
      if (age != null) updateData['age'] = age;
      if (country != null) updateData['country'] = country;

      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      debugPrint('Profil güncelleme hatası: $e');
      rethrow;
    }
  }

  // Profil fotoğrafı yükleme
  Future<String?> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      String fileName = 'profile_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Firestore'da profil URL'ini güncelle
      await _firestore.collection('users').doc(userId).update({
        'profilePhotoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Fotoğraf yükleme hatası: $e');
      return null;
    }
  }

  // Belge yükleme
  Future<String?> uploadDocument({
    required String userId,
    required File documentFile,
    required String documentName,
    required String documentType,
  }) async {
    try {
      String fileName = 'documents/$userId/${DateTime.now().millisecondsSinceEpoch}_$documentName';
      Reference ref = _storage.ref().child(fileName);
      
      UploadTask uploadTask = ref.putFile(documentFile);
      TaskSnapshot snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Firestore'da belge bilgilerini kaydet
      await _firestore.collection('users').doc(userId).collection('documents').add({
        'name': documentName,
        'type': documentType,
        'url': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
        'fileSize': await documentFile.length(),
      });
      
      return downloadUrl;
    } catch (e) {
      debugPrint('Belge yükleme hatası: $e');
      return null;
    }
  }

  // Kullanıcının belgelerini getirme
  Future<List<Map<String, dynamic>>> getUserDocuments(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .orderBy('uploadedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Belge getirme hatası: $e');
      return [];
    }
  }

  // Belge silme
  Future<void> deleteDocument(String userId, String documentId) async {
    try {
      // Firestore'dan belge bilgisini al
      DocumentSnapshot docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .doc(documentId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        String? fileUrl = data['url'];

        // Storage'dan dosyayı sil
        if (fileUrl != null) {
          Reference ref = _storage.refFromURL(fileUrl);
          await ref.delete();
        }

        // Firestore'dan belge kaydını sil
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('documents')
            .doc(documentId)
            .delete();
      }
    } catch (e) {
      debugPrint('Belge silme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcı verilerini dinleme (real-time updates)
  Stream<Map<String, dynamic>?> getUserProfileStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    });
  }

  // Kullanıcı belgelerini dinleme (real-time updates)
  Stream<List<Map<String, dynamic>>> getUserDocumentsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('documents')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
} 