// Importa los paquetes necesarios.
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/branch.dart';

// Diálogo para crear o editar un producto.
class ProductDialog extends StatefulWidget {
  final Product? product; // Producto a editar (puede ser null si es nuevo).
  final List<Branch> branches; // Lista de sucursales disponibles.

  const ProductDialog({
    super.key,
    this.product,
    required this.branches,
  });

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  // Controladores de texto para los campos del formulario.
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  Branch? selectedBranch; // Sucursal seleccionada.

  @override
  void initState() {
    super.initState();
    // Si se está editando un producto, inicializar campos con sus datos.
    if (widget.product != null) {
      nameController.text = widget.product!.name;
      priceController.text = widget.product!.price.toString();
      stockController.text = widget.product!.stock.toString();
      // Busca la sucursal del producto actual en la lista.
      selectedBranch = widget.branches.firstWhere(
        (b) => b.id == widget.product!.branchId,
      );
    } else if (widget.branches.isNotEmpty) {
      // Si es un nuevo producto, selecciona la primera sucursal disponible.
      selectedBranch = widget.branches.first;
    }
  }

  @override
  void dispose() {
    // Limpia los controladores al cerrar el widget.
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.product == null ? 'Nuevo Producto' : 'Editar Producto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo para el nombre del producto.
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Ingrese el nombre del producto',
              ),
            ),
            const SizedBox(height: 8),
            // Campo para el precio del producto.
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Precio',
                hintText: 'Ingrese el precio',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            // Campo para la cantidad en existencia.
            TextField(
              controller: stockController,
              decoration: const InputDecoration(
                labelText: 'Existencias',
                hintText: 'Ingrese la cantidad en existencia',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Selector de sucursal.
            DropdownButtonFormField<Branch>(
              value: selectedBranch,
              decoration: const InputDecoration(
                labelText: 'Sucursal',
                border: OutlineInputBorder(),
              ),
              items: widget.branches.map((branch) {
                return DropdownMenuItem(
                  value: branch,
                  child: Text(branch.name),
                );
              }).toList(),
              onChanged: (Branch? value) {
                setState(() {
                  selectedBranch = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        // Botón para cancelar y cerrar el diálogo.
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        // Botón para guardar los datos ingresados.
        TextButton(
          onPressed: () {
            if (nameController.text.isNotEmpty &&
                priceController.text.isNotEmpty &&
                stockController.text.isNotEmpty &&
                selectedBranch != null) {
              // Devuelve un mapa con los datos ingresados.
              Navigator.pop(context, {
                'name': nameController.text,
                'price': double.parse(priceController.text),
                'stock': int.parse(stockController.text),
                'branchId': selectedBranch!.id,
              });
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
