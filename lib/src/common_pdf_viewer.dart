import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CReportVewer {
  static Future<void> showReport(BuildContext context, String url,
      [String reportTitle = "Report"]) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewReport(
          url: url,
          reportTitle: reportTitle,
        ),
      ),
    );
  }
}

class ViewReport extends StatelessWidget {
  final String url;
  final String reportTitle;
  const ViewReport({super.key, required this.url, required this.reportTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottomOpacity: 0.5,
        title: Text(reportTitle, style: Theme.of(context).textTheme.bodyMedium),
        toolbarHeight: 40, // set the height you want
        actions: [
          InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: _CCustomHoverIcon(
                    icon: Icons.close,
                    size: 28,
                    iconColor: Color.fromARGB(255, 95, 6, 0),
                    iconHoverColor: Colors.red,
                    hoverSize: 29),
              ))
        ],
        elevation: 2,
      ),

      // Options: endFloat (default), centerFloat, miniStartFloat, etc.

      body: FutureBuilder(
          future: _getView(url),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Transform.scale(
                scale: 1.5,
                child: CupertinoActivityIndicator(),
              ));
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.red)),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Text('No data found',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.red)),
              );
            }

            return Column(
              children: [Expanded(child: snapshot.data)],
            );
          }),
    );
  }
}

Future<Widget> _getView(String urls) async {
//   await Future.delayed(const Duration(seconds: 3));
  HtmlElementView htmlView = HtmlElementView(viewType: '');
  urls = urls.replaceFirst(
    'data:application/pdf;base64,',
    '',
  );
  final pdfData = base64Decode(urls.replaceAll("\n", ""));
  final blob = html.Blob([pdfData], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  var viewId =
      "pdf-view1${DateFormat('yyyyMMddHHmmssSS').format(DateTime.now())}";
  htmlView = await _pdfViewerWidget(
      viewId,
      "pdf-cont1123${DateFormat('yyyyMMddHHmmssSS').format(DateTime.now())}",
      url);
  return htmlView;
}

Future<HtmlElementView> _pdfViewerWidget(
  String viewID,
  String divid,
  String url,
) async {
  ui_web.platformViewRegistry.registerViewFactory(
    viewID,
    (int viewId) {
      final iframe = html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..width = '100%'
        ..height = '100%'
        ..style.overflow = 'hidden'
        ..style.setProperty('scrollbar-width', 'thin');
      return iframe;
    },
  );

  return HtmlElementView(viewType: viewID);
}

class _CCustomHoverIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final double hoverSize;
  final Color iconColor;
  final Color iconHoverColor;
  const _CCustomHoverIcon({
    required this.icon,
    required this.size,
    required this.iconColor,
    required this.iconHoverColor,
    required this.hoverSize,
  });

  @override
  State<_CCustomHoverIcon> createState() => __CCustomHoverIconState();
}

class __CCustomHoverIconState extends State<_CCustomHoverIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          widget.icon,
          color: _isHovered ? widget.iconHoverColor : widget.iconColor,
          size: _isHovered ? widget.hoverSize : widget.size,
        ),
      ),
    );
  }
}
