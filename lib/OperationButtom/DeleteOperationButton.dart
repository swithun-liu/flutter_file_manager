import 'dart:io';

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:neofilemanager/Item/Mode.dart';
import 'package:neofilemanager/Opertaion/Operation.dart';

import 'IOptButton.dart';

class DeleteOperationButton extends IOptButton {
  @override
  Color color = Colors.blueGrey;
  @override
  String titleText = '删除';

  Mode mode;

  DeleteOperationButton(
      BuildContext context,
      FileSystemEntity file,
      int type,
      List<FileSystemEntity> leftFiles,
      List<FileSystemEntity> rightFiles,
      Mode mode,
      ValueNotifier<bool> uiShouldChange)
      : super(context, file, type) {
    this.leftFiles = leftFiles;
    this.rightFiles = rightFiles;
    this.mode = mode;
    this.uiShouldChange = uiShouldChange;
  }

//  DeleteOperationButton(this.context,this.file,this.type,this.mode,this.leftFiles,this.rightFiles,this.parentDir,this.uiShouldChange);

  @override
  void fun(FileSystemEntity file, int type) {
    new Operation(leftFiles, rightFiles, context,
            mode: mode, uiShouldChange: uiShouldChange)
        .deleteFile(file, type);
  }
}
