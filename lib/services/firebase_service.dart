import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

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
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

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
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
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
      String fileName =
          'profile_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
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
      debugPrint('Dosya yükleme başlatılıyor...');
      debugPrint('Kullanıcı ID: $userId');
      debugPrint('Dosya adı: $documentName');
      debugPrint('Dosya tipi: $documentType');
      debugPrint('Dosya boyutu: ${await documentFile.length()} bytes');

      // Dosyanın var olup olmadığını kontrol et
      if (!await documentFile.exists()) {
        debugPrint('HATA: Dosya bulunamadı: ${documentFile.path}');
        return null;
      }

      // Dosya boyutunu kontrol et (10MB limit)
      int fileSize = await documentFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        debugPrint('HATA: Dosya boyutu çok büyük: ${fileSize} bytes');
        return null;
      }

      // Firebase Storage bağlantısını test et
      debugPrint('Firebase Storage bağlantısı test ediliyor...');
      bool storageAvailable = false;

      try {
        // Önce Storage referansını test et
        Reference storageRef = _storage.ref();
        debugPrint('Storage referansı oluşturuldu');

        String testFileName =
            'test_${DateTime.now().millisecondsSinceEpoch}.txt';
        Reference testRef = storageRef.child('test/$userId/$testFileName');
        debugPrint(
          'Test dosyası referansı oluşturuldu: test/$userId/$testFileName',
        );

        String testContent = 'Test dosyası - ${DateTime.now()}';
        Uint8List testBytes = Uint8List.fromList(testContent.codeUnits);
        debugPrint('Test dosyası hazırlandı: ${testBytes.length} bytes');

        // Upload task'ı başlat
        UploadTask testTask = testRef.putData(testBytes);
        debugPrint('Test upload task başlatıldı');

        // Progress'i dinle
        testTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          debugPrint(
            'Test upload progress: ${(progress * 100).toStringAsFixed(1)}%',
          );
        });

        TaskSnapshot testSnapshot = await testTask;
        debugPrint('Test upload tamamlandı');

        String testUrl = await testSnapshot.ref.getDownloadURL();
        debugPrint('Test dosyası URL alındı: $testUrl');

        await testSnapshot.ref.delete(); // Test dosyasını sil
        debugPrint('Test dosyası silindi');
        debugPrint('Firebase Storage bağlantısı başarılı');
        storageAvailable = true;
      } catch (testError) {
        debugPrint('Firebase Storage bağlantı hatası: $testError');
        debugPrint('Hata türü: ${testError.runtimeType}');

        if (testError is FirebaseException) {
          debugPrint('Firebase hata kodu: ${testError.code}');
          debugPrint('Firebase hata mesajı: ${testError.message}');
        }

        debugPrint(
          'Firebase Storage kullanılamıyor, sadece Firestore kullanılacak',
        );
        storageAvailable = false;
      }

      // Firestore'da belge kaydını oluştur
      Map<String, dynamic> documentData = {
        'name': documentName,
        'type': documentType,
        'url': storageAvailable ? '' : 'local_only', // Storage yoksa local_only
        'uploadedAt': FieldValue.serverTimestamp(),
        'fileSize': fileSize,
        'isFavorite': false,
        'userId': userId,
        'storageAvailable': storageAvailable,
      };

      debugPrint('Firestore verisi hazırlandı: $documentData');

      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .add(documentData);

      debugPrint('Firestore kaydı oluşturuldu: ${docRef.id}');

      // Eğer Storage kullanılabilirse dosyayı yükle
      if (storageAvailable) {
        try {
          String fileName =
              'documents/$userId/${DateTime.now().millisecondsSinceEpoch}_$documentName';
          Reference ref = _storage.ref().child(fileName);

          debugPrint('Storage referansı oluşturuldu: $fileName');

          // Dosyayı byte array olarak oku ve yükle
          Uint8List fileBytes = await documentFile.readAsBytes();
          debugPrint(
            'Dosya byte array olarak okundu: ${fileBytes.length} bytes',
          );

          // Upload task'ı başlat ve progress'i takip et
          UploadTask uploadTask = ref.putData(fileBytes);
          debugPrint('Upload task başlatıldı');

          // Upload progress'ini dinle
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            double progress = snapshot.bytesTransferred / snapshot.totalBytes;
            debugPrint(
              'Upload progress: ${(progress * 100).toStringAsFixed(1)}%',
            );
          });

          TaskSnapshot snapshot = await uploadTask;
          debugPrint('Upload tamamlandı');

          String downloadUrl = await snapshot.ref.getDownloadURL();
          debugPrint('Download URL alındı: $downloadUrl');
          debugPrint('Download URL uzunluğu: ${downloadUrl.length}');

          // Firestore'da URL'i güncelle
          await docRef.update({'url': downloadUrl});

          debugPrint('Firestore URL güncellendi');

          // Başarılı olduğunu doğrula
          if (downloadUrl.isNotEmpty) {
            debugPrint('Dosya yükleme başarılı: $downloadUrl');
            return downloadUrl;
          } else {
            debugPrint('HATA: Download URL boş');
            return null;
          }
        } catch (storageError) {
          debugPrint('Storage yükleme hatası: $storageError');
          // Storage hatası olsa bile Firestore kaydı başarılı
          await docRef.update({
            'url': 'upload_failed',
            'error': storageError.toString(),
          });
          return 'upload_failed';
        }
      } else {
        // Storage kullanılamıyorsa sadece Firestore kaydı yeterli
        debugPrint('Dosya bilgileri sadece Firestore\'da saklandı');
        return 'local_only';
      }
    } catch (e) {
      debugPrint('Belge yükleme hatası: $e');
      debugPrint('Hata türü: ${e.runtimeType}');

      // Genel hata durumu
      throw Exception('Dosya yükleme sırasında bir hata oluştu: $e');
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
      debugPrint(
        'Belge silme başlatılıyor - UserId: $userId, DocumentId: $documentId',
      );

      // Firestore'dan belge bilgisini al
      DocumentSnapshot docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .doc(documentId)
          .get();

      if (docSnapshot.exists) {
        debugPrint('Belge Firestore\'da bulundu');
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        String? fileUrl = data['url'];
        debugPrint('Dosya URL: $fileUrl');

        // Storage'dan dosyayı sil
        if (fileUrl != null && fileUrl.isNotEmpty) {
          try {
            Reference ref = _storage.refFromURL(fileUrl);
            await ref.delete();
            debugPrint('Dosya Storage\'dan silindi');
          } catch (storageError) {
            debugPrint('Storage silme hatası (devam ediliyor): $storageError');
            // Storage hatası olsa bile Firestore'dan silmeye devam et
          }
        } else {
          debugPrint('Dosya URL bulunamadı, sadece Firestore kaydı silinecek');
        }

        // Firestore'dan belge kaydını sil
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('documents')
            .doc(documentId)
            .delete();
        debugPrint('Belge Firestore\'dan silindi');
      } else {
        debugPrint('Belge Firestore\'da bulunamadı');
        throw Exception('Belge bulunamadı');
      }
    } catch (e) {
      debugPrint('Belge silme hatası: $e');
      rethrow;
    }
  }

  // Kullanıcı verilerini dinleme (real-time updates)
  Stream<Map<String, dynamic>?> getUserProfileStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
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

  // Favori belgeleri getirme
  Future<List<Map<String, dynamic>>> getFavoriteDocuments(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .where('isFavorite', isEqualTo: true)
          .orderBy('uploadedAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Favori belge getirme hatası: $e');
      return [];
    }
  }

  // Favori belgeleri dinleme (real-time updates)
  Stream<List<Map<String, dynamic>>> getFavoriteDocumentsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('documents')
        .where('isFavorite', isEqualTo: true)
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

  // Belgeyi favorilere ekleme/çıkarma
  Future<void> toggleFavorite(
    String userId,
    String documentId,
    bool isFavorite,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .doc(documentId)
          .update({
            'isFavorite': isFavorite,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Favori güncelleme hatası: $e');
      rethrow;
    }
  }

  // Firebase Storage test metodu
  Future<bool> testStorageConnection() async {
    try {
      debugPrint('Firebase Storage bağlantısı test ediliyor...');

      // Kullanıcı ID'sini al
      String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('HATA: Kullanıcı girişi yapılmamış');
        return false;
      }

      debugPrint('Kullanıcı ID: $userId');
      debugPrint('Firebase Auth durumu: ${_auth.currentUser != null}');

      // Firebase Storage referansını test et
      Reference storageRef = _storage.ref();
      debugPrint('Storage referansı oluşturuldu');

      // Basit bir test dosyası oluştur
      String testContent = 'Test dosyası - ${DateTime.now()}';
      Uint8List testBytes = Uint8List.fromList(testContent.codeUnits);

      String testFileName = 'test_${DateTime.now().millisecondsSinceEpoch}.txt';
      Reference ref = storageRef.child('test/$userId/$testFileName');

      debugPrint('Test dosyası yükleniyor: $testFileName');
      debugPrint('Test dosyası boyutu: ${testBytes.length} bytes');

      // Upload task'ı başlat
      UploadTask uploadTask = ref.putData(testBytes);

      // Upload progress'ini dinle
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        debugPrint(
          'Test upload progress: ${(progress * 100).toStringAsFixed(1)}%',
        );
      });

      TaskSnapshot snapshot = await uploadTask;
      debugPrint('Test dosyası yüklendi');

      String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Test dosyası URL: $downloadUrl');

      // Test dosyasını sil
      await snapshot.ref.delete();
      debugPrint('Test dosyası silindi');

      return true;
    } catch (e) {
      debugPrint('Firebase Storage test hatası: $e');
      debugPrint('Hata türü: ${e.runtimeType}');

      if (e is FirebaseException) {
        debugPrint('Firebase hata kodu: ${e.code}');
        debugPrint('Firebase hata mesajı: ${e.message}');

        switch (e.code) {
          case 'storage/unauthorized':
            debugPrint('HATA: Firebase Storage yetkilendirme hatası');
            break;
          case 'storage/quota-exceeded':
            debugPrint('HATA: Firebase Storage kotası aşıldı');
            break;
          case 'storage/unauthenticated':
            debugPrint('HATA: Kullanıcı kimlik doğrulaması gerekli');
            break;
          case 'storage/object-not-found':
            debugPrint('HATA: Firebase Storage objesi bulunamadı');
            break;
          case 'storage/canceled':
            debugPrint('HATA: Upload iptal edildi');
            break;
          case 'storage/unknown':
            debugPrint('HATA: Bilinmeyen Firebase Storage hatası');
            break;
          default:
            debugPrint('HATA: Bilinmeyen Firebase Storage hatası: ${e.code}');
        }
      }
      return false;
    }
  }
}
