# Minha Estante

Catálogo pessoal de livros desenvolvido em **Flutter** para o trabalho final de **Desenvolvimento Mobile I**.

## Objetivo

Organizar as leituras em uma estante simples: cadastrar livros, consultar seus detalhes e acompanhar o que você quer ler, está lendo ou já leu.

## Funcionalidades

- **Estante:** lista dos livros cadastrados e mensagem quando a coleção está vazia.
- **Cadastro:** título, autor, situação da leitura e observações opcionais.
- **Validação:** título e autor são obrigatórios; entradas compostas apenas por espaços são recusadas.
- **Detalhes:** consulta das informações do livro selecionado.
- **Edição:** atualização dos dados com a alteração refletida no detalhe e na lista.
- **Interface:** tema Material 3, conteúdo com rolagem e adaptação a diferentes tamanhos de tela.

> Os livros ficam na memória durante a execução. Ao reiniciar o aplicativo, a estante volta a ficar vazia.

## Como executar

### Pré-requisitos

- Git instalado.
- Flutter instalado e disponível no terminal. A versão utilizada na entrega foi **Flutter 3.47.6**, com **Dart 3.13.5**.
- Android SDK configurado e licenças Android aceitas.
- Emulador Android iniciado ou celular conectado com depuração USB habilitada.

Confira a configuração do ambiente:

```sh
flutter doctor
```

### 1. Obter o projeto

```sh
git clone https://github.com/Sc00pex/M1_trabalho_final.git
cd M1_trabalho_final
```

### 2. Instalar as dependências

```sh
flutter pub get
```

### 3. Iniciar o aplicativo

```sh
flutter run
```

## Análise e testes

Execute a análise estática e os testes de widget:

```sh
dart format lib test
flutter analyze
flutter test
```

Os testes em `test/catalogo_test.dart` verificam o fluxo de cadastro, validação, detalhe e edição, além do cancelamento de formulários e da acessibilidade em dois tamanhos de tela.

## Gerar o APK

```sh
flutter build apk --release
```

O arquivo gerado fica em `build/app/outputs/flutter-apk/app-release.apk`.
