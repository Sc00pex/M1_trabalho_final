import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_estante/app.dart';
import 'package:minha_estante/models/livro.dart';
import 'package:minha_estante/widgets/livro_card.dart';

const _gerarEvidencias = bool.fromEnvironment('GERAR_EVIDENCIAS');
final _capturaKey = GlobalKey();

Future<void> _iniciar(
  WidgetTester tester,
  Size tamanho, {
  double escala = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = tamanho;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.platformDispatcher.textScaleFactorTestValue = escala;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  if (_gerarEvidencias) {
    await tester.runAsync(() async {
      final fonte = File(
        '.tools/flutter/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
      );
      final loader = FontLoader('Roboto');
      loader.addFont(
        Future.value(ByteData.sublistView(await fonte.readAsBytes())),
      );
      await loader.load();
      final icones = FontLoader('MaterialIcons');
      icones.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icones.load();
    });
  }
  await tester.pumpWidget(
    RepaintBoundary(key: _capturaKey, child: const MinhaEstanteApp()),
  );
  await tester.pumpAndSettle();
}

Future<void> _capturar(WidgetTester tester, String nome) async {
  if (!_gerarEvidencias) return;
  await tester.pumpAndSettle();
  final boundary =
      _capturaKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final imagem = await boundary.toImage();
    final bytes = await imagem.toByteData(format: ui.ImageByteFormat.png);
    final arquivo = File('relatorio/evidencias/$nome.png');
    await arquivo.parent.create(recursive: true);
    await arquivo.writeAsBytes(bytes!.buffer.asUint8List());
    imagem.dispose();
  });
}

Future<void> _pressionar(WidgetTester tester, String texto) async {
  final botao = find.widgetWithText(FilledButton, texto);
  await tester.ensureVisible(botao);
  await tester.pumpAndSettle();
  await tester.tap(botao);
  await tester.pumpAndSettle();
}

Future<void> _voltar(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

Future<void> _preencher(
  WidgetTester tester,
  String titulo,
  String autor,
) async {
  await tester.enterText(find.byKey(const Key('campo_titulo')), titulo);
  await tester.enterText(find.byKey(const Key('campo_autor')), autor);
}

void main() {
  testWidgets('estado vazio, validação, criação, detalhe e edição na coleção', (
    tester,
  ) async {
    await _iniciar(tester, const Size(360, 800));
    expect(find.text('Sua estante começa aqui'), findsOneWidget);
    await _capturar(tester, '01_vazio');

    await _pressionar(tester, 'Adicionar livro');
    await _pressionar(tester, 'Salvar livro');
    expect(find.text('Informe o título do livro.'), findsOneWidget);
    expect(find.text('Informe o autor do livro.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('campo_titulo')), '   ');
    await _pressionar(tester, 'Salvar livro');
    expect(find.text('Informe o título do livro.'), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, 800),
    );
    await _capturar(tester, '02_validacao');

    await _preencher(tester, 'O Pequeno Príncipe', 'Antoine de Saint-Exupéry');
    await tester.enterText(
      find.byKey(const Key('campo_observacoes')),
      'Quero reler com calma e prestar atenção nas pequenas coisas.',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, 800),
    );
    await _capturar(tester, '03_formulario_valido');
    await _pressionar(tester, 'Salvar livro');
    expect(find.text('O Pequeno Príncipe'), findsOneWidget);
    expect(find.text('Sua estante começa aqui'), findsNothing);
    await _capturar(tester, '04_criacao');

    await _pressionar(tester, 'Adicionar livro');
    await _preencher(tester, 'Dom Casmurro', 'Machado de Assis');
    await _pressionar(tester, 'Salvar livro');
    expect(find.text('Dom Casmurro'), findsOneWidget);
    await _capturar(tester, '05_colecao');

    await tester.tap(find.text('O Pequeno Príncipe'));
    await tester.pumpAndSettle();
    expect(find.text('por Antoine de Saint-Exupéry'), findsOneWidget);
    expect(find.text('por Machado de Assis'), findsNothing);
    await _capturar(tester, '06_detalhe');
    await _pressionar(tester, 'Editar livro');
    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('campo_titulo')))
          .controller!
          .text,
      'O Pequeno Príncipe',
    );
    await tester.enterText(
      find.byKey(const Key('campo_titulo')),
      'O Pequeno Príncipe (releitura)',
    );
    await tester.tap(find.byType(DropdownButtonFormField<StatusLeitura>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Já li').last);
    await tester.pumpAndSettle();
    await _pressionar(tester, 'Salvar alterações');
    expect(find.text('O Pequeno Príncipe (releitura)'), findsOneWidget);
    expect(find.text('Já li'), findsOneWidget);
    await _capturar(tester, '07_detalhe_editado');
    await _voltar(tester);
    await tester.pumpAndSettle();
    expect(find.text('O Pequeno Príncipe (releitura)'), findsOneWidget);
    expect(find.text('Dom Casmurro'), findsOneWidget);
    expect(find.text('O Pequeno Príncipe'), findsNothing);
    await _capturar(tester, '08_colecao_editada_360');
    tester.view.physicalSize = const Size(800, 600);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await _capturar(tester, '09_colecao_editada_800');
  });

  testWidgets('cancelar formulário não cria nem altera livro', (tester) async {
    await _iniciar(tester, const Size(360, 800));
    await _pressionar(tester, 'Adicionar livro');
    await _preencher(tester, 'Livro descartado', 'Autor');
    await _voltar(tester);
    await tester.pumpAndSettle();
    expect(find.text('Sua estante começa aqui'), findsOneWidget);
    await _pressionar(tester, 'Adicionar livro');
    await _preencher(tester, 'Dom Casmurro', 'Machado de Assis');
    await _pressionar(tester, 'Salvar livro');
    await tester.tap(find.text('Dom Casmurro'));
    await tester.pumpAndSettle();
    await _pressionar(tester, 'Editar livro');
    await tester.enterText(find.byKey(const Key('campo_titulo')), 'Não salvar');
    await _voltar(tester);
    await tester.pumpAndSettle();
    expect(find.text('Dom Casmurro'), findsOneWidget);
    await _voltar(tester);
    await tester.pumpAndSettle();
    expect(find.text('Dom Casmurro'), findsOneWidget);
    expect(find.text('Não salvar'), findsNothing);
  });

  for (final tamanho in [const Size(360, 800), const Size(800, 600)]) {
    testWidgets('texto ampliado, rolagem e acessibilidade em $tamanho', (
      tester,
    ) async {
      final semantica = tester.ensureSemantics();
      try {
        await _iniciar(tester, tamanho, escala: 2);
        expect(tester.takeException(), isNull);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await _pressionar(tester, 'Adicionar livro');
        await _preencher(
          tester,
          'Um título bem comprido para verificar a quebra de linha na estante',
          'Uma autora com um nome comprido para verificar o espaço disponível',
        );
        await _pressionar(tester, 'Salvar livro');
        expect(tester.takeException(), isNull);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        final node = tester.getSemantics(find.byType(LivroCard).first);
        expect(
          node.getSemanticsData().hasAction(ui.SemanticsAction.tap),
          isTrue,
        );
        node.owner!.performAction(node.id, ui.SemanticsAction.tap);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await _pressionar(tester, 'Editar livro');
        tester.view.viewInsets = FakeViewPadding(bottom: tamanho.height * 0.4);
        await tester.pumpAndSettle();
        await _pressionar(tester, 'Salvar alterações');
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
      } finally {
        semantica.dispose();
        tester.view.resetViewInsets();
      }
    });
  }
}
