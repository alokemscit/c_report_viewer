import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import 'common_pdf_viewer.dart';
import 'dart:html' as html;
class CPDFGenerator {
  final BuildContext context;
  final Font? font;
  final List<pw.Widget> header;
  final List<pw.Widget> footer;
  final List<pw.Widget> body;
  final void Function() fun;
  final PageOrientation? orientation;
  final bool isHeaderSpace;
  final bool isHeaderAllPage;
  final pw.EdgeInsetsGeometry margin;
  final bool isShowPageNo;
  final String reportTitle;
  CPDFGenerator(
      {required this.context,
      this.reportTitle = 'Report',
      required this.font,
      required this.header,
      required this.body,
      required this.footer,
      void Function()? fun,
      this.margin = const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      this.orientation = PageOrientation.portrait,
      this.isHeaderSpace = true,
      this.isHeaderAllPage = true,
      this.isShowPageNo = false})
      : fun = fun ?? (() {});
  String getDate() {
    return DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());
  }

  pw.Widget _header() => pw.Column(children: [
        pw.Column(
            // mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: header //[

            ),
        pw.SizedBox(height: isHeaderSpace ? 15 : 0),
        pw.Divider(height: isHeaderSpace ? 2 : 0),
        pw.SizedBox(height: isHeaderSpace ? 15 : 0),
      ]);
  pw.Widget _footer() => pw.Column(children: [
        pw.Divider(height: 2),
        pw.SizedBox(height: 4),
        pw.Column(children: footer),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
          pwTextCaption('Printed Date', font, 8),
          pw.SizedBox(width: 8),
          pwTextCaption(getDate(), font, 7.5)
        ]),
        pw.SizedBox(height: 4),
      ]);

  // ignore: non_constant_identifier_names
  void ShowReport() async {
    pw.Document d = await _generatePDfDocument(_header(), body, _footer(),
        font!, margin, orientation, isHeaderAllPage);

    // ignore: use_build_context_synchronously
    _openPdFromDocFile(d, context, reportTitle, fun);
  }
}

Future<void> _openPdFromDocFile(Document pdfFile, BuildContext context,
    [String title = 'Report', Function()? fun]) async {
  // final bytesData = await fetchPdfBytes(urls);
  final bytes = await _convertPdfToBytes(pdfFile);
  String base64Data = base64Encode(bytes);
  // ignore: use_build_context_synchronously
  await CReportVewer.showReport(context, base64Data);

  if (fun != null) {
    fun();
  }
  // }
}

Future<pw.Document> _generatePDfDocument(
  pw.Widget header,
  List<pw.Widget> body,
  pw.Widget footer,
  pw.Font font, [
  pw.EdgeInsetsGeometry margin =
      const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
  PageOrientation? orientation = PageOrientation.portrait,
  bool isShowHeaderAllPage = true,
  bool isShowPageNo = false,
]) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      maxPages: 2000,
      orientation: orientation,
      pageFormat: orientation == PageOrientation.portrait
          ? PdfPageFormat.a4
          : PdfPageFormat(PdfPageFormat.a4.height,
              PdfPageFormat.a4.width), //PdfPageFormat.a4,
      margin: margin,
      header: (pw.Context context) {
        return isShowHeaderAllPage
            ? header
            : (context.pageNumber == 1 ? header : pw.SizedBox.shrink());
      },
      footer: (context) {
        return pw.Column(children: <pw.Widget>[
          footer,
          if (isShowPageNo) // ,
            pwTextOne(
                font,
                '',
                'Page : ${context.pageLabel} of ${context.pagesCount}',
                7.5,
                pwMainAxisAlignmentEnd)
          //pw.Text(context.pageLabel),
        ]);
      },
      build: (context) => body,
    ),
  );

  return pdf;
}

Future<Uint8List> _convertPdfToBytes(Document pdf) async {
  // Save the PDF document as bytes
  return await pdf.save();
}

void openPdFromFile(Document pdfFile,
    [String title = 'Report Viewer', Function()? fun]) async {
  // final bytesData = await fetchPdfBytes(urls);
  final bytes = await _convertPdfToBytes(pdfFile);
  String base64Data = base64Encode(bytes);

  String dataUri = 'data:application/pdf;base64,$base64Data';
//report-title
  final h4 = html.window.document.getElementById('report-title');
  if (h4 != null) {
    h4.setInnerHtml(title);
  }
  final div = html.window.document.getElementById('pdf-container');
  if (div != null) {
    //print('object');
    final html.NodeValidatorBuilder htmValidator = html.NodeValidatorBuilder()
      ..allowElement('iframe', attributes: ['src', 'width', 'height']);

    div.setInnerHtml(
        '<iframe src= "$dataUri" width="100%" height="100%"></iframe>',
        validator: htmValidator);
    //  print(div.innerHtml);
    final bb = html.window.document.getElementById('triggerPdfViewer');
    if (bb != null) {
      //print('object');
      bb.dispatchEvent(html.MouseEvent('click'));
      if (fun != null) {
        fun();
      }
    } else {
      if (fun != null) {
        fun();
      }
    }
  } else {
    if (fun != null) {
      fun();
    }
  }
}

