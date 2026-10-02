import 'package:flutter/material.dart';

import '../models/livro.dart';
import '../widgets/conteudo_central.dart';

class FormularioLivroPage extends StatefulWidget {
  const FormularioLivroPage({super.key, this.livro, this.novoId});

  final Livro? livro;
  final int? novoId;

  @override
  State<FormularioLivroPage> createState() => _FormularioLivroPageState();
}

class _FormularioLivroPageState extends State<FormularioLivroPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _autor;
  late final TextEditingController _observacoes;
  late StatusLeitura _status;

  @override
  void initState() {
    super.initState();
    _titulo = TextEditingController(text: widget.livro?.titulo ?? '');
    _autor = TextEditingController(text: widget.livro?.autor ?? '');
    _observacoes = TextEditingController(text: widget.livro?.observacoes ?? '');
    _status = widget.livro?.status ?? StatusLeitura.queroLer;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _autor.dispose();
    _observacoes.dispose();
    super.dispose();
  }

  String? _validarObrigatorio(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe $campo do livro.';
    }
    return null;
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final livro = Livro(
      id: widget.livro?.id ?? widget.novoId!,
      titulo: _titulo.text.trim(),
      autor: _autor.text.trim(),
      status: _status,
      observacoes: _observacoes.text.trim(),
    );
    Navigator.of(context).pop(livro);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.livro != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar livro' : 'Adicionar livro'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConteudoCentral(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    editando
                        ? 'Atualize sua leitura'
                        : 'Um novo lugar na estante',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Título e autor são obrigatórios. O restante fica a seu critério.',
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    key: const Key('campo_titulo'),
                    controller: _titulo,
                    decoration: const InputDecoration(labelText: 'Título'),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    maxLength: 120,
                    validator: (valor) =>
                        _validarObrigatorio(valor, 'o título'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('campo_autor'),
                    controller: _autor,
                    decoration: const InputDecoration(labelText: 'Autor'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    maxLength: 100,
                    validator: (valor) => _validarObrigatorio(valor, 'o autor'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<StatusLeitura>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Sua leitura'),
                    isExpanded: true,
                    items: StatusLeitura.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.rotulo),
                          ),
                        )
                        .toList(),
                    onChanged: (status) {
                      if (status != null) setState(() => _status = status);
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    key: const Key('campo_observacoes'),
                    controller: _observacoes,
                    decoration: const InputDecoration(
                      labelText: 'Observações (opcional)',
                      hintText:
                          'Uma lembrança, uma indicação, uma impressão...',
                      alignLabelWithHint: true,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _salvar,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(
                        editando ? 'Salvar alterações' : 'Salvar livro',
                      ),
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
