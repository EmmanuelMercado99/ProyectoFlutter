// Importa los widgets de Flutter necesarios para la interfaz.
import 'package:flutter/material.dart';

// Importa el modelo de cliente.
import '../models/customer.dart';

// Widget que representa un diálogo para agregar o editar un cliente.
class CustomerDialog extends StatefulWidget {
  // Cliente que se va a editar (puede ser nulo si se está creando uno nuevo).
  final Customer? customer;

  // Constructor que acepta un cliente opcional.
  const CustomerDialog({Key? key, this.customer}) : super(key: key);

  @override
  _CustomerDialogState createState() => _CustomerDialogState();
}

// Estado asociado al CustomerDialog que maneja los campos del formulario.
class _CustomerDialogState extends State<CustomerDialog> {
  // Llave del formulario para validación.
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de nombre y correo.
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores con los valores del cliente si existen.
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _emailController =
        TextEditingController(text: widget.customer?.email ?? '');
  }

  @override
  void dispose() {
    // Libera los recursos de los controladores al cerrar el widget.
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Título dinámico dependiendo si se está agregando o editando un cliente.
      title:
          Text(widget.customer == null ? 'Agregar Cliente' : 'Editar Cliente'),

      // Contenido del diálogo: formulario con validación.
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo de texto para el nombre del cliente.
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un nombre';
                }
                return null;
              },
            ),
            // Campo de texto para el correo electrónico del cliente.
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un email';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        // Botón para cancelar la operación y cerrar el diálogo.
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),

        // Botón para guardar el cliente si el formulario es válido.
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Crea una instancia de cliente con los datos ingresados.
              final customer = Customer(
                id: widget.customer?.id ??
                    DateTime.now().millisecondsSinceEpoch,
                name: _nameController.text,
                email: _emailController.text,
              );
              // Devuelve el cliente al cerrar el diálogo.
              Navigator.of(context).pop(customer);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
