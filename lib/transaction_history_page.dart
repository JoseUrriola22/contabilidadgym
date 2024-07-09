import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:inv_upg1/models/transaction.dart';
import 'package:inv_upg1/provider/total_amount_provider.dart';
import 'package:inv_upg1/provider/transaction_list_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatefulWidget {
  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? selectedDate;
  List<Transaction> allTransactions = []; // Assuming this exists and is populated elsewhere
  List<Transaction> filteredTransactions = []; // Declaration of filteredTransactions
  List<DateTime> uniqueDates = [];
  CalendarFormat _calendarFormat = CalendarFormat.week; // Paso 1: Agregar el estado del formato del calendario
  final TextEditingController _dateController = TextEditingController(); // Paso 1: Agregar el controlador para el TextField

 @override
void initState() {
  super.initState();
  selectedDate = DateTime.now();
  final provider = Provider.of<TransactionListProvider>(context, listen: false);
  provider.fetchTransactions().then((_) {
    obtenerFechasUnicas();
    onDateSelected(selectedDate!);
  });
  _dateController.text = DateFormat('d \'de\' MMMM \'de\' yyyy', 'es_ES').format(selectedDate!);
}

  
void obtenerFechasUnicas() async {
  final provider = Provider.of<TransactionListProvider>(context, listen: false);
  Set<DateTime> fechas = await provider.databaseService.obtenerFechasUnicasTransacciones();
  if (!listEquals(uniqueDates, fechas.toList())) {
    setState(() {
      uniqueDates = fechas.toList();
    });
  }
}

void onDateSelected(DateTime newDate) {
  var newSelectedDate = DateTime(newDate.year, newDate.month, newDate.day);
  if (selectedDate != newSelectedDate) {
    setState(() {
      selectedDate = newSelectedDate;
      _dateController.text = DateFormat('d \'de\' MMMM \'de\' yyyy', 'es_ES').format(newDate);
      filteredTransactions = allTransactions.where((transaction) =>
        transaction.date.year == newDate.year &&
        transaction.date.month == newDate.month &&
        transaction.date.day == newDate.day).toList();
    });
  }
}

  void onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  List<Transaction> getFilteredTransactions(TransactionListProvider transactionList) {
  return selectedDate != null
      ? transactionList.transactions.where((transaction) {
          DateTime transactionDateNormalized = DateTime(
            transaction.date.year,
            transaction.date.month,
            transaction.date.day,
          );
          return transactionDateNormalized == selectedDate;
        }).toList()
      : transactionList.transactions;
}

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Historial de Transacciones'),
      ),
      body: Column(
        children: [
          _buildTableCalendar(),
          _buildSelectedDateTextField(),
          _buildTotalAmountWidget(),
          _buildTransactionList(),
        ],
      ),
    );
  }
  
  Widget _buildTableCalendar() {
    return TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: DateTime.now(),
            selectedDayPredicate: (day) => selectedDate != null && isSameDay(selectedDate!, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (uniqueDates.any((date) => isSameDay(date, selectedDay))) {
                onDateSelected(selectedDay);
              }
            },
            calendarFormat: _calendarFormat, // Paso 2: Usar el estado del formato del calendario
            onFormatChanged: (format) {
              onFormatChanged(format); // Actualizar el formato del calendario cuando el usuario lo cambie
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                if (uniqueDates.any((date) => isSameDay(date, day))) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: Center(
                      child: Text('${day.day}'),
                    ),
                  );
                } else {
                  return null;
                }
              },
            ),
          );
  }
  
  Widget _buildSelectedDateTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _dateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Fecha Seleccionada',
          suffixIcon: Icon(Icons.calendar_today),
        ),
      ),
    );
  }
  
  Widget _buildTotalAmountWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<TransactionListProvider>(
        builder: (context, transactionList, child) {
                 var filteredTransactions = getFilteredTransactions(transactionList);
          // Calcula el total de las transacciones filtradas
                double total = filteredTransactions.fold(0, (previousValue, transaction) {
                  if (['proveedor', 'casa'].contains(transaction.title.toLowerCase())) {
                    return previousValue - transaction.amount;
                  }
                  return previousValue + transaction.amount;
                });
  
          return Text('Total en esta fecha: \$${total.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          );
        },
      ),
    );
  }
  
  Widget _buildTransactionList() {
    return Expanded(
      child: Consumer<TransactionListProvider>(
        builder: (context, transactionList, child) {
                var filteredTransactions = getFilteredTransactions(transactionList);
                    
                return ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return ListTile(
                      title: Text(transaction.title),
                      subtitle: Text('${transaction.amount.toString()} - ${transaction.description}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(context, transaction, transactionList, index),
                      ),
                    );
                  },
                );
              },
      ),
    );
  }
    @override
  void dispose() {
    _dateController.dispose(); // Limpiar el controlador cuando el widget se deshaga
    super.dispose();
  }

  void _confirmDelete(BuildContext context, Transaction transaction, TransactionListProvider transactionList, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: const Text('¿Estás seguro de que quieres eliminar esta transacción?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                   var totalAmountProvider = Provider.of<TotalAmountProvider>(context, listen: false);
                  double nuevoTotal = totalAmountProvider.totalAmount - transaction.amount;
                  await transactionList.deleteTransaction(transaction.docId);
                  
                  if (nuevoTotal < 0) {
                    print('Error: El monto total no puede ser negativo');
                  } else {
                    totalAmountProvider.updateTotalAmount(nuevoTotal);
                    print('Transacción $index eliminada');
                  }
                  
                  
                } catch (e) {
                  print('Error al eliminar la transacción: $e');
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}