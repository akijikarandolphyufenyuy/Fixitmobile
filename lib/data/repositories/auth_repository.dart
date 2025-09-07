// lib/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AppUser {
  final String id;
  final String? name; // <-- Full name: "John Doe"
  final String? email;

  AppUser({required this.id, this.name, this.email});
}

class AuthRepository extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _currentUser;
  bool _isReady = false;

  // Getters
  AppUser? get currentUser => _currentUser;
  bool get isReady => _isReady;

  // ✅ Singleton Pattern
  static final AuthRepository _instance = AuthRepository._internal();

  static var instance = _instance;

  factory AuthRepository() => _instance;

  AuthRepository._internal() {
    _init();
  }

  get data => null;

  // Initialize auth state listener
  Future<void> _init() async {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData(user);
      } else {
        _currentUser = null;
        _isReady = true;
        notifyListeners();
      }
    });
  }

  // ✅ UPDATED: Load user data from Firestore with firstName + lastName
  Future<void> _loadUserData(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      String? fullName;
      Map<String, dynamic>? userData; // To safely access data if doc exists

      if (doc.exists) {
        userData = doc.data()!;
        final firstName = userData['firstName'] as String? ?? '';
        final lastName = userData['lastName'] as String? ?? '';

        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          fullName = '$firstName $lastName'.trim();
        } else {
          // Fallback to displayName or email
          fullName = user.displayName ?? user.email?.split('@').first;
        }
      } else {
        // No doc in Firestore — fallback for name
        fullName = user.displayName ?? user.email?.split('@').first;
      }

      _currentUser = AppUser(
        id: user.uid,
        name: fullName, // ✅ Now it's real name!
        email:
            userData?['email'] ??
            user.email, // Use userData for email if available
      );

      _isReady = true;
      notifyListeners();
    } catch (e) {
      print("Error loading user data: $e");

      // Safe fallback
      _currentUser = AppUser(
        id: user.uid,
        name: user.displayName ?? user.email?.split('@').first,
        email: user.email,
      );
      _isReady = true;
      notifyListeners();
    }
  }

  // ✅ Public method to wait until auth is fully initialized
  Future<void> waitForInit() async {
    if (_isReady) return;

    final completer = Completer<void>();
    late StreamSubscription<User?> subscription;

    subscription = _auth.authStateChanges().listen((user) {
      if (_isReady) {
        completer.complete();
        subscription.cancel();
      }
    });

    subscription.onError((error) {
      completer.completeError(error);
      subscription.cancel();
    });

    return completer.future;
  }

  // === Business Logic Methods ===

  bool isLoggedIn() => _currentUser != null;

  Future<bool> needsSubscription() async {
    if (!isLoggedIn()) return false;
    final snap = await _firestore
        .collection('users')
        .doc(_currentUser!.id)
        .get();
    return snap.data()?['isActiveSubscription'] != true;
  }

  Future<bool> isFirstRun() async {
    if (!isLoggedIn()) return false;
    final snap = await _firestore
        .collection('users')
        .doc(_currentUser!.id)
        .get();
    final data = snap.data();
    return data?['onboardingCompleted'] != true;
  }

  Future<void> markOnboardingComplete() async {
    if (_currentUser != null) {
      await _firestore.collection('users').doc(_currentUser!.id).update({
        'onboardingCompleted': true,
      });
    }
  }

  // lib/data/repositories/auth_repository.dart
  Future<void> completeOnboarding() async {
    // This method now calls the existing markOnboardingComplete,
    // which handles the Firestore update for 'onboardingCompleted'.
    await markOnboardingComplete();
    print("User onboarding completed!"); // You can remove this print later
    // As `isFirstRun` directly queries Firestore, a `notifyListeners()`
    // here is typically not needed unless `_currentUser` or another
    // internal state property related to onboarding is introduced and updated.
  }

  // === Auth Actions ===

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email ?? email,
        // For new sign-ups, displayName might not be set yet by Firebase Auth,
        // so `email.split('@').first` is a good initial fallback for `firstName`.
        'firstName': user.displayName ?? email.split('@').first,
        'lastName': '', // Often collected separately or left blank initially
        'onboardingCompleted': false,
        'isActiveSubscription': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // === Google / Facebook signup null-safe example ===
  Future<void> socialSignUp(User user) async {
    // This method handles creating/merging user data after social sign-up.
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email ?? '',
      'firstName': user.displayName?.split(' ').first ?? '',
      // If displayName contains multiple words, get the rest as lastName.
      'lastName':
          user.displayName != null && user.displayName!.split(' ').length > 1
          ? user.displayName!.split(' ').sublist(1).join(' ')
          : '',
      'profession': '',
      'skills': '',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
