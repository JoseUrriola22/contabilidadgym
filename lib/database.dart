import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String gimnasioId = 'gM3RqYAuJwOptheNfN1r';
  final String inventarioId = 'XD9AGnIB3R4Gg7mm0eQl';

Future<void> actualizarTotalDinero(double nuevoTotal) async {
  try {
    // Obtener referencia al documento del gimnasio
    DocumentReference gimnasioRef = FirebaseFirestore.instance.collection('gimnasios').doc(gimnasioId);

    // Obtener el documento actual
    DocumentSnapshot gimnasioDoc = await gimnasioRef.get();

    // Obtener el valor actual de total_dinero
    double totalActual = gimnasioDoc['total_dinero'];

    // Calcular el nuevo total_dinero (ejemplo: aumentar en 100 unidades)
    nuevoTotal = nuevoTotal +  totalActual;

    // Actualizar el campo total_dinero en Firestore
    await gimnasioRef.update({'total_dinero': nuevoTotal});
    
    // Si necesitas retorno de información o manejo de errores, podrías hacerlo aquí
  } catch (e) {
    // Manejar errores
    print('Error al actualizar total_dinero: $e');
    throw e; // Opcional: Propagar el error para manejarlo en otro lugar si es necesario
  }
}


Future<void> crearTransaccion(Map<String, dynamic> transaccionData) async {
  try {
    // Añadir documento a la colección 'transacciones'
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('transacciones')
        .add(transaccionData);
    
    // Obtener el ID del documento recién creado
    String transaccionId = docRef.id;
    print("Documento creado con ID: $transaccionId");
  } catch (e) {
    print(e.toString());
  }
}


  Stream<List<Map<String, dynamic>>> obtenerTransaccionesConIds() {
  return FirebaseFirestore.instance
      .collection('gimnasios')
      .doc(gimnasioId)
      .collection('transacciones')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
        // Crear un mapa con los datos del documento y su ID
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id; // Añadir el ID del documento al mapa
        return data;
      }).toList());
}

Future<void> actualizarTransaccion(String transaccionId, Map<String, dynamic> transaccionData) async {
  try {
    await FirebaseFirestore.instance
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('transacciones')
        .doc(transaccionId)
        .update(transaccionData);
    print("Documento actualizado con ID: $transaccionId");
  } catch (e) {
    print(e.toString());
  }
}





  Future<void> eliminarTransaccion(String transaccionId) async {
  try {
    await FirebaseFirestore.instance
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('transacciones')
        .doc(transaccionId)
        .delete();
    print("Documento eliminado con ID: $transaccionId");
  } catch (e) {
    print(e.toString());
  }
}




    Stream<List<Map<String, dynamic>>> obtenerInventarioConIds(String inventario) {
  return FirebaseFirestore.instance
      .collection('inventario')
      .doc(inventarioId)
      .collection(inventario)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
        // Crear un mapa con los datos del documento y su ID
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id; // Añadir el ID del documento al mapa
        return data;
      }).toList());
}

Future<List<Map<String, dynamic>>> futureobtenerInventarioConIds(String inventario) {
  return FirebaseFirestore.instance
      .collection('inventario')
      .doc(inventarioId)
      .collection(inventario)
      .get()
      .then((snapshot) => snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Añadir el ID del documento al mapa
        return data;
      }).toList());
}


Future<void> actualizarInventario(int cantidad, String tipoInventario, String docinv) async {
  try {
    // Obtener referencia al documento del inventario
    DocumentReference inventarioRef = FirebaseFirestore.instance.collection('inventario').doc(inventarioId).collection(tipoInventario).doc(docinv);

    // Obtener el documento actual
    DocumentSnapshot inventarioDoc = await inventarioRef.get();

    // Obtener el valor actual de total_dinero
    int totalActual = inventarioDoc['cantidad'];

    // Calcular el nuevo total_dinero (ejemplo: aumentar en 100 unidades)
    cantidad = totalActual + cantidad;

    // Actualizar el campo total_dinero en Firestore
    await inventarioRef.update({'cantidad': cantidad});
    
    // Si necesitas retorno de información o manejo de errores, podrías hacerlo aquí
  } catch (e) {
    // Manejar errores
    print('Error al actualizar total_dinero: $e');
    throw e; // Opcional: Propagar el error para manejarlo en otro lugar si es necesario
  }
}

Future<void> actualizarCantidadProducto(String tipoInventario, int nuevaCantidad, String docinv) async {
  return await FirebaseFirestore.instance.collection('inventario').doc(inventarioId).collection(tipoInventario).doc(docinv).update({'cantidad': nuevaCantidad});
}

Future<String> obtenerDocumentoPorNombre(String tipoInventario, String nombre) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('inventario')
        .doc(inventarioId)
        .collection(tipoInventario)
        .where('nombre', isEqualTo: nombre)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Retornar el ID del documento como String
      return querySnapshot.docs.first.id;
    } else {
      print('No se encontró un documento con el nombre: $nombre');
      throw Exception('Documento no encontrado');
    }
  } catch (e) {
    print('Error al obtener documento por nombre: $e');
    throw e;
  }
}
Future<Set<DateTime>> obtenerFechasUnicasTransacciones() async {
  try {
    // Obtener todos los documentos de la colección 'transacciones'
    QuerySnapshot transaccionesSnapshot = await FirebaseFirestore.instance
        .collection('gimnasios')
        .doc(gimnasioId)
        .collection('transacciones')
        .get();

    // Crear un conjunto para almacenar las fechas únicas
    Set<DateTime> fechasUnicas = {};

    // Iterar sobre los documentos para extraer la fecha
    for (var doc in transaccionesSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('fecha')) {
        // Convertir el Timestamp de Firestore a DateTime
        Timestamp timestamp = data['fecha'];
        DateTime fechaCompleta = timestamp.toDate();
        // Normalizar la fecha para ignorar la hora
        DateTime fechaNormalizada = DateTime(fechaCompleta.year, fechaCompleta.month, fechaCompleta.day);
        // Agregar la fecha normalizada al conjunto
        fechasUnicas.add(fechaNormalizada);
      }
    }

    return fechasUnicas;
  } catch (e) {
    print('Error al obtener fechas únicas de transacciones: $e');
    throw e;
  }
}
}