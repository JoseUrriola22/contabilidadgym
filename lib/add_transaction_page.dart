import 'package:flutter/material.dart';
import 'package:inv_upg1/database.dart';
import 'package:inv_upg1/provider/total_amount_provider.dart';
import 'package:provider/provider.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  // Estado de carga y clave del formulario
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _tipoTransaccionController = TextEditingController();

  // Variables del formulario
  String? _transactionTitle, _transactionDescription, _transactionCategory, _transactionType, _transactionSubCategory, _selectedInventarioItem;
  double? _transactionAmount;
  int? _cantidad;

  // Claves únicas para Dropdowns
  UniqueKey _subCategoryDropdownKey = UniqueKey();
  UniqueKey _inventarioDropdownKey = UniqueKey();

  // Listas y mapas
  List<String> _inventarioItems = [];
  final Map<String, String> _categoryIds = {
    'proveedor': 'KwJdsdXiZoTptLp3QikB',
    'mensualidad': 'gF1rsNRQ1hqxyWprxyYy',
    'diario': 'Agfzsd4qrTLO8vmvp8MV',
    'nevera': 'tzlAqIy7w0VmdRxEs5dD',
    'cafeteria': 'VdbPrhkrPXdzqhtURTP5',
    'congelador': 'b9ckxM4fFjIENSA23I81',
    'casa': 'tzlAqIy7w0VmdRxEs5dD',
  };

void _submitForm() async {
  if (_formKey.currentState?.validate() ?? false) {
    setState(() {
      _isLoading = true; // Iniciar la carga
    });
    _formKey.currentState?.save();
    try {
      if (_transactionCategory == 'Producto' && _transactionSubCategory != null && _selectedInventarioItem != null) {
        DatabaseService db = DatabaseService();
        var documento = await db.obtenerDocumentoPorNombre(_transactionSubCategory!, _selectedInventarioItem!);
        if (documento != null && _cantidad != null) {
          _transactionAmount = _transactionAmount! * _cantidad!;
          await db.actualizarInventario(-_cantidad!, _transactionSubCategory!, documento);
        } else {
          throw Exception("Documento o cantidad no disponibles.");
        }
      }
       _createTransaction();
      _updateTotalAmount();
      // Mostrar confirmación de éxito
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transacción creada con éxito")));
      // Reiniciar el formulario para una nueva transacción
      _formKey.currentState?.reset();
      // Reiniciar el estado de carga y otros estados específicos del formulario si es necesario
      if (mounted) {
      setState(() {
        _isLoading = false;
        _resetFormState(); // Implementar este método según sea necesario
      });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al crear la transacción: $e")));
      setState(() {
        _isLoading = false;
      });
    }
  }
}
  
void _updateInventario(String subCategoria) async {
  DatabaseService db = DatabaseService();
  db.obtenerInventarioConIds(subCategoria).listen((data) {
    List<String> inventario = data.map((doc) => doc['nombre'] as String).toList(); // Cast the data to List<String>
    setState(() {
    _inventarioItems = inventario;
    _selectedInventarioItem = null; // Resetea la selección al cambiar la subcategoría
    _inventarioDropdownKey = UniqueKey(); // Actualiza la clave para forzar la reconstrucción del dropdown de inventario
  });
  });
}

void _onInventarioItemSelected(String newValue) {
  setState(() {
    _selectedInventarioItem = newValue;
    // Paso 3: Actualiza el valor del TextEditingController con la selección del DropdownButton.
    _tipoTransaccionController.text = _selectedInventarioItem!;
  });
}

  Future<void> _createTransaction() async {
    Map<String, dynamic> transactionData = {
      'tipo': _transactionTitle,
      'descripcion': _transactionDescription,
      'monto': _transactionAmount,
      'categoria_id': _categoryIds[_transactionSubCategory!],
      'fecha': DateTime.now(),
    };

    DatabaseService db = DatabaseService();
    await db.crearTransaccion(transactionData);
  }

  void _updateTotalAmount() {
    double nuevoTotalAgregado = (_transactionType == 'Pago' || _transactionType == 'Gastos') ? -_transactionAmount! : _transactionAmount!;
    var totalAmountProvider = Provider.of<TotalAmountProvider>(context, listen: false);
    totalAmountProvider.updateTotalAmount(totalAmountProvider.totalAmount + nuevoTotalAgregado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Transacción'),
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator()) // Mostrar la pantalla de carga
        : Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: ListView(
              children: [
              _buildReadOnlyTextField(
                label: "Tipo de transacción",
                controller: _tipoTransaccionController,
                saveFunction: (value) => _transactionTitle = value,
                validateFunction: (value) => value == null || value.isEmpty ? 'Por favor ingrese un tipo' : null,
              ),
              _buildTextFormField(
                label: 'Cliente de la transacción',
                saveFunction: (value) => _transactionDescription = value,
                validateFunction: (value) => value == null || value.isEmpty ? 'Por favor ingrese una descripción' : null,
              ),
              _buildTextFormField(
                label: 'Monto de la transacción',
                keyboardType: TextInputType.number,
                saveFunction: (value) => _transactionAmount = double.tryParse(value ?? ''),
                validateFunction: (value) {
                  if (value == null || value.isEmpty) return 'Por favor ingrese un monto';
                  if (double.tryParse(value) == null) return 'Por favor ingrese un número válido';
                  return null;
                },
              ),
              _buildDropdownButtonFormField(),
              if (_transactionCategory != null) ...[
                SizedBox(height: 20),
                _buildSubCategoryDropdown(),
              ],
              // Paso 5: Integrar el tercer menú desplegable en el UI
              // Agregar la condición para mostrar el tercer menú desplegable en el método build, después del segundo menú desplegable
              if (_transactionCategory == 'Producto' && _inventarioItems.isNotEmpty) ...[
                SizedBox(height: 20),
                _buildInventarioDropdown(),

              ],
              if (_transactionCategory == 'Producto' && _selectedInventarioItem != null) ...[
              SizedBox(height: 20),
              _buildCantidadFormField(),
            ],

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Guardar Transacción'),
              ),
            ],
          ),
        ),
      ),
    );
  }


