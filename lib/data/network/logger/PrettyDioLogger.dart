library pretty_dio_logger;

import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';

class PrettyDioLogger extends Interceptor {
  /// Print request [Options]
  final bool request;

  /// Print request header [Options.headers]
  final bool requestHeader;

  /// Print request data [Options.data]
  final bool requestBody;

  /// Print [Response.data]
  final bool responseBody;

  /// Print [Response.headers]
  final bool responseHeader;

  /// Print error message
  final bool error;

  /// InitialTab count to logPrint json response
  static const int initialTab = 1;

  /// 1 tab length
  static const String tabStep = '    ';

  /// Print compact json response
  final bool compact;

  /// Width size per logPrint
  final int maxWidth;

  /// Log printer; defaults logPrint log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file.
  void Function(Object? object) logPrint;

  //LoggerColor
  var infoColor = AnsiColor.fg(208);
  var paramColor = AnsiColor.fg(215);
  var successColor = AnsiColor.fg(77);
  var errorColor = AnsiColor.fg(196);

  PrettyDioLogger(
      {this.request = true,
      this.requestHeader = false,
      this.requestBody = false,
      this.responseHeader = false,
      this.responseBody = true,
      this.error = true,
      this.maxWidth = 90,
      this.compact = true,
      this.logPrint = print});

  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (request) {
      _printRequestHeader(options);
    }
    if (requestHeader) {
      _printMapAsTable(options.queryParameters, header: 'Query Parameters', color: paramColor);
      final requestHeaders = {};
      requestHeaders.addAll(options.headers);
          requestHeaders['contentType'] = options.contentType?.toString();
      requestHeaders['responseType'] = options.responseType.toString();
      requestHeaders['followRedirects'] = options.followRedirects;
      requestHeaders['connectTimeout'] = options.connectTimeout;
      requestHeaders['receiveTimeout'] = options.receiveTimeout;
      _printMapAsTable(requestHeaders, header: 'Headers', color: infoColor);
      _printMapAsTable(options.extra, header: 'Extras', color: infoColor);
    }
    if (requestBody && options.method != 'GET') {
      final data = options.data;
      if (data != null) {
        if (data is Map) {
          _printMapAsTable(options.data, header: 'Body', color: paramColor);
        } else if (data is FormData) {
          final formDataMap = {}..addEntries(data.fields)..addEntries(data.files);
          _printMapAsTable(formDataMap, header: 'Form data | ${data.boundary}', color: paramColor);
        }

        _printBlock('RequestMap: ${data.toString()}', color: infoColor);
      }
    }
    super.onRequest(options, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (error) {
        final uri = err.response?.requestOptions.uri;
      if (err.type == DioExceptionType.badResponse) {
        _printBoxed(
            header: 'DioError ║ Status: ${err.response!.statusCode} ${err.response!.statusMessage}',
            text: uri.toString(),
            color: errorColor);
        if (err.response != null && err.response!.data != null) {
          logPrint(errorColor('╔ ${err.type.toString()}'));
          _printResponse(err.response!, color: errorColor);
        }
        _printLine(pre: '╚', color: errorColor);
        logPrint('');
      } else {
        _printBoxed(header: 'DioError ║ ${err.type}', text: err.message, color: errorColor);
      }
    }
    super.onError(err, handler);
  }

  @override
  Future onResponse(Response response, ResponseInterceptorHandler handler) async {
    var iColor = response.statusCode == 200 ? successColor : AnsiColor.fg(209);
    _printResponseHeader(response, iColor);
    if (responseHeader) {
      final responseHeaders = <String, String>{};
      response.headers.forEach((k, list) => responseHeaders[k] = list.toString());
      _printMapAsTable(responseHeaders, header: 'Headers', color: iColor);
    }

    if (responseBody) {
      logPrint(iColor('╔ Body'));
      logPrint(iColor('║'));
      _printResponse(response, color: iColor);
      logPrint(iColor('║'));
      _printLine(pre: '╚', color: iColor);
    }

    super.onResponse(response, handler);
  }

  void _printBoxed({String? header, String? text, AnsiColor? color}) {
    color = color ?? AnsiColor.none();
    logPrint(color(''));
    logPrint(color('╔╣ $header'));
    logPrint(color('║  $text'));
    _printLine(pre: '╚', color: color);
  }

  void _printResponse(Response response, {AnsiColor? color}) {
    color = color ?? AnsiColor.none();
    if (response.data != null) {
      if (response.data is Map) {
        _printPrettyMap(response.data, vColor: color);
      } else if (response.data is List) {
        logPrint(color('║${_indent()}['));
        _printList(response.data, vColor: color);
        logPrint(color('║${_indent()}]'));
      } else
        _printBlock(response.data.toString());
    }
  }

  void _printResponseHeader(Response response, AnsiColor vColor) {
    final uri = response.requestOptions.uri;
    final method = response.requestOptions.method;
    _printBoxed(
        header: 'Response ║ $method ║ Status: ${response.statusCode} ${response.statusMessage}',
        text: uri.toString(),
        color: vColor);
  }

  void _printRequestHeader(RequestOptions options) {
    final uri = options.uri;
    final method = options.method;
    _printBoxed(header: 'Request ║ $method ', text: uri.toString(), color: infoColor);
  }

  void _printLine({String pre = '', AnsiColor? color}) {
    color = color ?? AnsiColor.none();
    logPrint(color('$pre${'═' * maxWidth}'));
  }

