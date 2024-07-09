import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:inv_upg1/provider/total_amount_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PieChartWidget extends StatefulWidget {
  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  List<TextEditingController> percentageControllers = [];
  List<String> sectionTitles = [];

 // Define los colores de las secciones aquí para que coincidan con los del PieChart
  final List<Color> sectionColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores con porcentajes iguales
    double initialPercentage = 100 / 4; // 100% dividido entre 4 secciones
    percentageControllers = List.generate(4, (index) => TextEditingController(text: '$initialPercentage'));
    sectionTitles = ['Arrendamiento', 'Pagos', 'Inversiones', 'Extra'];
    loadState();
  }

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se desmonte
    percentageControllers.forEach((controller) => controller.dispose());
    super.dispose();

  }

  Future<void> saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('sectionTitles', sectionTitles);
    await prefs.setStringList('percentages', percentageControllers.map((controller) => controller.text).toList());
  }
  
  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? loadedTitles = prefs.getStringList('sectionTitles');
    List<String>? loadedPercentages = prefs.getStringList('percentages');
  
    if (loadedTitles != null && loadedPercentages != null) {
      setState(() {
        sectionTitles = loadedTitles;
        percentageControllers = List.generate(loadedPercentages.length, (index) => TextEditingController(text: loadedPercentages[index]));
      });
    }
  }

  void _showTitleEditor(BuildContext context, int index) {
    TextEditingController titleController = TextEditingController(text: sectionTitles[index]);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Título de la Sección'),
          content: TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: "Ingrese nuevo título"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                setState(() {
                  sectionTitles[index] = titleController.text; // Actualiza el título de la sección
                  saveState();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  List<PieChartSectionData> generateSections(double totalAmount) {

    return List.generate(percentageControllers.length, (index) {
      double percentage = double.tryParse(percentageControllers[index].text) ?? 0;
      double amount = totalAmount * (percentage / 100);
      return PieChartSectionData(
        color: sectionColors[index % sectionColors.length],
        value: amount,
        title: '${percentage.toStringAsFixed(0)}% \n\$${amount.toStringAsFixed(2)}',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    });
  }

  void _showPercentageEditor(BuildContext context, int index) {
     // Verifica si el índice es válido
  if (index < 0 || index >= percentageControllers.length) {
    print('Índice inválido: $index');
    return; // Sale de la función si el índice no es válido
  }

  TextEditingController editController = TextEditingController(text: percentageControllers[index].text);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Editar Porcentaje'),
        content: TextField(
            controller: editController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Ingrese nuevo porcentaje"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
              double newPercentage = double.tryParse(editController.text) ?? 0;
              if (newPercentage < 0 || newPercentage > 90) {
                // Validación adicional para el nuevo porcentaje
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Porcentaje inválido: $newPercentage'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
                return;
              }
              double remainingPercentage = 100 - newPercentage;
              double sumOfOtherPercentages = percentageControllers.asMap().entries.where((entry) => entry.key != index).map((entry) => double.tryParse(entry.value.text) ?? 0).fold(0.0, (a, b) => a + b);
              if (sumOfOtherPercentages == 0) {
                if (remainingPercentage < 100) {
                  // Ajusta todos los otros porcentajes a 0 si no hay más porcentaje para distribuir
                  percentageControllers.asMap().entries.where((entry) => entry.key != index).forEach((entry) => entry.value.text = '0');
                }
              } else {
                double scaleFactor = remainingPercentage / sumOfOtherPercentages;
                percentageControllers.asMap().entries.where((entry) => entry.key != index).forEach((entry) {
                  double currentPercentage = double.tryParse(entry.value.text) ?? 0;
                  double adjustedPercentage = currentPercentage * scaleFactor;
                  entry.value.text = adjustedPercentage.toStringAsFixed(2);
                });
              }

              setState(() {
                percentageControllers[index].text = newPercentage.toStringAsFixed(2);
                saveState();
              });

              Navigator.of(context).pop();
            },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = Provider.of<TotalAmountProvider>(context).totalAmount;

    
    // Organiza los títulos y cuadritos de colores en dos filas
    List<Widget> titleWidgets = [];
    for (int i = 0; i < sectionTitles.length; i++) {
      titleWidgets.add(
        GestureDetector(
          onTap: () => _showTitleEditor(context, i),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                color: sectionColors[i % sectionColors.length],
              ),
              SizedBox(width: 8),
              Text(sectionTitles[i]),
            ],
          ),
        ),
      );
    }

    return Column(
       children: [
        // Divide los widgets de título en dos filas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: titleWidgets.sublist(0, titleWidgets.length ~/ 2),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: titleWidgets.sublist(titleWidgets.length ~/ 2, titleWidgets.length),
        ),
        
        Expanded(
          child: GestureDetector(
            onTapUp: (details) {
              // Placeholder para la funcionalidad de tocar una sección del gráfico
            },
            child: Stack(
              children: [
                Center(
                  child: PieChart(
                    PieChartData(
                      sections: generateSections(totalAmount),
                      centerSpaceRadius: 60,
                      sectionsSpace: 2,
                      borderData: FlBorderData(show: false),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          if (event is FlLongPressEnd || event is FlTapUpEvent) {
                            if (pieTouchResponse != null && pieTouchResponse.touchedSection != null) {
                              int touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              _showPercentageEditor(context, touchedIndex);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '\$${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}