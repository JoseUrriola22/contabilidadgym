import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_upg1/database.dart'; // Asegúrate de importar tu archivo database.dart correctamente

class InventarioGimnasio extends StatefulWidget {
  @override
  _InventarioGimnasioState createState() => _InventarioGimnasioState();
}

class _InventarioGimnasioState extends State<InventarioGimnasio> {
  final DatabaseService _databaseService = DatabaseService();
  String _opcionSeleccionada = 'nevera';
  List<Map<String, dynamic>> _productos = [];
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  void _cargarProductos() async {
    _iniciarCarga();
    try {
      final productosStream = _databaseService.obtenerInventarioConIds(_opcionSeleccionada);
      productosStream.listen(
        (productos) => _actualizarProductos(productos),
        onError: (error) => _manejarError(error),
      );
    } catch (e) {
      _manejarError(e);
    }
  }

  void _iniciarCarga() {
    setState(() {
      _cargando = true;
      _error = null;
    });
  }

  void _actualizarProductos(List<Map<String, dynamic>> productos) {
    setState(() {
      _productos = productos;
      _cargando = false;
    });
  }

  void _manejarError(Object error) {
    setState(() {
      _error = error.toString();
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventario del Gimnasio'),
      ),
      body: Column(
        children: [
          _buildDropdownButton(),
          _buildContent(),
        ],
      ),
    );
  }

  DropdownButton<String> _buildDropdownButton() {
    return DropdownButton<String>(
      value: _opcionSeleccionada,
      onChanged: (String? newValue) {
        setState(() {
          _opcionSeleccionada = newValue!;
          _cargarProductos();
        });
      },
      items: <String>['nevera', 'congelador', 'cafeteria']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildContent() {
    if (_cargando) return Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));
    return Expanded(
      child: ListView.builder(
        itemCount: _productos.length,
        itemBuilder: (context, index) {
          final producto = _productos[index];
          return ListTile(
            title: Text(producto['nombre']),
            subtitle: Text('Cantidad: ${producto['cantidad']}'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _mostrarDialogoActualizacion(context, producto['id'], producto['cantidad'], _opcionSeleccionada),
            ),
          );
        },
      ),
    );
  }

  void _mostrarDialogoActualizacion(BuildContext context, String idProducto, int cantidadActual, String categoriaSeleccionada) {
  final TextEditingController _controller = TextEditingController(text: cantidadActual.toString());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Actualizar cantidad'),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Nueva cantidad',
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Actualizar'),
            onPressed: () {
              final int nuevaCantidad = int.parse(_controller.text);
              _databaseService.actualizarCantidadProducto(categoriaSeleccionada, nuevaCantidad, idProducto)
                .then((_) => Navigator.of(context).pop())
                .then((_) => _cargarProductos())
                .catchError((error) => print("Error al actualizar: $error"));
            },
          ),
        ],
      );
    },
  );
}

}