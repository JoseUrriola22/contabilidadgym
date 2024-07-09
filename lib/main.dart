import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inv_upg1/add_transaction_page.dart';
import 'package:inv_upg1/provider/total_amount_provider.dart';
import 'package:inv_upg1/transaction_history_page.dart';
import 'pie_chart_widget.dart';
import 'package:provider/provider.dart';
import 'package:inv_upg1/models/transaction.dart';
import 'package:inv_upg1/inventariogimnasio.dart'; // Importación de InventarioGimnasio
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importa esto
import 'package:inv_upg1/provider/transaction_list_provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeDateFormatting().then((_) {
    runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransactionListProvider()),
        ChangeNotifierProvider(create: (context) => TotalAmountProvider()),
      ],
      child: MyApp(),
    ),
  );
  });
  
  
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pie Chart App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          ),
        ),
      ),
      home: MyHomePage(),
      routes: {
        '/addTransaction': (context) => AddTransactionPage(),
        '/transactionHistory': (context) => TransactionHistoryPage(),
        '/inventarioGimnasio': (context) => InventarioGimnasio(), // Ruta para InventarioGimnasio
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contabilidad del Gimnasio'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          CustomElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/addTransaction').then((value) {
                if (value != null) {
                  Transaction newTransaction = value as Transaction;
                  Provider.of<TransactionListProvider>(context, listen: false).addTransaction(newTransaction);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Nueva transacción agregada: \$${newTransaction.amount.toStringAsFixed(2)}'),
                    ),
                  );
                }
              });
            },
            label: 'Agregar Transacción',
            color: Colors.blue,
            textColor: Colors.white,
          ),
          SizedBox(height: 10),
          CustomElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/transactionHistory');
            },
            label: 'Ver Historial',
            color: Colors.green,
            textColor: Colors.white,
          ),
          SizedBox(height: 10),
          CustomElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/inventarioGimnasio'); // Botón para navegar a InventarioGimnasio
            },
            label: 'Inventario Gimnasio',
            color: Colors.purple,
            textColor: Colors.white,
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: PieChartWidget(),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color color;
  final Color textColor;

  CustomElevatedButton({
    required this.onPressed,
    required this.label,
    this.color = Colors.blue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor),
      ),
    );
  }
}