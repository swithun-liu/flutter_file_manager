import 'dart:io';

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:neofilemanager/Item/Mode.dart';
import 'package:neofilemanager/Opertaion/Operation.dart';

import 'IOptButton.dart';

class CutOperationButton extends IOptButton {
  @override
  Color color = Colors.lightBlue;
  @override
  String titleText = '剪切';

  CutOperationButton(
      BuildContext context, FileSystemEntity file, int type, Mode mode)
      : super(context, file, type) {
    this.mode = mode;
  }

//  CutOperationButton(this.context,this.file,this.type,this.mode);
  @override
  void fun(FileSystemEntity file, int type) {
    new Operation(leftFiles, rightFiles, context, mode: mode)
        .cutToDir(file, type);
  }
}
