// ignore: depend_on_referenced_packages
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ErrorType {
  idle,
  multipleFiles,
}

class DropzoneParams {
  final bool dragging;
  final ErrorType errorType;

  DropzoneParams({
    required this.dragging,
    this.errorType = ErrorType.idle,
  });
}

class DropzoneElement extends ConsumerStatefulWidget {
  final Widget Function(BuildContext context, DropzoneParams params) builder;
  final Function(List<XFile> files) onFile;
  final bool multiple;

  const DropzoneElement({
    required this.builder,
    required this.onFile,
    this.multiple = false,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DropzoneElementState();
}

class _DropzoneElementState extends ConsumerState<DropzoneElement> {
  bool _dragging = false;
  ErrorType _errorType = ErrorType.idle;

  void _handleFileDrop(List<XFile> files) {
    setState(() => _errorType = ErrorType.idle);

    if (!widget.multiple && files.length > 1) {
      setState(() => _errorType = ErrorType.multipleFiles);
      return;
    }

    widget.onFile(widget.multiple ? files : [files.first]);
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) => _handleFileDrop(detail.files),
      onDragEntered: (detail) {
        if (!_dragging) {
          setState(() => _dragging = true);
        }
      },
      onDragExited: (detail) {
        if (_dragging) {
          setState(() => _dragging = false);
        }
      },
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: _dragging ? Colors.blue.shade100 : Colors.grey.shade300,
        ),
        child: widget.builder(
          context,
          DropzoneParams(
            dragging: _dragging,
            errorType: _errorType,
          ),
        ),
      ),
    );
  }
}
