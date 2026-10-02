import 'package:flutter/material.dart';

// Limita a largura em telas maiores e mantém espaço nas laterais do celular.
class ConteudoCentral extends StatelessWidget {
  const ConteudoCentral({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );
  }
}