  void _printKV(String key, Object? v, AnsiColor? color) {
    color = color ?? AnsiColor.none();
    final pre = '╟ $key: ';
    final msg = v.toString();

    if (pre.length + msg.length > maxWidth) {
      logPrint(color(pre));
      _printBlock(msg, color: paramColor);
    } else {
      logPrint(color('$pre$msg'));
    }
  }

  void _printBlock(String msg, {AnsiColor? color}) {
    color = color ?? AnsiColor.none();
    int lines = (msg.length / maxWidth).ceil();
    for (int i = 0; i < lines; ++i) {
      logPrint(color(
          (i >= 0 ? '║ ' : '') + msg.substring(i * maxWidth, math.min<int>(i * maxWidth + maxWidth, msg.length))));
    }
  }

  String _indent([int tabCount = initialTab]) => tabStep * tabCount;

  void _printPrettyMap(Map data,
      {int tabs = initialTab, bool isListItem = false, bool isLast = false, AnsiColor? vColor}) {
    vColor = vColor ?? AnsiColor.none();
    final bool isRoot = tabs == initialTab;
    final initialIndent = _indent(tabs);
    tabs++;

    if (isRoot || isListItem) logPrint(vColor('║$initialIndent{'));

    data.keys.toList().asMap().forEach((index, key) {
      final isLast = index == data.length - 1;
      var value = data[key];
//      key = '\"$key\"';
      if (value is String) value = '\"${value.toString().replaceAll(RegExp(r'(\r|\n)+'), " ")}\"';
      if (value is Map) {
        if (compact && _canFlattenMap(value)) {
          logPrint(vColor!('║${_indent(tabs)} $key: $value${!isLast ? ',' : ''}'));
        } else {
          logPrint(vColor!('║${_indent(tabs)} $key: {'));
          _printPrettyMap(value, tabs: tabs, vColor: vColor);
        }
      } else if (value is List) {
        if (compact && _canFlattenList(value)) {
          logPrint(vColor!('║${_indent(tabs)} $key: ${value.toString()}'));
        } else {
          logPrint(vColor!('║${_indent(tabs)} $key: ['));
          _printList(value, tabs: tabs, vColor: vColor);
          logPrint(vColor('║${_indent(tabs)} ]${isLast ? '' : ','}'));
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        final indent = _indent(tabs);
        final linWidth = maxWidth - indent.length;
        if (msg.length + indent.length > linWidth) {
          int lines = (msg.length / linWidth).ceil();
          for (int i = 0; i < lines; ++i) {
            logPrint(vColor!(
                '║${_indent(tabs)} ${msg.substring(i * linWidth, math.min<int>(i * linWidth + linWidth, msg.length))}'));
          }
        } else {
          logPrint(vColor!('║${_indent(tabs)} $key: $msg${!isLast ? ',' : ''}'));
        }
      }
    });

    logPrint(vColor('║$initialIndent}${isListItem && !isLast ? ',' : ''}'));
  }

  void _printList(List list, {int tabs = initialTab, AnsiColor? vColor}) {
    list.asMap().forEach((i, e) {
      final isLast = i == list.length - 1;
      if (e is Map) {
        if (compact && _canFlattenMap(e)) {
          logPrint(vColor!('║${_indent(tabs)}  $e${!isLast ? ',' : ''}'));
        } else {
          _printPrettyMap(e, tabs: tabs + 1, isListItem: true, isLast: isLast, vColor: vColor);
        }
      } else {
        logPrint(vColor!('║${_indent(tabs + 2)} $e${isLast ? '' : ','}'));
      }
    });
  }

  bool _canFlattenMap(Map map) {
    return map.values.where((val) => val is Map || val is List).isEmpty && map.toString().length < maxWidth;
  }

  bool _canFlattenList(List list) {
    return (list.length < 10 && list.toString().length < maxWidth);
  }

  void _printMapAsTable(Map? map, {String? header, AnsiColor? color}) {
    color = color ?? AnsiColor.none();
    if (map == null || map.isEmpty) return;
    logPrint(color('╔ $header '));
    map.forEach((key, value) => _printKV(key, value, color));
    _printLine(pre: '╚', color: color);
  }
}

class AnsiColor {
  /// ANSI Control Sequence Introducer, signals the terminal for new settings.
  static const ansiEsc = '\x1B[';

  /// Reset all colors and options for current SGRs to terminal defaults.
  static const ansiDefault = '${ansiEsc}0m';

  final int? fg;
  final int? bg;
  final bool color;

  AnsiColor.none()
      : fg = null,
        bg = null,
        color = false;

  AnsiColor.fg(this.fg)
      : bg = null,
        color = true;

  AnsiColor.bg(this.bg)
      : fg = null,
        color = true;

  @override
  String toString() {
    if (fg != null) {
      return '${ansiEsc}38;5;${fg}m';
    } else if (bg != null) {
      return '${ansiEsc}48;5;${bg}m';
    } else {
      return '';
    }
  }

  String call(String msg) {
    if (color) {
      return '${this}$msg$ansiDefault';
    } else {
      return msg;
    }
  }

  AnsiColor toFg() => AnsiColor.fg(bg);

  AnsiColor toBg() => AnsiColor.bg(fg);

  /// Defaults the terminal's foreground color without altering the background.
  String get resetForeground => color ? '${ansiEsc}39m' : '';

  /// Defaults the terminal's background color without altering the foreground.
  String get resetBackground => color ? '${ansiEsc}49m' : '';

  static int grey(double level) => 232 + (level.clamp(0.0, 1.0) * 23).round();
}
