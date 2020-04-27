import 'dart:io';

import 'dart:ui';

import 'package:flutter/src/widgets/framework.dart';
import 'package:neofilemanager/OperationButtom/IOptButton.dart';

class testButton extends IOptButton {
  @override
  Color color;

  @override
  String titleText;

  testButton(BuildContext context, FileSystemEntity file, int type)
      : super(context, file, type);

  @override
  void fun(FileSystemEntity file, int type) {
    // TODO: implement fun
  }
}
