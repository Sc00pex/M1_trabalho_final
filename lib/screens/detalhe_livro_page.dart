import 'package:flutter/material.dart';

import '../models/livro.dart';
import '../widgets/conteudo_central.dart';
import '../widgets/status_livro.dart';
import 'formulario_livro_page.dart';

class DetalheLivroPage extends StatefulWidget {
  const DetalheLivroPage({super.key, required this.livro});

  final Livro livro;

  @override
  State<DetalheLivroPage> createState() => _DetalheLivroPageState();
}

class _DetalheLivroPageState extends State<DetalheLivroPage> {
  late Livro _livro;
  bool _alterado = false;

  @override
  void initState() {
    super.initState();
    _livro = widget.livro;
  }

  Future<void> _editar() async {
    final atualizado = await Navigator.of(context).push<Livro>(
      MaterialPageRoute(builder: (_) => FormularioLivroPage(livro: _livro)),
    );
    if (!mounted || atualizado == null) return;

    setState(() {
      _livro = atualizado;
      _alterado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Livro>(
      canPop: !_alterado,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(_livro);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Detalhes do livro')),
        body: SafeArea(
          child: SingleChildScrollView(
            child: ConteudoCentral(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.menu_book_rounded, size: 56),
                  const SizedBox(height: 24),
                  Text(
                    _livro.titulo,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'por ${_livro.autor}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  StatusLivro(status: _livro.status),
                  const SizedBox(height: 32),
                  Text(
                    'Minhas observações',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _livro.observacoes.isEmpty
                        ? 'Você ainda não fez anotações sobre este livro.'
                        : _livro.observacoes,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _editar,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar livro'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
