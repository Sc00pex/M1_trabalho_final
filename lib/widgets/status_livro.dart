import 'package:flutter/material.dart';

import '../models/livro.dart';

class StatusLivro extends StatelessWidget {
  const StatusLivro({super.key, required this.status});

  final StatusLeitura status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EFE8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.rotulo,
        style: const TextStyle(
          color: Color(0xFF295B46),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
