import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  String id;
  String docId;
  double amount;
  String description;
  DateTime date;
  String title;

  Transaction({required this.id, required this.docId,required this.amount, required this.description, required this.date, required this.title});

static double tryConvertToDouble(dynamic value, double defaultValue) {
  try {
    return double.parse(value.toString());
  } catch (e) {
    return defaultValue;
  }
}

  static Transaction fromMap(Map<String, dynamic> data, String documentId) {
      return Transaction(
        id: data['categoria_id'] ?? 'default_id',
         docId: documentId,
        amount: tryConvertToDouble(data['monto'], 0.0), // esto se cambio ya que la base de datos no retorna un valor double y eso causa una excepcion
        description: data['descripcion'] ?? 'default_description',
        date: data['fecha'] != null ? (data['fecha'] as Timestamp).toDate() : DateTime.now(),
        title: data['tipo'] ?? 'default_title',
      );
  }
  Map<String, dynamic> toMap() {
    return {
      'categoria_id': id,
      'monto': amount,
      'descripcion': description,
      'day': date,
      'tipo': title,
    };
}
}