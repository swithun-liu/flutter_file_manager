import 'dart:io';

import 'package:file_manager/Common.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart' as p;

void main() {
  //future: Future<T>对象--Dart内置,有自己的队列策略(EventQueue)
  //async: 异步,不阻塞当前进程,来等待该线程处理完任务再执行其他任务
  //await: 等待,声明运算为延迟进行
  Future<void> getSDCardDir() async {
    //插件path_provider提供函数getExternalStorageDirectory
    //获取SD卡根路径  path_provider提供方法
    Common().sDCardDir = (await getExternalStorageDirectory()).path;
  }

  //获取权限函数
  Future<void> getPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      }
      await getSDCardDir();
    } else if (Platform.isIOS) {
      await getSDCardDir();
    }
  }

  //获取权限
  Future.wait([initializeDateFormatting("zh_CN", null), getPermission()])
      .then((result) {
    runApp(MyApp());
  });
}

//App
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: MyHomePage(title: 'ranger'),
    );
  }
}

//HomePage
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //文件,目录和链接都继承自FileSystemEntity
  //FileSystemEntityType有三个常量：
  //                               Directory、FILE、LINK、NOT_FOUND
  //FileSystemEntity.isFile .isLink .isDerectory可用于判断类型
  List<FileSystemEntity> leftFiles = [];
  List<FileSystemEntity> rightFiles = [];

  //Flutter通过平台通道(platform channel)将消息发送到应用程序所在的宿主(宿主监听平台通道,调用平台API-将响应发送回客户端)
  //Flutter---MethodChannel----FlutterMethodChannel(iOS host)/MethodChannel(Android host)
  //Flutter 三种 Channel:
  //                    1. BasicMessageChannel：用于传递字符串和半结构化的信息。
  //                    2. MethodChannel：用于传递方法调用（method invocation）。
  //                    3. EventChannel: 用于数据流（event streams）的通信。
//  MethodChannel _channel = MethodChannel('openFileChannel'); //后面用来打开文件用
  Directory parentDir;
  ScrollController controller = ScrollController();
  List<double> position = [];

//  final _subdirectorys = <WordPair>[];
//  final _biggerFont = const TextStyle(fontSize: 10.0);

  ///初始化: 拿到根路径 刷新目录
  @override
  void initState() {
    super.initState();
    //获取根路径
    parentDir = Directory(Common().sDCardDir);
    //刷新目录
    initPathFiles(Common().sDCardDir, false);
  }

  ///用于导航返回拦截器的onWillPop
  ///也就是再返回的时候用的
  ///如果再根目录的话再按返回就退出
  ///如果不是就parentDir.parent.path拿到父目录然后跳转
  Future<bool> onWillPop() async {
    /// 如果不是根目录,就跳转到上层目录并刷新目录
    if (parentDir.path != Common().sDCardDir) {
      initPathFiles(parentDir.parent.path,true);
      initPathFiles(parentDir.parent.path,false);
      jumpToPosition(false);
    }

    ///否则退出
    else {
      ///https://blog.csdn.net/weixin_33979203/article/details/88019065
      ///Router: 路由 对屏幕界面的抽象 每一个页面都有相应的Page
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
              child: _fileListView(leftFiles, true),
            ),
            Expanded(
              child: _fileListView(rightFiles, false),
            )
          ],
        ),
      ),
    );
  }

  Widget _fileListView(List<FileSystemEntity> files, bool leftList) {
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
                return _buildFileItem(files[index], leftList);
              else
                return _buildFolderItem(files[index], leftList);
            }),
      );
    }
  }

  /// 创建文件的ListTile
  Widget _buildFileItem(FileSystemEntity file, bool leftList) {
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
          leading: Image.asset(Common().selectIcon(p.extension(file.path))),

          ///TODO 解释p.etension
          title: Text(file.path.substring(file.parent.path.length + 1)),

          ///从文件路径中截取文件名字 (file.parent.length+1-文件父目录长度)
          subtitle: Text(
            '$modifiledTime ${Common().getFileSize(file.statSync().size)}',
            style: TextStyle(fontSize: 12.0),
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

  Widget _buildFolderItem(FileSystemEntity file, bool leftList) {
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
          leading: Image.asset('assets/images/folder.png'),
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(file.path.substring(file.parent.path.length + 1),
                    style: TextStyle(fontSize: 10.0)),
              ),

              ///TODO 解释这里为什么要用Expanded
              ///TODO 添加文件夹内文件项数
//              Text('有多少项')
            ],
          ),
          subtitle: Text(
            modifiledTime,
            style: TextStyle(fontSize: 8.0),
          ),
          trailing: Icon(Icons.chevron_right),

          ///trailing: 和leading相对,最后面
        ),
      ),
      onTap: () {
        // 点进一个文件夹，记录进去之前的offset
        // 返回上一层跳回这个offset，再清除该offset
        if (leftList)
          initPathFiles(file.path, leftList);
        else {
          initPathFiles(file.parent.path, leftList);
          initPathFiles(file.path, true);
        }

//        position.add(controller.offset);
//        initPathFiles(file.path,leftList);
//        jumpToPosition(true);
      },
      //TODO onLongPressed
    );
  }

  //////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////

  ///用传来的路径刷新该目录下的文件.文件夹
  void initPathFiles(String path, bool leftList) {
    try {
      //可变的Widget可以使用setState()函数--重新绘制试图--调用build方法--绘制不一样的地方
      setState(() {
        parentDir = Directory(path);
        sortFile(leftList);
      });
    } catch (e) {
      print(e);
      print("Directory does not exist");
    }
  }

  ///目录排序
  void sortFile(bool leftList) {
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
    if (leftList) {
      rightFiles.clear();
      rightFiles.addAll(_Folders);
      rightFiles.addAll(_Files);
    } else {
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
