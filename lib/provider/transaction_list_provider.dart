import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inv_upg1/models/transaction.dart';
import 'package:inv_upg1/database.dart' as fc;
import 'package:cloud_firestore/cloud_firestore.dart' as cf;

class TransactionListProvider with ChangeNotifier {
  fc.DatabaseService databaseService = fc.DatabaseService();
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  double get total => _transactions.fold(0, (sum, item) => sum + item.amount);

  Future<void> deleteTransaction(String id) async {
    try {
      await databaseService.eliminarTransaccion(id);
      _transactions.removeWhere((transaction) => transaction.docId == id);
      notifyListeners();
    } catch (e) {
      throw Exception('Error al eliminar la transacción: $e');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      cf.FirebaseFirestore _db = cf.FirebaseFirestore.instance;
      var docRef = await _db.collection('transactions').add({
        'id': transaction.id,
        'title': transaction.title,
        'amount': transaction.amount,
      });
      transaction.docId = docRef.id;
      _transactions.add(transaction);
      notifyListeners();
    } catch (e) {
      throw Exception('Error al agregar la transacción: $e');
    }
  }

  
  Future<List<Transaction>> fetchTransactions() {
    Completer<List<Transaction>> completer = Completer<List<Transaction>>();
  
    databaseService.obtenerTransaccionesConIds().listen(
      (List<Map<String, dynamic>> transactions) {
        _transactions = transactions.map((transaction) => Transaction.fromMap(transaction, transaction['id'])).toList();
        notifyListeners();
        completer.complete(_transactions);
      },
      onError: (error) => completer.completeError(error),
    );
  
    return completer.future;
  }
}