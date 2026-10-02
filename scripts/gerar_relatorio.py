"""Gera o relatório de oito páginas com as evidências da versão verificada."""

from pathlib import Path
from xml.sax.saxutils import escape
import hashlib
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / '.tools' / 'python'))

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfgen import canvas
from reportlab.platypus import Paragraph, Table, TableStyle
from PIL import Image

OUT = ROOT / 'relatorio'
GREEN = colors.HexColor('#295B46')
INK = colors.HexColor('#25372D')
LIGHT = colors.HexColor('#E7EFE8')
W, H = A4
M = 42
CW = W - M * 2


def ler_log(nome):
    path = OUT / 'logs' / f'{nome}.txt'
    raw = path.read_bytes()
    return raw.decode('utf-16' if raw.startswith(b'\xff\xfe') else 'utf-8-sig')


def git(*args):
    return subprocess.check_output(
        ['git', '-c', f'safe.directory={ROOT.as_posix()}', *args],
        cwd=ROOT, text=True,
    ).strip()


def main():
    versao = ler_log('versao')
    analise = ler_log('analise')
    testes = ler_log('testes')
    build = ler_log('build')
    if 'No issues found!' not in analise or 'All tests passed!' not in testes:
        raise SystemExit('Análise e testes precisam passar antes de gerar o relatório.')
    if not re.search(r'Built .*app-release\.apk', build):
        raise SystemExit('O log precisa confirmar o APK gerado.')

    apk = ROOT / 'build/app/outputs/flutter-apk/app-release.apk'
    if not apk.is_file():
        raise SystemExit('O APK não foi encontrado.')
    sha_apk = hashlib.sha256(apk.read_bytes()).hexdigest()
    tag = 'm1-v1.0.0'
    commit = git('rev-parse', f'{tag}^{{commit}}')
    flutter = re.search(r'Flutter ([\d.]+)', versao).group(1)
    dart = re.search(r'Dart ([\d.]+)', versao).group(1)
    tamanho_apk = apk.stat().st_size / (1024 * 1024)
    metadata = {
        'aplicativo': 'Minha Estante',
        'estudante': 'Kayann Leandro de Sá',
        'ra': '0031623',
        'turma_informada': '4º período',
        'data': '2026-10-02',
        'commit': commit,
        'tag': tag,
        'flutter': flutter,
        'dart': dart,
        'apk': 'build/app/outputs/flutter-apk/app-release.apk',
        'sha256_apk': sha_apk,
        'evidencias': 'Capturas da renderização em testes de widget; não de um aparelho.',
        'repositorio_remoto': 'https://github.com/Sc00pex/M1_trabalho_final.git',
    }
    (OUT / 'versao.json').write_text(json.dumps(metadata, ensure_ascii=False, indent=2), encoding='utf-8')

    pdf = canvas.Canvas(str(OUT / 'relatorio_final.pdf'), pagesize=A4)
    pdf.setTitle('Minha Estante — Relatório do trabalho final')
    pdf.setAuthor('Kayann Leandro de Sá; assistência do Codex declarada no relatório')
    y = 0
    md = []

    def pagina(titulo, numero):
        nonlocal y
        if numero > 1:
            pdf.showPage()
        pdf.setFillColor(GREEN)
        pdf.rect(0, H - 10, W, 10, fill=1, stroke=0)
        pdf.setFont('Helvetica', 9)
        pdf.drawString(M, H - 34, 'MINHA ESTANTE  /  DESENVOLVIMENTO MOBILE I')
        pdf.setFillColor(INK)
        pdf.setFont('Helvetica-Bold', 20)
        pdf.drawString(M, H - 70, titulo)
        pdf.setFont('Helvetica', 8)
        pdf.setFillColor(colors.HexColor('#5E6C63'))
        pdf.drawString(M, 25, 'Kayann Leandro de Sá  •  RA 0031623  •  02/10/2026')
        pdf.drawRightString(W - M, 25, f'{numero} / 8')
        y = H - 94
        md.append(f'\n# {titulo}\n')

    def paragrafo(texto, size=10.5, gap=10, bold=False):
        nonlocal y
        style = ParagraphStyle('texto', fontName='Helvetica-Bold' if bold else 'Helvetica',
                               fontSize=size, leading=size * 1.42, textColor=INK)
        item = Paragraph(texto, style)
        _, height = item.wrap(CW, H)
        if y - height < 48:
            raise ValueError(f'Texto ultrapassou a página: {texto[:80]}')
        item.drawOn(pdf, M, y - height)
        y -= height + gap
        md.append(re.sub(r'<[^>]+>', '', texto) + '\n')

    def subtitulo(texto):
        paragrafo(texto, size=12, gap=8, bold=True)

    def codigo(texto, size=8.6):
        nonlocal y
        linhas = texto.splitlines()
        altura = len(linhas) * (size + 4) + 18
        if y - altura < 48:
            raise ValueError('Bloco de código ultrapassou a página.')
        pdf.setFillColor(LIGHT)
        pdf.roundRect(M, y - altura, CW, altura, 7, fill=1, stroke=0)
        pdf.setFillColor(INK)
        pdf.setFont('Courier', size)
        for i, linha in enumerate(linhas):
            pdf.drawString(M + 10, y - 14 - i * (size + 4), linha)
        y -= altura + 12
        md.append('```text\n' + texto + '\n```\n')

    def imagens(nomes, max_altura=390):
        nonlocal y
        gap = 14
        largura_celula = (CW - gap * (len(nomes) - 1)) / len(nomes)
        altura = 0
        for i, nome in enumerate(nomes):
            arquivo = OUT / 'evidencias' / f'{nome}.png'
            with Image.open(arquivo) as imagem:
                iw, ih = imagem.size
            escala = min(largura_celula / iw, max_altura / ih)
            dw, dh = iw * escala, ih * escala
            x = M + i * (largura_celula + gap) + (largura_celula - dw) / 2
            pdf.drawImage(str(arquivo), x, y - dh, dw, dh)
            pdf.setStrokeColor(colors.HexColor('#D6DDD6'))
            pdf.rect(x, y - dh, dw, dh, fill=0, stroke=1)
            altura = max(altura, dh)
            md.append(f'![{nome}](evidencias/{nome}.png)\n')
        y -= altura + 14

    pagina('Relatório do trabalho final', 1)
    paragrafo('Desenvolvimento Mobile I — Catálogo Pessoal em Flutter', size=13)
    paragrafo('Minha Estante', size=26, bold=True, gap=20)
    paragrafo('Kayann Leandro de Sá<br/>Matrícula: 0031623<br/>Turma informada: 4º período<br/>2º semestre de 2026', size=12, gap=24)
    subtitulo('1. Identificação e resumo')
    paragrafo('<b>Domínio e problema.</b> Minha Estante é um catálogo pessoal de livros. A ideia é reunir, em um lugar simples, o que a pessoa quer ler, está lendo ou já leu, junto com pequenas anotações. O público é quem gosta de ler e quer acompanhar suas leituras sem preencher um cadastro complicado.')
    paragrafo('<b>Fluxo principal.</b> A tela inicial mostra a coleção. Ao tocar em um livro, abre-se o detalhe daquele item. O botão Adicionar livro leva ao formulário de criação; Editar livro, no detalhe, abre o mesmo formulário com os dados preenchidos. Depois de salvar a edição, o detalhe é atualizado. Ao voltar à lista, o cartão também mostra a mudança.')
    paragrafo('<b>Escopo do M1.</b> Estão implementados lista dinâmica, estado vazio, detalhe, criação, edição, validação, tema e adaptação de layout. Os dados ficam no estado local durante a execução. Salvar os livros entre sessões seria uma evolução futura e não faz parte desta entrega.')
    paragrafo('<b>Sobre as evidências.</b> As figuras foram geradas pelo renderer do Flutter nos testes de widget. Os tamanhos indicados são pixels lógicos. Não são capturas de um celular ou emulador. O APK foi compilado separadamente.', size=9.5)

    pagina('Versão e requisitos', 2)
    subtitulo('2. Repositório, versão e execução')
    paragrafo(f'<b>Versão:</b> 1.0.0+1 · Flutter {flutter} · Dart {dart}<br/><b>Tag dos fontes e evidências:</b> {tag}<br/><b>Commit do projeto:</b> {commit}<br/><b>Repositório:</b> <link href="https://github.com/Sc00pex/M1_trabalho_final" color="#295B46">https://github.com/Sc00pex/M1_trabalho_final</link><br/><b>Cópia local:</b> entrega/minha-estante.bundle.', size=9, gap=8)
    paragrafo(f'<b>Artefato Android:</b> app-release.apk, APK release, {tamanho_apk:.1f} MiB. Geração confirmada no log de build. Assinado com chave de desenvolvimento, para instalação e avaliação. Android mínimo: 7.0 (API 24).', size=9, gap=8)
    codigo(f'git clone https://github.com/Sc00pex/M1_trabalho_final.git\ncd M1_trabalho_final\ngit checkout {tag}\nflutter pub get\nflutter analyze\nflutter test\nflutter run\nflutter build apk --release', size=8)
    paragrafo('É preciso ter Flutter e Android SDK configurados e as licenças Android aceitas. A tag identifica os fontes, testes, capturas e logs usados aqui. O PDF e o registro de versão são incluídos depois, em um commit de documentação. O SHA-256 do APK está em relatorio/versao.json. A cópia Git também permite reproduzir a versão.', size=8.5, gap=8)
    subtitulo('3. Matriz dos 13 critérios')
    linhas = [
        ('1', 'Identificação, objetivo e fluxo', 'p. 1, seção 1', 'README.md; app.dart'),
        ('2', 'Repositório, versão e instruções', 'p. 2, seção 2', 'README.md; versao.json'),
        ('3', 'Execução e artefato Android', 'p. 2 e 7', 'logs/build.txt; APK'),
        ('4', 'Duas ou mais telas e navegação', 'p. 3, evidência B', 'screens/; Navigator'),
        ('5', 'Coleção dinâmica e estado vazio', 'p. 3, evidência A', 'CatalogoPage'),
        ('6', 'Detalhe do item selecionado', 'p. 3, evidência B', 'DetalheLivroPage'),
        ('7', 'Formulário e validação', 'p. 4, evidência C', 'FormularioLivroPage'),
        ('8', 'Criação e edição no estado local', 'p. 5, evidência D', 'CatalogoPage; Livro.id'),
        ('9', 'Modelo e widgets organizados', 'p. 7, estrutura', 'models/; widgets/'),
        ('10', 'Dois espaços sem overflow', 'p. 6, evidência E', 'ConteudoCentral; testes'),
        ('11', 'Tema e acessibilidade', 'p. 6, verificações', 'AppTheme; LivroCard'),
        ('12', 'Análise e teste de widget', 'p. 7, saídas reais', 'test/catalogo_test.dart'),
        ('13', 'Decisões, fontes e autoria', 'p. 8, seção 6', 'README.md; relatório'),
    ]
    ts = ParagraphStyle('tabela', fontName='Helvetica', fontSize=7.6, leading=10)
    dados = [[Paragraph(escape(c), ts) for c in linha]
             for linha in [('Nº', 'Requisito', 'Evidência no PDF', 'Arquivo ou classe'), *linhas]]
    tabela = Table(dados, colWidths=[23, 192, 112, CW - 327])
    tabela.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), LIGHT),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('LINEBELOW', (0, 0), (-1, -1), 0.4, colors.HexColor('#DDE4DC')),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
    ]))
    _, th = tabela.wrap(CW, H)
    if y - th < 48:
        raise ValueError('A matriz ultrapassou a página.')
    tabela.drawOn(pdf, M, y - th)
    md.append('| Nº | Requisito | Evidência | Arquivo ou classe |\n|---|---|---|---|')
    md.extend('| ' + ' | '.join(linha) + ' |' for linha in linhas)

    pagina('Coleção e navegação', 3)
    subtitulo('4. Evidências visuais e funcionais')
    paragrafo('<b>Evidência A — estado vazio e coleção.</b> O teste inicia uma sessão sem livros e registra a primeira tela. Depois cadastra O Pequeno Príncipe e Dom Casmurro. A lista passa a mostrar dois itens, sem dados fixos no código.')
    paragrafo('<b>Evidência B — navegação e detalhe.</b> Na coleção, o teste toca em O Pequeno Príncipe. O destino mostra o título, o autor e as observações desse livro; não os de Dom Casmurro. Origem: CatalogoPage. Destino: DetalheLivroPage.')
    imagens(['01_vazio', '05_colecao', '06_detalhe'], max_altura=365)
    paragrafo('<b>Figuras A1, A2 e B1, da esquerda para a direita.</b> Estante vazia; coleção após duas criações; detalhe do item selecionado. As três imagens usam 360 × 800 pixels lógicos.', size=9)
    paragrafo('O botão Adicionar livro abre o formulário. O cartão inteiro é uma área de toque e recebe um rótulo semântico com título, autor e situação da leitura. A seta Voltar retorna à tela anterior.', size=9.5)

    pagina('Formulário e validação', 4)
    subtitulo('Evidência C — entrada inválida e envio válido')
    paragrafo('O formulário usa Form e TextFormField. Título e autor são obrigatórios. Valores compostos somente por espaços também são recusados, pois a validação usa trim(). Situação da leitura e observações completam o cadastro; as observações são opcionais.')
    imagens(['02_validacao', '03_formulario_valido'], max_altura=435)
    paragrafo('<b>Figuras C1 e C2.</b> À esquerda, a tentativa inválida mostra “Informe o título do livro” e “Informe o autor do livro”. À direita, os campos foram preenchidos com dados válidos. O envio desse formulário é confirmado pela coleção na figura D1, na página seguinte.', size=9)
    paragrafo('O teste também verifica que a rota não é encerrada com campos inválidos. Os rótulos continuam visíveis após o preenchimento. Os campos seguem a ordem título, autor, leitura e observações; o formulário rola quando falta altura.', size=9.5)

    pagina('Criação e edição', 5)
    subtitulo('Evidência D — alterações refletidas no estado local')
    paragrafo('A sequência começa com a criação de O Pequeno Príncipe. Depois da inclusão de Dom Casmurro, o primeiro livro é aberto para edição. O título muda para O Pequeno Príncipe (releitura) e a leitura para Já li. Ao voltar do detalhe, a coleção mostra os novos valores e preserva o segundo livro.')
    imagens(['04_criacao', '07_detalhe_editado', '08_colecao_editada_360'], max_altura=365)
    paragrafo('<b>Figuras D1, D2 e D3.</b> Livro criado; detalhe atualizado depois de salvar; lista atualizada ao voltar. A comparação do título e da etiqueta de leitura mostra o resultado das duas operações.', size=9)
    paragrafo('<b>Como o estado é atualizado.</b> O formulário devolve um objeto Livro por Navigator.pop. Na criação, CatalogoPage adiciona esse objeto à lista. Na edição, o identificador do livro é mantido; ao receber o resultado do detalhe, a tela substitui apenas o item correspondente com setState.')
    paragrafo('Cancelar o formulário não modifica a coleção. Esse comportamento também foi verificado por um teste separado. Os livros permanecem disponíveis durante a sessão; não existe persistência em arquivo ou banco de dados.', size=9.5)

    pagina('Layout e acessibilidade', 6)
    subtitulo('Evidência E — o mesmo conteúdo em dois espaços')
    paragrafo('A coleção editada é renderizada primeiro em 360 × 800 e depois em 800 × 600 pixels lógicos. Os dados são os mesmos. ConteudoCentral limita o conteúdo a 760 pixels; a lista usa rolagem e os textos dos cartões podem quebrar linha.')
    imagens(['08_colecao_editada_360', '09_colecao_editada_800'], max_altura=335)
    paragrafo('<b>Figuras E1 e E2.</b> A mesma coleção no espaço estreito e no espaço largo. O botão de adicionar fica na área inferior do Scaffold, acima da qual aparece a mensagem de confirmação. A interface não registrou exceção de overflow.', size=9)
    subtitulo('Acessibilidade efetivamente verificada')
    paragrafo('Os testes executaram androidTapTargetGuideline, labeledTapTargetGuideline e textContrastGuideline no estado vazio e na coleção, nos dois tamanhos. As verificações passaram. Os textos também foram ampliados a 200% com título e autor longos; lista, detalhe e formulário continuaram acessíveis por rolagem.', size=9.5)
    paragrafo('Na figura E1, o cartão tem rótulo semântico com título, autor e leitura. O teste também abre o detalhe pela ação semântica de toque do cartão. Na figura C2, os campos têm rótulos permanentes. Botões têm texto e áreas de toque verificadas. As cores vêm de um tema Material 3. Não foi feita avaliação manual com TalkBack em dispositivo físico.', size=9.5)

    pagina('Organização e qualidade', 7)
    subtitulo('5. Estrutura e componentização')
    codigo('lib/main.dart                 entrada\nlib/app.dart                  MaterialApp em pt-BR\nlib/models/livro.dart          modelo e enum de leitura\nlib/screens/                  lista, detalhe e formulário\nlib/widgets/                  cartão, status e largura\nlib/theme/app_theme.dart       tema\ntest/catalogo_test.dart        quatro testes de widget', size=9)
    paragrafo('<b>Widget extraído.</b> StatusLivro cuida da etiqueta de leitura, usada tanto no cartão da lista quanto no detalhe. A extração evita repetir estilo e espaçamento. ConteudoCentral reúne a margem e o limite de largura das três telas.')
    subtitulo('Análise, teste e build — saídas reais')
    analise_linha = next(l.strip() for l in analise.splitlines() if 'No issues found!' in l)
    testes_linhas = [l.strip() for l in testes.splitlines() if re.match(r'\d\d:\d\d \+\d', l.strip()) and 'loading ' not in l]
    build_linha = next(l.strip().replace('√ ', '').replace('✓ ', '') for l in build.splitlines() if re.search(r'Built .*app-release\.apk', l))
    codigo(f'$ flutter analyze\n{analise_linha}\n\n$ flutter test --reporter=expanded\n' + '\n'.join(testes_linhas) + '\n\n$ flutter build apk --release\n' + build_linha, size=7.7)
    paragrafo('Os logs completos estão em relatorio/logs. A execução usada para as imagens acrescenta --dart-define=GERAR_EVIDENCIAS=true ao comando de testes, para gravar as capturas; as asserções são as mesmas do teste normal.', size=9)
    paragrafo('<b>Teste principal.</b> “estado vazio, validação, criação, detalhe e edição na coleção” verifica toda a sequência mostrada nas figuras. Os outros três testes cobrem cancelamento e acessibilidade em 360 × 800 e 800 × 600, com texto a 200% e espaço reduzido pelo teclado.', size=9.5)
    paragrafo(f'<b>APK confirmado:</b> {tamanho_apk:.1f} MiB; pacote br.com.kayann.minha_estante. O hash completo do arquivo está em relatorio/versao.json. A compilação foi verificada; não houve instalação em aparelho físico.', size=9)

    pagina('Decisões, fontes e autoria', 8)
    subtitulo('6. Decisão técnica')
    paragrafo('Foi usado setState com uma lista de Livro na tela do catálogo. Para três telas e um estado pequeno, essa escolha deixa o fluxo de atualização fácil de acompanhar e dispensa bibliotecas adicionais. Como consequência, o catálogo é reiniciado ao encerrar a execução. A identificação por id permite editar um livro sem depender de seu título.')
    subtitulo('Dificuldade e solução observadas')
    paragrafo('Nos primeiros testes, a mensagem de confirmação cobria o botão de adicionar, e uma composição fixa estourava o espaço com texto ampliado. A investigação comparou o resultado do teste e a posição dos controles. O botão foi colocado no bottomNavigationBar e o cabeçalho passou a fazer parte da lista com rolagem. A mensagem é encerrada antes de abrir outra tela. Os testes do fluxo e dos dois tamanhos passaram depois dos ajustes.')
    subtitulo('Fontes e recursos externos')
    fontes = [
        ('Flutter — formulários e validação', 'https://docs.flutter.dev/cookbook/forms/validation'),
        ('Flutter — navegação entre telas', 'https://docs.flutter.dev/cookbook/navigation/navigation-basics'),
        ('Flutter — acessibilidade', 'https://docs.flutter.dev/ui/accessibility'),
        ('Flutter — testes', 'https://docs.flutter.dev/testing/overview'),
    ]
    for titulo, url in fontes:
        paragrafo(f'<link href="{url}" color="#295B46">{titulo}</link><br/>{url}', size=8.5, gap=6)
    paragrafo('Recursos do aplicativo: Flutter, flutter_localizations, ícones Material e Roboto do SDK. flutter_test e flutter_lints foram usados na verificação. Nenhuma imagem externa de livro foi utilizada. ReportLab gerou o PDF; PyMuPDF e pypdf auxiliaram a conferência do documento.', size=9, gap=8)
    paragrafo('<b>Contribuições.</b> Houve assistência do Codex na elaboração e revisão do código, dos testes, da documentação e deste relatório. O tema foi confirmado por Kayann, que também forneceu nome, matrícula e período. Essa contribuição é informada para deixar a origem do trabalho transparente.', size=9, gap=10)
    subtitulo('Declaração')
    paragrafo('Declaro que este relatório descreve a versão identificada do meu projeto, que as fontes e contribuições externas foram informadas e que não publiquei chaves, senhas, tokens ou outros segredos.', size=9.5)
    paragrafo('Kayann Leandro de Sá', size=11, bold=True)
    pdf.save()
    (OUT / 'relatorio_final.md').write_text('\n'.join(md), encoding='utf-8')
    print(f'Relatório gerado: {OUT / "relatorio_final.pdf"}')
    print(f'Commit: {commit}; APK SHA-256: {sha_apk}')


if __name__ == '__main__':
    main()
