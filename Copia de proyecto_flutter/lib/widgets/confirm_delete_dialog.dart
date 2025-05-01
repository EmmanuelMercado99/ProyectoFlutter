// Importa el paquete de Flutter necesario para crear interfaces gráficas.
import 'package:flutter/material.dart';

// Widget que muestra un cuadro de diálogo de confirmación para eliminar un elemento.
class ConfirmDeleteDialog extends StatelessWidget {
  // Nombre del elemento que se desea eliminar (por ejemplo: "Sucursal Central").
  final String itemName;

  // Tipo de elemento (por ejemplo: "sucursal", "producto", etc.).
  final String itemType;

  // Constructor que recibe el nombre y tipo del elemento como argumentos obligatorios.
  const ConfirmDeleteDialog({
    super.key,
    required this.itemName,
    required this.itemType,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Título del diálogo, incluye el tipo del elemento.
      title: Text('Eliminar $itemType'),

      // Mensaje de confirmación que muestra el nombre y tipo del elemento.
      content: Text('¿Está seguro que desea eliminar $itemType "$itemName"?'),

      // Botones de acción del cuadro de diálogo.
      actions: [
        // Botón para cancelar la operación y cerrar el diálogo sin eliminar.
        TextButton(
          onPressed: () => Navigator.pop(context, false), // Devuelve "false".
          child: const Text('Cancelar'),
        ),

        // Botón para confirmar la eliminación. Se muestra en rojo.
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.red, // Color rojo para advertencia.
          ),
          onPressed: () => Navigator.pop(context, true), // Devuelve "true".
          child: const Text('Eliminar'),
        ),
      ],
    );
  }
}
