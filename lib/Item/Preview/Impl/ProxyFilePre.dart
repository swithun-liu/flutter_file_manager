import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neofilemanager/Item/Common.dart';
import 'package:neofilemanager/Item/Preview/FilePre.dart';
import 'package:neofilemanager/Item/Preview/Impl/RealFilePre.dart';

class ProxyFilePre extends FilePre {
  Common common;
  FileSystemEntity file;
  String extension;
  double iconHeight = 30.0;
  double iconWidth = 30.0;
  double fileHeight = 50.0;
  double fileWidth = 70.0;
  RealFilePre realFilePre;

  ProxyFilePre(this.common, this.file, this.extension);

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: returnRealFIlePre(common, file, extension),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return realFilePre;
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Image.asset(
            common.selectIcon(extension),
            height: iconHeight,
            width: iconWidth,
          );
        }
        return Image.asset(
          common.selectIcon(extension),
          height: iconHeight,
          width: iconWidth,
        );
      },
    );
  }

  Future<Widget> returnRealFIlePre(common, file, extension) async {
    return realFilePre = new RealFilePre(common, file, extension);
  }
}