// Método para crear el campo de texto "Cantidad" ajustado para aceptar int
TextFormField _buildCantidadFormField() {
  return TextFormField(
    decoration: InputDecoration(labelText: 'Cantidad'),
    keyboardType: TextInputType.number,
    onSaved: (value) => _cantidad = int.tryParse(value ?? ''),
    validator: (value) {
      if (value == null || value.isEmpty) return 'Por favor ingrese la cantidad';
      final n = int.tryParse(value);
      if (n == null) return 'Por favor ingrese un número entero válido';
      return null;
    },
  );
}

  TextFormField _buildTextFormField({
    required String label,
    TextInputType? keyboardType,
    required Function(String?) saveFunction,
    required String? Function(String?) validateFunction,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      onSaved: saveFunction,
      validator: validateFunction,
    );
  }

TextFormField _buildReadOnlyTextField({
  required String label,
  required TextEditingController controller,
  required Function(String) saveFunction,
  required String? Function(String?) validateFunction,
}) {
  return TextFormField(
    controller: controller,
    readOnly: true, // Hace el TextField de solo lectura.
    decoration: InputDecoration(
      labelText: label,
    ),
    onSaved: (value) => saveFunction(value!),
    validator: validateFunction,
    // Aquí puedes agregar más configuraciones según necesites.
  );
}

  DropdownButtonFormField<String> _buildDropdownButtonFormField() {
    final Map<String, List<String>> mainCategories = {
      'Producto': ['nevera', 'congelador', 'cafeteria'],
      'Uso Gym': ['Mensualidad', 'Diario'],
      'Gastos': ['Proveedor', 'Casa'],
    };

    return DropdownButtonFormField(
      decoration: InputDecoration(labelText: 'Categoría de la transacción'),
      items: mainCategories.keys.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      // Actualización en el método _buildDropdownButtonFormField
      onChanged: (value) {
        setState(() {
          _transactionCategory = value;
          _transactionSubCategory = null; // Resetear la subcategoría seleccionada
          _selectedInventarioItem = null; // Resetear el inventario seleccionado
          _inventarioItems.clear(); // Limpiar los items de inventario
          _subCategoryDropdownKey = UniqueKey(); // Generar nueva clave para subcategoría
          // Generar nueva clave para inventario si es necesario
          // Esto depende de la lógica específica de la aplicación, si el inventario se muestra basado en la subcategoría, esto podría no ser necesario aquí
        });
      },
      validator: (value) => value == null || value.isEmpty ? 'Por favor seleccione una categoría' : null,
    );
  }

  DropdownButtonFormField<String> _buildSubCategoryDropdown() {
    final Map<String, List<String>> mainCategories = {
      'Producto': ['nevera', 'congelador', 'cafeteria'],
      'Uso Gym': ['Mensualidad', 'Diario'],
      'Gastos': ['Proveedor', 'Casa'],
    };

    List<String>? subCategories = _transactionCategory != null ? mainCategories[_transactionCategory!] : [];

    // Paso 3: Usar el valor de clave único como Key para el widget
    return DropdownButtonFormField<String>(
      key: _subCategoryDropdownKey,
      decoration: InputDecoration(labelText: 'Subcategoría de la transacción'),
      items: subCategories!.map((subCategory) {
        return DropdownMenuItem(
          value: subCategory,
          child: Text(subCategory),
        );
      }).toList(),

      // Paso 4: Actualizar el método _buildSubCategoryDropdown para incluir la llamada a _updateInventario
// Modificar el onChanged para incluir la llamada a _updateInventario si la categoría es 'Producto'
      onChanged: (value) {
      setState(() {
        _transactionSubCategory = value;
        _selectedInventarioItem = null; // Resetea la selección de inventario
        if (_transactionCategory == 'Producto') {
          _updateInventario(value!);
        } else {
          _inventarioItems = []; // Limpia el inventario si no es 'Producto'
          _tipoTransaccionController.text = value!;
        }
      });
       },
      validator: (value) => value == null || value.isEmpty ? 'Por favor seleccione una subcategoría' : null,
    );
  }

  DropdownButtonFormField<String> _buildInventarioDropdown() {
    return DropdownButtonFormField(
      key: _inventarioDropdownKey, // Usar la clave única aquí
      decoration: InputDecoration(labelText: 'Producto'),
      items: _inventarioItems.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
    onChanged: (String? newValue) {
      if (newValue != null) {
        _onInventarioItemSelected(newValue);
      }
    },
      validator: (value) => value == null || value.isEmpty ? 'Por favor seleccione un producto' : null,
    );
  }

// Método adicional para reiniciar el estado del formulario si es necesario
void _resetFormState() {
  // Reiniciar variables de estado específicas del formulario
  _transactionTitle = null;
  _transactionDescription = null;
  // Continuar reiniciando el estado según sea necesario
}

}
