import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

import 'Common.dart';

class MyHome extends StatefulWidget {
  MyHome({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHome> {
  //文件,目录和链接都继承自FileSystemEntity
  //FileSystemEntityType有三个常量：
  //                               Directory、FILE、LINK、NOT_FOUND
  //FileSystemEntity.isFile .isLink .isDerectory可用于判断类型
  List<FileSystemEntity> leftFiles = [];   //左列的文件
  List<FileSystemEntity> rightFiles = [];    //右列的文件

  double iconHight = 40.0;
  double iconWidth=40.0;
  double fileFontSize=10.0;
  double subTitleFontSize=8.0;
  Directory parentDir;  //父目录
  ScrollController controller = ScrollController();
  List<double> position = [];

//  final _subdirectorys = <WordPair>[];
//  final _biggerFont = const TextStyle(fontSize: 10.0);

  ///初始化: 拿到根路径 刷新目录
  @override
  void initState() {
    super.initState();
    parentDir = Directory(Common().sDCardDir);   //获取根路径
    initPathFiles(Common().sDCardDir,-2);   //刷新左列目录
  }

  ///用于导航返回拦截器的onWillPop
  ///也就是再返回的时候用的
  ///如果再根目录的话再按返回就退出
  ///如果不是就parentDir.parent.path拿到父目录然后跳转
  Future<bool> onWillPop() async {
    /// 如果不是根目录,就跳转到上层目录并刷新目录
    if (parentDir.parent.path!=Common().sDCardDir) {
      //刷新左边 true
      initPathFiles(parentDir.path,2);
//      jumpToPosition(false);
    }

    ///否则退出
    else {
      ///https://blog.csdn.net/weixin_33979203/article/details/88019065
      ///Router: 路由 对屏幕界面的抽象 每一个页面都有相应的Page
      print('退出时parentDir为:'+parentDir.path);
      SystemNavigator.pop();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    ///导航返回拦截器: WillPopScope
    ///连续按两次才退出
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            parentDir?.path == Common().sDCardDir
                ? 'SD card'
                : p.basename(parentDir.path),
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Color(0xffeeeeee),
          elevation: 5.0,
          //浮起来的高度
          leading: parentDir?.path == Common().sDCardDir
              ? Container()
              : IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
            onPressed: onWillPop,
          ), //再标题前面显示的一个控件
        ),
//        body: _fileListView(files.length)
        body: Row(
          children: <Widget>[
            Expanded(
              child: _fileListView(leftFiles, -1),
            ),
            Expanded(
              child: _fileListView(rightFiles,1),
            )
          ],
        ),
      ),
    );
  }

  Widget _fileListView(List<FileSystemEntity> files, int type) {
    if (files.length == 0)
      return Center(child: Text('The folder is empty'));
    else {
      return Scrollbar(
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            //控制列表的滚动的发生方式(再列表结束时退回列表,iOS中有类似效果)
            controller: controller,
            itemCount: files.length,
            itemBuilder: (BuildContext context, int index) {
              if (FileSystemEntity.isFileSync(files[index].path))
                return _buildFileItem(files[index],type);
              else
                return _buildFolderItem(files[index],type);
            }),
      );
    }
  }

  /// 创建文件的ListTile
  Widget _buildFileItem(FileSystemEntity file, int type) {
    //获取文件最后改动日期
    String modifiledTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN')
        .format(file.statSync().modified.toLocal());

    ///InkWell: 水波纹效果
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          border:
          Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
        ),
        child: ListTile(
          leading: Image.asset(Common().selectIcon(p.extension(file.path)),height: 40.0,width: 40.0,),

          ///TODO 解释p.etension
          title: Text(file.path.substring(file.parent.path.length + 1),style: TextStyle(fontSize: fileFontSize)),

          ///从文件路径中截取文件名字 (file.parent.length+1-文件父目录长度)
          subtitle: Text(
            '$modifiledTime ${Common().getFileSize(file.statSync().size)}',
            style: TextStyle(fontSize:subTitleFontSize),
          ), //时间和文件大小
        ),
        //TODO onTap()
        //TODO onLongPress()
      ),
      onTap: () {
        OpenFile.open(file.path);
      },
    );
  }

  /// 创建文件夹的ListTile

