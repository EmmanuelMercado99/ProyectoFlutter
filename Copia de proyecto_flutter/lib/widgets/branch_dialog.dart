// Importa el paquete de Flutter para componentes visuales.
import 'package:flutter/material.dart';

// Importa el modelo de sucursal.
import '../models/branch.dart';

// Widget para mostrar un diálogo que permite crear o editar una sucursal.
class BranchDialog extends StatelessWidget {
  // Objeto Branch existente (puede ser nulo si se está creando una nueva).
  final Branch? branch;

  // Controlador para el campo de texto del nombre.
  final TextEditingController nameController;

  // Controlador para el campo de texto de la ubicación.
  final TextEditingController locationController;

  // Constructor del diálogo, inicializa los controladores con los valores actuales de la sucursal si existen.
  BranchDialog({
    super.key,
    this.branch,
  })  : nameController = TextEditingController(text: branch?.name),
        locationController = TextEditingController(text: branch?.location);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Título del diálogo que cambia según si se está creando o editando.
      title: Text(branch == null ? 'Nueva Sucursal' : 'Editar Sucursal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo de texto para el nombre de la sucursal.
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Ingrese el nombre de la sucursal',
            ),
          ),
          const SizedBox(height: 8), // Espaciado entre campos.
          // Campo de texto para la ubicación de la sucursal.
          TextField(
            controller: locationController,
            decoration: const InputDecoration(
              labelText: 'Ubicación',
              hintText: 'Ingrese la ubicación (opcional)',
            ),
          ),
        ],
      ),
      actions: [
        // Botón para cancelar y cerrar el diálogo.
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        // Botón para guardar los datos ingresados y cerrar el diálogo.
        TextButton(
          onPressed: () {
            // Verifica que el nombre no esté vacío antes de guardar.
            if (nameController.text.isNotEmpty) {
              // Devuelve un mapa con los datos ingresados al cerrar el diálogo.
              Navigator.pop(context, {
                'name': nameController.text,
                'location': locationController.text,
              });
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
