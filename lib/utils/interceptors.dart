import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suchigo_collector/config/app_config.dart';
import 'package:suchigo_collector/utils/app_build_methods.dart';

class LoggerStackTrace {
  const LoggerStackTrace._({
    required this.functionName,
    required this.callerFunctionName,
    required this.fileName,
    required this.lineNumber,
    required this.columnNumber,
  });

  factory LoggerStackTrace.from(StackTrace trace) {
    final frames = trace.toString().split('\n');
    final functionName = _getFunctionNameFromFrame(frames[0]);
    final callerFunctionName = _getFunctionNameFromFrame(frames[1]);
    final fileInfo = _getFileInfoFromFrame(frames[0]);

    return LoggerStackTrace._(
      functionName: functionName,
      callerFunctionName: callerFunctionName,
      fileName: fileInfo[0],
      lineNumber: int.tryParse(fileInfo[1]) ?? 0,
      columnNumber: int.tryParse(fileInfo[2].replaceFirst(')', '')) ?? 0,
    );
  }

  final String functionName;
  final String callerFunctionName;
  final String fileName;
  final int lineNumber;
  final int columnNumber;

  static List<String> _getFileInfoFromFrame(String trace) {
    final indexOfFileName = trace.indexOf(RegExp('[A-Za-z]+.dart'));
    final fileInfo = trace.substring(indexOfFileName);
    return fileInfo.split(':');
  }

  static String _getFunctionNameFromFrame(String trace) {
    final indexOfWhiteSpace = trace.indexOf(' ');
    final subStr = trace.substring(indexOfWhiteSpace);
    final indexOfFunction = subStr.indexOf(RegExp('[A-Za-z0-9]'));

    return subStr
        .substring(indexOfFunction)
        .substring(0, subStr.substring(indexOfFunction).indexOf(' '));
  }

  @override
  String toString() {
    return '(functionName: $functionName, '
        'callerFunctionName: $callerFunctionName, '
        'fileName: $fileName, \t'
        'lineNumber: $lineNumber, \t'
        'columnNumber: $columnNumber)\n';
  }
}

class AppStackInterceptor extends Interceptor {
  final ValueChanged<String>? onDisplayLog;

  AppStackInterceptor({this.onDisplayLog}) : super();

  static const _jsonEncoder = JsonEncoder.withIndent('  ');

  static String _formatJson(dynamic data) {
    if (data == null) return 'null';
    if (data is FormData) {
      final fields =
          data.fields.map((f) => '${f.key}: ${f.value}').join(', ');
      final files =
          data.files.map((f) => '${f.key}: ${f.value.filename}').join(', ');
      return 'FormData(fields: [$fields], files: [$files])';
    }
    if (data is Map || data is List) {
      try {
        return _jsonEncoder.convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        return _jsonEncoder.convert(decoded);
      } catch (_) {
        return data;
      }
    }
    return data.toString();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kDebugMode || !AppConfig.isDebugMode) {
      handler.next(options);
      return;
    }
    options.extra['_req_time'] = DateTime.now().millisecondsSinceEpoch;
    try {
      final timeStr = DateTime.now().toIso8601String().substring(11, 19);
      final buffer = StringBuffer();
      buffer.writeln('\n==================== [API REQUEST $timeStr] ====================');
      buffer.writeln('${options.method.toUpperCase()} ${options.uri}');
      if (options.headers.isNotEmpty) {
        buffer.writeln('HEADERS: ${_formatJson(options.headers)}');
      }
      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('QUERY: ${_formatJson(options.queryParameters)}');
      }
      if (options.data != null) {
        buffer.writeln('BODY: ${_formatJson(options.data)}');
      }
      buffer.writeln('------------------------------------------------------------\n');

      _outputLog(buffer.toString());
    } catch (e) {
      debugPrint('[AppStackInterceptor] onRequest error: $e');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!kDebugMode || !AppConfig.isDebugMode) {
      handler.next(response);
      return;
    }
    try {
      final startTime = response.requestOptions.extra['_req_time'] as int?;
      final durationMs = startTime != null
          ? DateTime.now().millisecondsSinceEpoch - startTime
          : null;
      final timeStr = DateTime.now().toIso8601String().substring(11, 19);

      final buffer = StringBuffer();
      buffer.writeln('\n==================== [API RESPONSE $timeStr] ====================');
      buffer.writeln('${response.requestOptions.method.toUpperCase()} ${response.realUri}');
      buffer.writeln(
          'STATUS: ${response.statusCode} ${response.statusMessage ?? ""} ${durationMs != null ? "(${durationMs}ms)" : ""}');
      buffer.writeln('BODY: ${_formatJson(response.data)}');
      buffer.writeln('------------------------------------------------------------\n');

      _outputLog(buffer.toString());
    } catch (e) {
      debugPrint('[AppStackInterceptor] onResponse error: $e');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kDebugMode || !AppConfig.isDebugMode) {
      handler.next(err);
      return;
    }
    try {
      final startTime = err.requestOptions.extra['_req_time'] as int?;
      final durationMs = startTime != null
          ? DateTime.now().millisecondsSinceEpoch - startTime
          : null;
      final timeStr = DateTime.now().toIso8601String().substring(11, 19);

      final buffer = StringBuffer();
      buffer.writeln('\n==================== [API ERROR $timeStr] ====================');
      buffer.writeln('${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}');
      buffer.writeln(
          'STATUS: ${err.response?.statusCode ?? "NO STATUS"} ${durationMs != null ? "(${durationMs}ms)" : ""}');
      buffer.writeln('MESSAGE: ${err.message}');
      if (err.response?.data != null) {
        buffer.writeln('ERROR BODY: ${_formatJson(err.response?.data)}');
      }
      buffer.writeln('------------------------------------------------------------\n');

      _outputLog(buffer.toString());
    } catch (e) {
      debugPrint('[AppStackInterceptor] onError error: $e');
    }
    handler.next(err);
  }

  void _outputLog(String log) {
    if (onDisplayLog != null) {
      onDisplayLog!(log);
    }
    _chunkPrint(log);
  }

  static void _chunkPrint(String text) {
    const int chunkSize = 800;
    for (int i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      debugPrint(text.substring(i, end));
    }
  }
}

