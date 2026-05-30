import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Converts a flutter_quill Delta (JSON) into PDF / HTML / plain text.
/// Works directly on the Delta operations so it is independent of the editor.
class ExportService {
  /// Parse the Delta JSON into a list of "blocks" of styled runs.
  static List<_Block> _parse(String contentJson) {
    List ops;
    try {
      ops = jsonDecode(contentJson) as List;
    } catch (_) {
      ops = [
        {'insert': '\n'}
      ];
    }

    final blocks = <_Block>[];
    var runs = <_Run>[];
    Map<String, dynamic> pendingBlockAttrs = {};

    void flushLine() {
      blocks.add(_Block(List.from(runs), Map.from(pendingBlockAttrs)));
      runs = [];
      pendingBlockAttrs = {};
    }

    for (final op in ops) {
      final insert = op['insert'];
      final attrs = (op['attributes'] as Map?)?.cast<String, dynamic>() ?? {};
      if (insert is! String) {
        // embed (image etc.) — represent as placeholder
        runs.add(_Run('[image]', {}));
        continue;
      }
      final parts = insert.split('\n');
      for (var i = 0; i < parts.length; i++) {
        final text = parts[i];
        if (text.isNotEmpty) {
          runs.add(_Run(text, attrs));
        }
        if (i < parts.length - 1) {
          // newline -> this op's block-level attributes belong to the line
          pendingBlockAttrs = attrs;
          flushLine();
        }
      }
    }
    if (runs.isNotEmpty) flushLine();
    if (blocks.isEmpty) blocks.add(_Block([], {}));
    return blocks;
  }

  // ---- Plain text ----------------------------------------------------------

  static String toPlainText(String contentJson) {
    final blocks = _parse(contentJson);
    final sb = StringBuffer();
    for (final b in blocks) {
      sb.writeln(b.runs.map((r) => r.text).join());
    }
    return sb.toString().trimRight();
  }

  // ---- HTML ----------------------------------------------------------------

  static String toHtml(String contentJson, {String title = 'Document'}) {
    final blocks = _parse(contentJson);
    final body = StringBuffer();
    String? listType;

    void closeList() {
      if (listType != null) {
        body.writeln(listType == 'ordered' ? '</ol>' : '</ul>');
        listType = null;
      }
    }

    for (final b in blocks) {
      final attrs = b.blockAttrs;
      final inner = b.runs.map((r) => _runToHtml(r)).join();
      final list = attrs['list'];
      if (list == 'ordered' || list == 'bullet') {
        final want = list == 'ordered' ? 'ordered' : 'bullet';
        if (listType != want) {
          closeList();
          body.writeln(want == 'ordered' ? '<ol>' : '<ul>');
          listType = want;
        }
        body.writeln('<li>$inner</li>');
        continue;
      } else {
        closeList();
      }

      final header = attrs['header'];
      final align = attrs['align'];
      final style = align != null ? ' style="text-align:$align"' : '';
      if (header == 1) {
        body.writeln('<h1$style>$inner</h1>');
      } else if (header == 2) {
        body.writeln('<h2$style>$inner</h2>');
      } else if (header == 3) {
        body.writeln('<h3$style>$inner</h3>');
      } else if (attrs['blockquote'] == true) {
        body.writeln('<blockquote$style>$inner</blockquote>');
      } else if (attrs['code-block'] == true) {
        body.writeln('<pre><code>$inner</code></pre>');
      } else {
        body.writeln('<p$style>${inner.isEmpty ? '&nbsp;' : inner}</p>');
      }
    }
    closeList();

    return '''<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>$title</title>
<style>
body{font-family:-apple-system,Segoe UI,Roboto,Arial,sans-serif;max-width:760px;margin:40px auto;padding:0 20px;line-height:1.6;color:#1B2330}
h1{font-size:28px}h2{font-size:22px}h3{font-size:18px}
blockquote{border-left:4px solid #7C4DFF;margin:0;padding-left:16px;color:#555}
pre{background:#f4f4f7;padding:12px;border-radius:8px;overflow:auto}
</style></head><body>
$body
</body></html>''';
  }

  static String _runToHtml(_Run r) {
    var text = const HtmlEscape().convert(r.text);
    final a = r.attrs;
    if (a['bold'] == true) text = '<strong>$text</strong>';
    if (a['italic'] == true) text = '<em>$text</em>';
    if (a['underline'] == true) text = '<u>$text</u>';
    if (a['strike'] == true) text = '<s>$text</s>';
    final styles = <String>[];
    if (a['color'] is String) styles.add('color:${a['color']}');
    if (a['background'] is String) {
      styles.add('background-color:${a['background']}');
    }
    if (styles.isNotEmpty) {
      text = '<span style="${styles.join(';')}">$text</span>';
    }
    if (a['link'] is String) text = '<a href="${a['link']}">$text</a>';
    return text;
  }

  // ---- Markdown ------------------------------------------------------------

