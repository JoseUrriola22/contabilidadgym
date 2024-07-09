import 'package:flutter/material.dart';
import 'package:inv_upg1/add_transaction_page.dart';
import 'package:inv_upg1/transaction_history_page.dart';

class HomePage extends StatelessWidget {
  final double totalAmount; // Monto total disponible

  HomePage({required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Transacciones'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Total: \$${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTransactionPage()),
                );
              },
              child: Text('Agregar Transacción'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionHistoryPage()),
                );
              },
              child: Text('Ver Historial'),
            ),
          ],
        ),
      ),
    );
  }
}
