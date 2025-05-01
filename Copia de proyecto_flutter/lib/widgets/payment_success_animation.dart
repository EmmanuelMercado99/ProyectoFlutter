// Importa los widgets y clases necesarias de Flutter.
import 'package:flutter/material.dart';

// Widget con animación de éxito de pago.
// Requiere el método de pago y una función callback al finalizar la animación.
class PaymentSuccessAnimation extends StatefulWidget {
  final String
      paymentMethod; // Nombre del método de pago (ej. Efectivo, Tarjeta).
  final VoidCallback
      onAnimationComplete; // Función a ejecutar cuando termina la animación.

  const PaymentSuccessAnimation({
    super.key,
    required this.paymentMethod,
    required this.onAnimationComplete,
  });

  @override
  State<PaymentSuccessAnimation> createState() =>
      _PaymentSuccessAnimationState();
}

// Estado que controla la animación.
class _PaymentSuccessAnimationState extends State<PaymentSuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Controlador de animaciones.
  late Animation<double> _scaleAnimation; // Animación de escalado.
  late Animation<double> _opacityAnimation; // Animación de opacidad.

  @override
  void initState() {
    super.initState();

    // Inicializa el controlador con duración de 4 segundos.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Define animación de escala con curva elástica.
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Define animación de opacidad que se desvanece al final.
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // Inicia la animación y al finalizar ejecuta el callback.
    _controller.forward().then((_) {
      widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    // Libera recursos del controlador al destruir el widget.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Construye la UI animada usando AnimatedBuilder.
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value, // Controla la transparencia.
          child: Transform.scale(
            scale: _scaleAnimation.value, // Controla el escalado.
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black54, // Fondo semi-transparente.
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícono dinámico según el método de pago.
                      Icon(
                        widget.paymentMethod == 'Efectivo'
                            ? Icons.attach_money
                            : Icons.credit_card,
                        size: 64,
                        color: const Color(0xFF50C878), // Verde esmeralda.
                      ),
                      const SizedBox(height: 16),
                      // Mensaje principal.
                      const Text(
                        '¡Pago Exitoso!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Muestra el método de pago.
                      Text(
                        'Método: ${widget.paymentMethod}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
