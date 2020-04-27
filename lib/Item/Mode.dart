import 'dart:io';

class Mode{
  bool cutMode; //是否点了剪切文件
  bool copyMode; //是否点了复制文件
  FileSystemEntity copyTempFile;
  Directory parentDir; //父目录
  Mode(this.cutMode,this.copyMode,this.copyTempFile,this.parentDir);
}
