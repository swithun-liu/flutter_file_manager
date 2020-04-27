import 'dart:io';

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:neofilemanager/OperationButtom/IOptButton.dart';
import 'package:neofilemanager/Opertaion/Operation.dart';
import '../Item/Mode.dart';

class CopyOperationButton extends IOptButton {
  @override
  Color color = Colors.blueAccent;
  @override
  String titleText = '复制2';

  CopyOperationButton(
      BuildContext context, FileSystemEntity file, int type, Mode mode)
      : super(
          context,
          file,
          type,
        ) {
    this.mode = mode;
  }

  @override
  void fun(FileSystemEntity file, int type) {
    // TODO: implement fun
    new Operation(leftFiles, rightFiles, context, mode: mode)
        .copyToDir(file, type);
  }
//  CopyOperationButton(this.context,this.file,this.type,this.mode);
}