Future<pw.Font> CPwLoadFont(String path) async {
  final data = await rootBundle.load(path);
  return pw.Font.ttf(data);
}

Future<pw.Font> pwFontloader(String path) async {
  final data = await rootBundle.load(path);
  return pw.Font.ttf(data);
}

pw.Widget pwCenter(pw.Widget child) => pw.Center(child: child);
pw.Widget pwTableColumnHeader(String name, pw.Font? font,
        [pw.Alignment aligment = pw.Alignment.centerLeft,
        double fontSize = 12,
        pw.FontWeight fontWeight = pw.FontWeight.bold]) =>
    pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: pw.Align(
            alignment: aligment,
            child: pw.Text(name,
                style: pw.TextStyle(
                    fontSize: fontSize, fontWeight: fontWeight, font: font))));

pw.SizedBox pwSizedBoxWithWidth([double weight = 0, pw.Widget? child]) =>
    pw.SizedBox(width: weight, child: child);

pw.SizedBox pwSizedBox([double height = 0, double weight = 0]) =>
    pw.SizedBox(height: height, width: weight);
pw.Widget pwSizedBoxWidth([double width = 0, pw.Widget? child]) {
  return pw.SizedBox(
    width: width,
    child: child ?? pw.SizedBox.shrink(),
  );
}

pw.BoxDecoration pwBoxDecorationFooter =
    const pw.BoxDecoration(color: PdfColors.grey100);

pw.TableRow pwTableRow(List<pw.Widget> children,
        [pw.BoxDecoration decoration = const pw.BoxDecoration(
          color: PdfColors.white,
        )]) =>
    pw.TableRow(
        verticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: children,
        decoration: decoration);
pw.Alignment pwAligmentRight = pw.Alignment.centerRight;
pw.Alignment pwAligmentLeft = pw.Alignment.centerLeft;
pw.Alignment pwAligmentCenter = pw.Alignment.center;
pw.MainAxisAlignment pwMainAxisAlignmentStart = pw.MainAxisAlignment.start;
pw.MainAxisAlignment pwMainAxisAlignmentEnd = pw.MainAxisAlignment.end;
pw.MainAxisAlignment pwMainAxisAlignmentCenter = pw.MainAxisAlignment.center;

pw.CrossAxisAlignment pwCrossAxisAligmentCenter = pw.CrossAxisAlignment.center;

pw.MainAxisAlignment pwMainAxisAlignmentSpaceBetween =
    pw.MainAxisAlignment.spaceBetween;
pw.Widget pwTableCell2(
  String name,
  pw.Font? font, [
  pw.Alignment aligment = pw.Alignment.centerLeft,
  double fontSize = 9,
  pw.FontWeight fontWeight = pw.FontWeight.bold,
  PdfColor pdfColor = PdfColors.black,
  double vericalPadding = 8,
]) =>
    pw.Padding(
        padding:
            pw.EdgeInsets.symmetric(horizontal: 4, vertical: vericalPadding),
        child: pw.Align(
            alignment: aligment,
            child: pw.Text(name,
                style: pw.TextStyle(
                    fontSize: fontSize, font: font, color: pdfColor))));

pw.Widget pwTableCell(String name, pw.Font? font,
        [pw.Alignment aligment = pw.Alignment.centerLeft,
        double fontSize = 9,
        pw.FontWeight fontWeight = pw.FontWeight.bold,
        PdfColor pdfColor = PdfColors.black,
        double verticalPadding = 2]) =>
    pw.Padding(
        padding:
            pw.EdgeInsets.symmetric(horizontal: 4, vertical: verticalPadding),
        child: pw.Align(
            alignment: aligment,
            child: pw.Text(name,
                style: pw.TextStyle(
                    fontSize: fontSize, font: font, color: pdfColor))));
pw.Widget pwTableCellBlackLine() => pw.Row(children: [
      pw.Expanded(child: pw.Container(color: PdfColors.black, height: 0.5))
    ]);

pw.Widget pwTextCaption(
  String name,
  pw.Font? font, [
  double fontSize = 9,
  pw.FontWeight fontWeight = pw.FontWeight.bold,
  pw.Alignment aligment = pw.Alignment.centerLeft,
  PdfColor color = PdfColors.black,
]) =>
    pw.Align(
        alignment: aligment,
        child: pw.Text(name,
            style: pw.TextStyle(
                fontSize: fontSize,
                font: font,
                color: color,
                fontWeight: fontWeight)));

Map<int, pw.TableColumnWidth> pwTableColumnWidthGenerator(
    List<int> columnWidth) {
  final Map<int, pw.TableColumnWidth> columnWidthMap = {};

  for (int i = 0; i < columnWidth.length; i++) {
    columnWidthMap[i] = pw.FlexColumnWidth(columnWidth[i].toDouble());
  }
  return columnWidthMap;
}

