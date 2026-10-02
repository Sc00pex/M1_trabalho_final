enum StatusLeitura {
  queroLer('Quero ler'),
  lendo('Estou lendo'),
  lido('Já li');

  const StatusLeitura(this.rotulo);

  final String rotulo;
}

class Livro {
  const Livro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.status,
    this.observacoes = '',
  });

  final int id;
  final String titulo;
  final String autor;
  final StatusLeitura status;
  final String observacoes;
}
