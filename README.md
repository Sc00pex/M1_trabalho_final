# Minha Estante

Trabalho final de Desenvolvimento Mobile I — Kayann Leandro de Sá, RA 0031623, 4º período, 2º semestre de 2026.

Um catálogo pessoal para guardar os livros que quero ler, estou lendo ou já li. Cada livro tem título, autor, situação da leitura e observações opcionais.

## O que o aplicativo faz

- Começa com uma estante vazia e um convite para cadastrar o primeiro livro.
- Mostra os livros cadastrados em uma lista dinâmica.
- Abre o detalhe do livro selecionado.
- Permite criar e editar livros, com título e autor obrigatórios.
- Atualiza o detalhe e a lista após a edição. Cancelar o formulário descarta as alterações.

Os dados ficam na memória durante a execução. Ao fechar e abrir novamente o aplicativo, a estante começa vazia. Persistência, exclusão, busca e contas de usuário ficaram fora do escopo deste trabalho.

## Executar

Versão usada na entrega: Flutter 3.47.6 e Dart 3.13.5. Para Android, é necessário configurar o Android SDK e aceitar suas licenças. A versão mínima do aplicativo é Android 7.0 (API 24).

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

Para gerar o artefato Android:

```sh
flutter build apk --release
```

O APK fica em `build/app/outputs/flutter-apk/app-release.apk`. A assinatura é de desenvolvimento, adequada para instalar e avaliar o trabalho.

No Windows, o script `scripts/verificar.ps1` executa as verificações e salva suas saídas em `relatorio/logs`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verificar.ps1
```

Neste computador, uma cópia do Flutter foi instalada em `.tools/flutter`. Se o Flutter não estiver no PATH:

```powershell
.\.tools\flutter\bin\flutter.bat run
```

## Organização

```text
lib/
  main.dart                     início da execução
  app.dart                      aplicativo e localização em português
  models/livro.dart              modelo e situações da leitura
  screens/                      lista, detalhe e formulário
  widgets/                      cartão, etiqueta de leitura e largura do conteúdo
  theme/app_theme.dart           cores, campos e botões
test/catalogo_test.dart          testes do fluxo, cancelamento e acessibilidade
relatorio/                      PDF, capturas e saídas dos comandos
```

O estado é mantido na lista da `CatalogoPage` com `setState`. As telas devolvem um `Livro` pelo `Navigator`, e o identificador permite atualizar apenas o item editado. Não há dependências de gerenciamento de estado ou de banco de dados.

## Evidências e relatório

As imagens do relatório são capturas da interface renderizada nos testes de widget, em 360 × 800 e 800 × 600 pixels lógicos. Não são fotografias de um dispositivo Android. Os testes também verificam textos a 200%, conteúdo longo e acesso ao botão de salvar com espaço reduzido pelo teclado.

Para regenerar as capturas usando o Flutter instalado nesta pasta:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verificar.ps1 -Flutter .\.tools\flutter\bin\flutter.bat -GerarEvidencias
```

O modo de evidências carrega a fonte Roboto da instalação local do SDK. Os testes normais (`flutter test`) não dependem dessa pasta.

O relatório tem oito páginas, incluindo a identificação, os 13 critérios e as evidências. A versão editável fica em `relatorio/relatorio_final.md`. O gerador `scripts/gerar_relatorio.py` usa ReportLab; para executá-lo, são necessários os logs de verificação, as imagens, o APK e um commit Git. PyMuPDF foi usado somente para conferir o PDF exportado.

## Fontes e contribuições

- [Documentação do Flutter](https://docs.flutter.dev/).
- [Formulários e validação](https://docs.flutter.dev/cookbook/forms/validation).
- [Navegação](https://docs.flutter.dev/cookbook/navigation/navigation-basics).
- [Acessibilidade e testes](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility).
- Ícones Material e fonte Roboto incluídos no Flutter; nenhuma imagem externa de capa de livro.
- Assistência do Codex na elaboração do código, testes, documentação e relatório. A identificação do estudante e o tema foram fornecidos por Kayann.

O repositório remoto não foi informado. A entrega inclui o código e uma cópia transportável do repositório Git local, `entrega/minha-estante.bundle`, com a versão identificada no relatório. Para reproduzir a partir dessa cópia:

```sh
git clone entrega/minha-estante.bundle minha_estante
cd minha_estante
flutter pub get
flutter analyze
flutter test
flutter run
```