pw.Widget pwGenerateTable(List<int> columnWidth, List<pw.Widget> headerRow,
        List<pw.TableRow> bodyChildren,
        [bool is_border = true]) =>
    pw.Table(
      border: is_border
          ? pw.TableBorder.all(color: PdfColors.black)
          : const pw.TableBorder(),
      columnWidths: pwTableColumnWidthGenerator(columnWidth),
      children: [
        headerRow.isEmpty
            ? const pw.TableRow(children: [])
            : pw.TableRow(
                decoration: is_border
                    ? const pw.BoxDecoration(color: PdfColors.grey300)
                    : const pw.BoxDecoration(),
                children: headerRow),
        ...bodyChildren
      ],
    );

pw.Widget pwText2Col(pw.Font? font, String caption1, String text1,
        String caption2, String text2,
        [double fontSize = 9]) =>
    pw.Table(columnWidths: pwTableColumnWidthGenerator([70, 50]), children: [
      pw.TableRow(children: [
        pw.Row(children: [
          pwTextCaption(caption1, font, fontSize),
          pwTextCaption(text1, font, fontSize, pw.FontWeight.normal),
        ]),
        pw.Row(children: [
          pw.Spacer(),
          pwTextCaption(caption2, font, fontSize),
          pwTextCaption(text2, font, fontSize, pw.FontWeight.normal),
        ]),
      ])
    ]);
pw.Widget pwHeight([double height = 8]) => pw.SizedBox(height: height);
pw.Widget pwTextOne(pw.Font? font, String caption, String text,
        [double fontSize = 9,
        pw.MainAxisAlignment aligment = pw.MainAxisAlignment.center]) =>
    pw.Row(mainAxisAlignment: aligment, children: [
      pw.Text(caption,
          style: pw.TextStyle(
              fontSize: fontSize,
              font: font,
              //color: color,
              fontWeight: pw.FontWeight.bold)),
      pw.Text(text,
          style: pw.TextStyle(
              fontSize: fontSize,
              font: font,
              //color: color,
              fontWeight: pw.FontWeight.bold))
    ]);

pw.Widget pwLogo(pw.MemoryImage image,
        [double width = 150, double height = 80]) =>
    pw.Image(image, width: width, height: height);

Future<pw.MemoryImage> pwLoadImageWidget(String logoImage) async {
  // Load the image from assets

  final imageData = await rootBundle.load(logoImage);

  // Convert the image data to a MemoryImage
  final image = pw.MemoryImage(
    imageData.buffer.asUint8List(),
  );
  return image;
}

pw.Widget pwTableCell2Column(String name1, String name2, pw.Font? font,
        [pw.Alignment aligment = pw.Alignment.centerLeft,
        double fontSize = 9,
        pw.FontWeight fontWeight = pw.FontWeight.bold]) =>
    pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: pw.Column(
            crossAxisAlignment: aligment == pw.Alignment.centerLeft
                ? pw.CrossAxisAlignment.start
                : aligment == pw.Alignment.center
                    ? pw.CrossAxisAlignment.center
                    : pw.CrossAxisAlignment.end,
            children: [
              pw.Text(name1,
                  style: pw.TextStyle(fontSize: fontSize, font: font)),
              pw.Text(name2,
                  style: pw.TextStyle(fontSize: fontSize, font: font))
            ]));

pw.Widget pwTableCellUnderLine() => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(children: [
      pw.Expanded(
          child: pw.Container(height: 0.2, color: const PdfColor.fromInt(0)))
    ]));
pw.FontWeight pwFontWigthBold = pw.FontWeight.bold;

pw.Widget pwColumn(
  List<pw.Widget> list,
) =>
    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: list);

pw.Widget pwRow(List<pw.Widget> list,
        [pw.MainAxisAlignment ma = pw.MainAxisAlignment.start,
        pw.CrossAxisAlignment ca = pw.CrossAxisAlignment.start]) =>
    pw.Row(mainAxisAlignment: ma, crossAxisAlignment: ca, children: list);

pw.Widget pwRowSplitCell(pw.Font? font, String w1, String w2,
        [double fontSize = 9]) =>
    pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Expanded(
          child: pw.Container(
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                      top: pw.BorderSide(color: PdfColors.black, width: 0.5),
                      right:
                          pw.BorderSide(color: PdfColors.black, width: 0.5))),
              child: __splitText(font, w1, fontSize))),
      pw.Expanded(
          child: pw.Container(
              decoration: const pw.BoxDecoration(
                  border: pw.Border(
                top: pw.BorderSide(color: PdfColors.black, width: 0.5),
              )),
              child: __splitText(font, w2, fontSize)))
    ]);

__splitText(pw.Font? font, String text, [double fontSize = 9]) => pw.Align(
    alignment: pw.Alignment.centerRight,
    child: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: pw.Text(text,
            style: pw.TextStyle(font: font, fontSize: fontSize))));


enum CPdfPageOrientation {
  portrait,
  landscape,
}
extension AppPageOrientationExt on CPdfPageOrientation {
  PageOrientation get pageOrientation {
    switch (this) {
      case CPdfPageOrientation.portrait:
        return PageOrientation.portrait;
      case CPdfPageOrientation.landscape:
        return PageOrientation.landscape;
    }
  }
}