import 'dart:io';

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:neofilemanager/Item/Mode.dart';
import 'package:neofilemanager/OperationButtom/IOptButton.dart';
import 'package:neofilemanager/Opertaion/Operation.dart';

class RenameOperationButton extends IOptButton {
  @override
  Color color = Colors.blue;
  @override
  String titleText = '重命名';

  RenameOperationButton(
      BuildContext context,
      FileSystemEntity file,
      int type,
      List<FileSystemEntity> leftFiles,
      List<FileSystemEntity> rightFiles,
      ValueNotifier<bool> uiShouldChange,
      Mode mode)
      : super(context, file, type) {
    this.uiShouldChange = uiShouldChange;
    this.mode = mode;
  }

//  RenameOperationButton(this.context, this.file, this.type, this.leftFiles, this.rightFiles, this.uiShouldChange, this.mode);

  @override
  void fun(FileSystemEntity file, int type) {
    new Operation(leftFiles, rightFiles, context,
            uiShouldChange: uiShouldChange, mode: mode)
        .renameFile(file, type);
  }
}