  static String toMarkdown(String contentJson) {
    final blocks = _parse(contentJson);
    final out = StringBuffer();

    for (final b in blocks) {
      final attrs = b.blockAttrs;
      final inner = b.runs.map((r) => _runToMarkdown(r)).join();
      final header = attrs['header'];
      final list = attrs['list'];

      if (header == 1) {
        out.writeln('# $inner');
      } else if (header == 2) {
        out.writeln('## $inner');
      } else if (header == 3) {
        out.writeln('### $inner');
      } else if (list == 'bullet') {
        out.writeln('- $inner');
      } else if (list == 'ordered') {
        out.writeln('1. $inner');
      } else if (attrs['blockquote'] == true) {
        out.writeln('> $inner');
      } else if (attrs['code-block'] == true) {
        out.writeln('    $inner');
      } else {
        out.writeln(inner);
      }
    }
    return out.toString().trimRight();
  }

  static String _runToMarkdown(_Run r) {
    var text = r.text;
    final a = r.attrs;
    if (text.trim().isEmpty) return text;
    if (a['bold'] == true) text = '**$text**';
    if (a['italic'] == true) text = '*$text*';
    if (a['strike'] == true) text = '~~$text~~';
    if (a['code'] == true) text = '`$text`';
    if (a['link'] is String) text = '[$text](${a['link']})';
    return text;
  }

  // ---- PDF -----------------------------------------------------------------

  static Future<Uint8List> toPdf(String contentJson,
      {String title = 'Document'}) async {
    final blocks = _parse(contentJson);

    // تحميل خط عربي (Cairo) لعرض النص العربي بشكل صحيح في PDF.
    final arabic = await PdfGoogleFonts.cairoRegular();
    final arabicBold = await PdfGoogleFonts.cairoBold();

    final doc = pw.Document(title: title);
    final widgets = <pw.Widget>[];

    widgets.add(
      pw.Container(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          title,
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(font: arabicBold, fontSize: 24),
        ),
      ),
    );
    widgets.add(pw.Divider(thickness: 1.5));
    widgets.add(pw.SizedBox(height: 6));

    for (final b in blocks) {
      final attrs = b.blockAttrs;
      final header = attrs['header'];
      final align = attrs['align'];
      double fontSize = 12;
      bool boldBlock = false;
      if (header == 1) {
        fontSize = 20;
        boldBlock = true;
      } else if (header == 2) {
        fontSize = 16;
        boldBlock = true;
      } else if (header == 3) {
        fontSize = 14;
        boldBlock = true;
      }

      final spans = b.runs.map((r) {
        final a = r.attrs;
        final isBold = (a['bold'] == true) || boldBlock;
        return pw.TextSpan(
          text: r.text,
          style: pw.TextStyle(
            font: isBold ? arabicBold : arabic,
            fontSize: fontSize,
            fontStyle:
                (a['italic'] == true) ? pw.FontStyle.italic : null,
            decoration: (a['underline'] == true)
                ? pw.TextDecoration.underline
                : null,
          ),
        );
      }).toList();

      final list = attrs['list'];
      String? bullet;
      if (list == 'bullet') bullet = '•  ';
      if (list == 'ordered') bullet = '-  ';

      final isQuote = attrs['blockquote'] == true;

      widgets.add(
        pw.Container(
          alignment: _pdfAlign(align),
          margin: const pw.EdgeInsets.only(bottom: 6),
          padding: isQuote
              ? const pw.EdgeInsets.only(right: 10)
              : pw.EdgeInsets.zero,
          decoration: isQuote
              ? const pw.BoxDecoration(
                  border: pw.Border(
                      right: pw.BorderSide(
                          color: PdfColors.deepPurple, width: 3)),
                )
              : null,
          child: pw.RichText(
            textDirection: pw.TextDirection.rtl,
            text: pw.TextSpan(children: [
              if (bullet != null)
                pw.TextSpan(
                    text: bullet, style: pw.TextStyle(font: arabic)),
              ...spans,
            ]),
          ),
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabic, bold: arabicBold),
        margin: const pw.EdgeInsets.all(40),
        build: (_) => widgets,
      ),
    );

    return doc.save();
  }

  static pw.Alignment? _pdfAlign(dynamic align) {
    switch (align) {
      case 'center':
        return pw.Alignment.center;
      case 'left':
        return pw.Alignment.centerLeft;
      case 'right':
        return pw.Alignment.centerRight;
      default:
        // الافتراضي للعربية: محاذاة لليمين.
        return pw.Alignment.centerRight;
    }
  }

  /// Convert plain text into a minimal Delta for import.
  static String plainTextToDelta(String text) {
    final normalized = text.endsWith('\n') ? text : '$text\n';
    return jsonEncode([
      {'insert': normalized}
    ]);
  }
}

class _Run {
  final String text;
  final Map<String, dynamic> attrs;
  _Run(this.text, this.attrs);
}

class _Block {
  final List<_Run> runs;
  final Map<String, dynamic> blockAttrs;
  _Block(this.runs, this.blockAttrs);
}
