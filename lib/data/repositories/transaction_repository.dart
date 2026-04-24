import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_transaction.dart';

class TransactionRepository {
  final _col = FirebaseFirestore.instance.collection('transactions');

  Future<String> saveTransaction(AppTransaction tx) async {
    final doc = _col.doc();
    await doc.set({...tx.toMap(), 'id': doc.id});
    return doc.id;
  }

  Future<List<AppTransaction>> getUserTransactions(String userId) async {
    try {
      final snap = await _col
          .where('userId', isEqualTo: userId)
          .orderBy('paidAt', descending: true)
          .get();
      return snap.docs
          .map((d) => AppTransaction.fromMap(d.data(), d.id))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<AppTransaction>> streamUserTransactions(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => AppTransaction.fromMap(d.data(), d.id))
              .toList();
          list.sort((a, b) => b.paidAt.compareTo(a.paidAt));
          return list;
        });
  }
}
