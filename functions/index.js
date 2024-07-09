
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.actualizarTotalDinero = functions.firestore
    .document('gimnasios/{gimnasioId}/transacciones/{transaccionId}')
    .onWrite(async (change, context) => {
        const gimnasioId = context.params.gimnasioId;
        const transaccionesRef = admin.firestore().collection('gimnasios').doc(gimnasioId).collection('transacciones');

        try {
            const transaccionesSnapshot = await transaccionesRef.get();
            let totalDinero = 0;

            transaccionesSnapshot.forEach(doc => {
                totalDinero += doc.data().monto;
            });

            const gimnasioRef = admin.firestore().collection('gimnasios').doc(gimnasioId);
            await gimnasioRef.update({ total_dinero: totalDinero });

            console.log(`Total dinero actualizado para el gimnasio ${gimnasioId}: ${totalDinero}`);
        } catch (error) {
            console.error('Error al actualizar el total de dinero:', error);
        }
    });

