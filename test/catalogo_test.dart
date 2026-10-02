import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_estante/app.dart';
import 'package:minha_estante/models/livro.dart';
import 'package:minha_estante/widgets/livro_card.dart';

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
  await tester.pumpWidget(const MinhaEstanteApp());
  await tester.pumpAndSettle();
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

    await _pressionar(tester, 'Adicionar livro');
    await _pressionar(tester, 'Salvar livro');
    expect(find.text('Informe o título do livro.'), findsOneWidget);
    expect(find.text('Informe o autor do livro.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('campo_titulo')), '   ');
    await _pressionar(tester, 'Salvar livro');
    expect(find.text('Informe o título do livro.'), findsOneWidget);

    await _preencher(tester, 'O Pequeno Príncipe', 'Antoine de Saint-Exupéry');
    await tester.enterText(
      find.byKey(const Key('campo_observacoes')),
      'Quero reler com calma e prestar atenção nas pequenas coisas.',
    );
    await _pressionar(tester, 'Salvar livro');
    expect(find.text('O Pequeno Príncipe'), findsOneWidget);
    expect(find.text('Sua estante começa aqui'), findsNothing);

    await _pressionar(tester, 'Adicionar livro');
    await _preencher(tester, 'Dom Casmurro', 'Machado de Assis');
    await _pressionar(tester, 'Salvar livro');
    expect(find.text('Dom Casmurro'), findsOneWidget);

    await tester.tap(find.text('O Pequeno Príncipe'));
    await tester.pumpAndSettle();
    expect(find.text('por Antoine de Saint-Exupéry'), findsOneWidget);
    expect(find.text('por Machado de Assis'), findsNothing);
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
    await _voltar(tester);
    await tester.pumpAndSettle();
    expect(find.text('O Pequeno Príncipe (releitura)'), findsOneWidget);
    expect(find.text('Dom Casmurro'), findsOneWidget);
    expect(find.text('O Pequeno Príncipe'), findsNothing);
    tester.view.physicalSize = const Size(800, 600);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
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
