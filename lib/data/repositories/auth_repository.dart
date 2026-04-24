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
    // Use currentUser first (instant, no network) for warm starts
    final current = _auth.currentUser;
    if (current != null) {
      _currentUser = AppUser(
        id: current.uid,
        name: current.displayName ?? current.email?.split('@').first,
        email: current.email,
      );
      _isReady = true;
      notifyListeners();
      // Load full profile in background without blocking
      _loadUserData(current);
    }

    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        if (!_isReady) {
          // Cold start — set ready immediately with basic info
          _currentUser = AppUser(
            id: user.uid,
            name: user.displayName ?? user.email?.split('@').first,
            email: user.email,
          );
          _isReady = true;
          notifyListeners();
          // Load full profile in background
          _loadUserData(user);
        }
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
      // Error loading user data

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
