import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TotalAmountProvider with ChangeNotifier {
  double _totalAmount = 0;

  double get totalAmount => _totalAmount;

  TotalAmountProvider() {
    _fetchTotalAmount();
  }
void _fetchTotalAmount() async {
  DocumentSnapshot doc = await FirebaseFirestore.instance.collection('gimnasios').doc('gM3RqYAuJwOptheNfN1r').get();
  _totalAmount = (doc['total_dinero'] as num).toDouble();
  notifyListeners();
}
  Future<void> updateTotalAmount(double newTotal) async {
    _totalAmount = newTotal;
    await FirebaseFirestore.instance.collection('gimnasios').doc('gM3RqYAuJwOptheNfN1r').update({'total_dinero': _totalAmount});
    notifyListeners();
  }
}