//  Future openFile(String path) async {
//    ///dynamic (不做类型检查)
//    final Map<String, dynamic> args = <String, dynamic>{'path': path};
//    await _channel.invokeMethod('openFile', args);
//  }

  Widget _buildFolderItem(FileSystemEntity file, int type) {
    String modifiledTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN')
        .format(file.statSync().modified.toLocal());
    //InkWell: 水波纹效果
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          border:
          Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
        ),
        child: ListTile(
          leading: Image.asset('assets/images/folder.png',height: 40.0,width: 40.0,),
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(file.path.substring(file.parent.path.length + 1),
                    style: TextStyle(fontSize: fileFontSize)),
              ),
              ///TODO 解释这里为什么要用Expanded
            ],
          ),
          subtitle: Text(
            modifiledTime,
            style: TextStyle(fontSize: subTitleFontSize),
          ),
          trailing: Icon(Icons.chevron_right),

          ///trailing: 和leading相对,最后面
        ),
      ),
      onTap: () {
          initPathFiles(file.path,type);
      },
      //TODO onLongPressed
    );
  }

  //////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////

  ///用传来的路径刷新该目录下的文件.文件夹
  void initPathFiles(String path, int type) {
    try {
      //可变的Widget可以使用setState()函数--重新绘制试图--调用build方法--绘制不一样的地方
      setState(() {
        parentDir = Directory(path);
        print('parentDir 更改为'+parentDir.path);
        if(type==-1){//刷新右列表
          sortFile(parentDir,-1);
        }else if(type==1){//往右走 先刷右列表 再刷左列表
          sortFile(parentDir, -1);
          sortFile(parentDir.parent, 1);
        }else if(type==-2){
          sortFile(parentDir,1);
        }else if(type==2){
          sortFile(parentDir.parent, -1);
          sortFile(parentDir.parent.parent, 1);
          parentDir=parentDir.parent;
        }
      });
    } catch (e) {
      print(e);
      print("Directory does not exist");
    }
  }

  ///目录排序
  void sortFile(Directory parentDir,int type) {
    List<FileSystemEntity> _Files = [];
    List<FileSystemEntity> _Folders = [];
    //parenDire--路径
    //Directory.listSync 会列出当前目录下所有的文件和文件夹
    for (var v in parentDir.listSync()) {
      //去除.开头的文件/文件夹
      if (p.basename(v.path).substring(0, 1) == '.') {
        continue;
      }
      if (FileSystemEntity.isFileSync(v.path))
        _Files.add(v);
      else
        _Folders.add(v);
    }
    _Files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    _Folders.sort(
            (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    if (type==-1) {//刷新右列
      rightFiles.clear();
      rightFiles.addAll(_Folders);
      rightFiles.addAll(_Files);
    } else {  //刷新左列
      leftFiles.clear();
      leftFiles.addAll(_Folders);
      leftFiles.addAll(_Files);
    }
  }

  //目录跳转
  void jumpToPosition(bool isEnter) async {
    if (isEnter) {
      controller.jumpTo(0.0);
    } else {
      try {
        ///https://www.jianshu.com/p/a4affde4c8ca
        ///Dart: 单线程模式
        ///     模型: Event-Looper & Event-Queue
        ///     依次执行: 通过EventLooper (事件循环)
        ///               - 取Event (EventQueue)
        ///               - 处理Event
        ///               - 直到EventQueue为空
        ///     :isolate(隔离) ---Dart无线程概念
        ///                    - isolate相互隔离
        ///                    - 不会共享内存
        ///                     程序开始: Main isolate->main()
        ///                     接着处理EventQueue中的Event(one by one)
        ///      : Event Queue & Microtask Queue
        ///             - Main Isolate只有一个Event looper
        ///                               两个Event Queue: Event Queue & Microtask Queue((优先执行)处理稍晚一些的事情(但是下一个消息来之前要处理完的),处理这个Queue时停止Event Queue的处理)
        ///异步任务调度:
        ///             Future: 任务加到Event Queue队尾
        ///             scheduleMidrotask: 任务加到Microtask Queue队尾(要避免过大--阻塞其他事件的处理)
        ///Future.then: 大人物拆分成小任务一步步执行
        ///Future.delayed: 任务延迟执行
        ///Duration:
        await Future.delayed(Duration(milliseconds: 1));
        // "?" 的作用: 标示对象可以是 null
        controller?.jumpTo(position[position.length - 1]);
      } catch (e) {
        position.removeLast();
      }
    }
  }
}