class AppStackInterceptorBuilder extends StatefulWidget {
  static final ValueNotifier<String> _logNotifier = ValueNotifier("");
  static final ValueNotifier<int> _callCountNotifier = ValueNotifier(0);

  static set log(String value) {
    if (!kDebugMode || !AppConfig.isDebugMode) return;
    _logNotifier.value += "\n$value";
    _callCountNotifier.value++;
  }

  static AppStackInterceptor appStackInterceptor = AppStackInterceptor(
    onDisplayLog: _addToNotifier,
  );

  final Widget child;

  const AppStackInterceptorBuilder({super.key, required this.child});

  @override
  State<AppStackInterceptorBuilder> createState() =>
      _AppStackInterceptorBuilderState();

  static void _addToNotifier(String value) {
    if (!kDebugMode || !AppConfig.isDebugMode) return;
    _logNotifier.value += value;
    _callCountNotifier.value++;
  }
}

class _AppStackInterceptorBuilderState
    extends State<AppStackInterceptorBuilder> {
  final _scrollController = ScrollController();
  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier(false);

  Offset _offSet = const Offset(16, 120);

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || !AppConfig.isDebugMode) {
      return widget.child;
    }

    final EdgeInsets safeAreaPadding = MediaQuery.of(context).padding;
    final double maxWidth =
        MediaQuery.of(context).size.width - safeAreaPadding.horizontal;
    final double maxHeight =
        MediaQuery.of(context).size.height - safeAreaPadding.vertical;

    return Material(
      child: SafeArea(
        child: Stack(
          children: [
            widget.child,

            // Fullscreen Live Logger Overlay when Expanded
            Positioned.fill(
              child: ValueListenableBuilder<bool>(
                valueListenable: _isExpandedNotifier,
                builder: (context, isExpanded, _) {
                  if (!isExpanded) return const SizedBox.shrink();

                  return Container(
                    color: const Color(0xE6121814), // Dark translucent green/black
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Toolbar
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          color: const Color(0xFF1B281E),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.terminal_rounded,
                                color: Color(0xFF81C784),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "API Live Logger",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ValueListenableBuilder<int>(
                                valueListenable:
                                    AppStackInterceptorBuilder._callCountNotifier,
                                builder: (context, count, _) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "$count calls",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  AppStackInterceptorBuilder._logNotifier.value = "";
                                  AppStackInterceptorBuilder._callCountNotifier.value = 0;
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                                child: const Text("Clear"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(
                                      text: AppStackInterceptorBuilder._logNotifier.value,
                                    ),
                                  );
                                  showToast("Logs copied to clipboard");
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF81C784),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                                child: const Text("Copy"),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.white),
                                onPressed: () => _isExpandedNotifier.value = false,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),

                        // Scrollable Console Log Content
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(12),
                            child: ValueListenableBuilder<String>(
                              valueListenable:
                                  AppStackInterceptorBuilder._logNotifier,
                              builder: (context, log, _) {
                                if (log.trim().isEmpty) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 40),
                                      child: Text(
                                        "No API calls logged yet.\nMake an API request to see details.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white54,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return SelectableText(
                                  log,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFFA5D6A7),
                                    fontFamily: 'monospace',
                                    height: 1.35,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Draggable Floating Action Button
            Positioned(
              left: _offSet.dx,
              top: _offSet.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    final newX = (_offSet.dx + details.delta.dx)
                        .clamp(0.0, (maxWidth - 56.0).clamp(0.0, maxWidth));
                    final newY = (_offSet.dy + details.delta.dy)
                        .clamp(0.0, (maxHeight - 56.0).clamp(0.0, maxHeight));
                    _offSet = Offset(newX, newY);
                  });
                },
                child: Material(
                  elevation: 6,
                  shape: const CircleBorder(),
                  color: const Color(0xFF1D723C),
                  child: InkWell(
                    onTap: _onTapExpand,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF81C784),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.terminal_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                          ValueListenableBuilder<int>(
                            valueListenable:
                                AppStackInterceptorBuilder._callCountNotifier,
                            builder: (context, count, _) {
                              if (count == 0) return const SizedBox.shrink();
                              return Positioned(
                                right: 2,
                                top: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      count > 99 ? '99+' : count.toString(),
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapExpand() {
    _isExpandedNotifier.value = !_isExpandedNotifier.value;
    if (_isExpandedNotifier.value) {
      try {
        Future.delayed(
          const Duration(milliseconds: 300),
          () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
              );
            }
          },
        );
      } catch (_) {}
    }
  }
}
