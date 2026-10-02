import 'package:flutter/material.dart';

import '../models/livro.dart';
import '../widgets/conteudo_central.dart';
import '../widgets/livro_card.dart';
import 'detalhe_livro_page.dart';
import 'formulario_livro_page.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final List<Livro> _livros = [];
  int _proximoId = 1;

  Future<void> _adicionarLivro() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final livro = await Navigator.of(context).push<Livro>(
      MaterialPageRoute(
        builder: (_) => FormularioLivroPage(novoId: _proximoId),
      ),
    );
    if (!mounted || livro == null) return;

    setState(() {
      _livros.add(livro);
      _proximoId++;
    });
    _mostrarMensagem('Livro adicionado à sua estante.');
  }

  Future<void> _abrirLivro(Livro livro) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final atualizado = await Navigator.of(context).push<Livro>(
      MaterialPageRoute(builder: (_) => DetalheLivroPage(livro: livro)),
    );
    if (!mounted || atualizado == null) return;

    setState(() {
      final indice = _livros.indexWhere((item) => item.id == atualizado.id);
      if (indice >= 0) _livros[indice] = atualizado;
    });
    _mostrarMensagem('As alterações foram salvas.');
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Estante')),
      body: SafeArea(
        child: ConteudoCentral(
          child: ListView.builder(
            itemCount: _livros.isEmpty ? 2 : _livros.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return const _Cabecalho();
              if (_livros.isEmpty) {
                return _EstadoVazio(onAdicionar: _adicionarLivro);
              }
              final livro = _livros[index - 1];
              return LivroCard(livro: livro, onTap: () => _abrirLivro(livro));
            },
          ),
        ),
      ),
      bottomNavigationBar: _livros.isEmpty
          ? null
          : SafeArea(
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _adicionarLivro,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Adicionar livro'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cada livro, uma história.',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text('Guarde suas leituras e o que elas deixaram em você.'),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({required this.onAdicionar});

  final VoidCallback onAdicionar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_stories_rounded, size: 64),
            const SizedBox(height: 20),
            Text(
              'Sua estante começa aqui',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione um livro que você já leu ou quer conhecer.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdicionar,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Adicionar livro'),
            ),
          ],
        ),
      ),
    );
  }
}
