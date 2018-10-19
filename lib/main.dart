import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testchat/data.dart';
import 'package:testchat/repository.dart';
import 'package:testchat/ui.dart';
import 'package:testchat/utilities.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("test"),
        ),
        backgroundColor: const Color(0xFFCCDDDD),
        body: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var chatItems = List<ChatItem>();

  @override
  void initState() {
    var ms = MessageSource();
    chatItems = ms.generate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var locale = Localizations.localeOf(context).toString();
    print('Current Locale = ' + locale);
    Intl.defaultLocale = 'ru_RU';
    return ListView.builder(
      itemCount: chatItems.length,
      itemBuilder: _itemBuilder,
    );
  }

  static const space = 4.0;
  static const space05 = space / 2;
  static const space2 = space * 2;
  static const space3 = space * 3;
  static const space4 = space * 4;

  Widget _itemBuilder(BuildContext context, int index) {
    var chatItem = chatItems[index];
    if (chatItem is Msg) return _buildMsg(chatItem);
    if (chatItem is DaySeparator) return _buildDaySeparator(chatItem);
    if (chatItem is TransferEndBlock) return _buildTransferEndBlock(chatItem);

    return Container(child: Text("Upsupported item"));
  }

  Widget _buildDaySeparator(DaySeparator daySeparator) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              color: Colors.black12),
          child: Text(
            daySeparator.text,
            textScaleFactor: 0.9,
            style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic),
          ),
        ),
      ),
    );
  }

  //TODO merge with daySeparator?
  Widget _buildTransferEndBlock(TransferEndBlock chatItem) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: space),
        child: Text(
          chatItem.text,
          textScaleFactor: 0.7,
          style: TextStyle(color: Colors.grey),
        ),
      );

  Widget _buildMsg(Msg msg) {
    return Padding(
      padding: EdgeInsets.only(top: msg.isContinuation ? space05 : space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          SizedBox(width: space),
          _avatarArea(msg),
          SizedBox(width: space),
          Flexible(
            child: _bubbleArea(msg),
          ),
          _actionsArea(msg),
        ],
      ),
    );
  }

  Widget _avatarArea(Msg msg) {
    var avatarSize = 32.0;
    var time = Text(
      msg.bubbleTime,
      style: TextStyle(color: Colors.grey), //TODO monospace here needed
      textScaleFactor: 0.7,
    );

    var items = <Widget>[
      SizedBox(width: avatarSize),
      Positioned(
        //TODO for transferredMessages that has additionally day or year increase bottom padding (-38,-26)
        bottom: (msg.avatar != null
            ? (msg.bubbleTimeLines > 1 ? -26.0 : -14.0)
            : 0.0),
        child: time,
      ),
    ];
    if (msg.avatar != null) {
      items.add(avatar(avatarSize, msg));
    }
    return Stack(
      overflow: Overflow.visible,
      alignment: Alignment.bottomCenter,
      children: items.reversed.toList(),
    );
  }

  ClipRRect avatar(double avatarSize, Msg msg) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: avatarSize,
        height: avatarSize,
        color: msg.color,
        child: Center(
          child: Text(
            msg.avatar.text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _bubbleArea(Msg msg) => Container(
        decoration: ShapeDecoration.fromBoxDecoration(
          BoxDecoration(
            color: Colors.white,
            border: !msg.isImportant ? null : Border.all(color: msg.color),
            borderRadius: BorderRadius.only(
                topLeft: msg.isContinuation
                    ? Radius.circular(space)
                    : Radius.circular(space3),
                topRight: msg.isContinuation
                    ? Radius.circular(space)
                    : Radius.circular(space3),
                bottomRight: msg.avatar == null || msg.transferInfo != null
                    ? Radius.circular(space)
                    : Radius.circular(space * 3),
                bottomLeft:
                    msg.avatar == null ? Radius.circular(space) : Radius.zero

                //right: Radius.circular(20.0),
                ),
          ),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: space2, horizontal: space3),
            child: _bubbleContent(msg)),
      );

  Widget _bubbleContent(Msg msg) {
    var t = List<Widget>();
    if (msg.authorName != null)
      t.add(Text(msg.authorName, style: TextStyle(color: msg.color)));
    if (msg.reply != null) t.add(_buildReplyButton(msg.reply));
    t.add(Text(msg.text,
        style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.2)));
    if (msg.transferInfo != null) t.add(_buildTransferInfo(msg));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: t,
    );
  }

  Widget _actionsArea(Msg msg) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: space2, horizontal: space3),
        child: Icon(Icons.reply, size: 20.0, color: Colors.grey),
      ),
    );
  }

  Widget _buildReplyButton(Reply reply) {
    var colItems = List<Widget>();
    if (reply.preview == null)
      colItems.add(Text(reply.fallback));
    else {
      var p = reply.preview;
      colItems.add(Text(p.author,overflow: TextOverflow.fade,textScaleFactor: 0.9,)); // Use author widget
      colItems.add(Text(p.content,overflow: TextOverflow.fade,textScaleFactor: 0.9)); // Use author widget
    }
    return Row(children: <Widget>[
      Container(width: 2.0, height: 32.0, color: Colors.blueAccent),
      SizedBox(width: space2),
      Column(children: colItems,crossAxisAlignment: CrossAxisAlignment.start,)
    ]);
  }

  Widget _buildTransferInfo(Msg msg) {
    TransferInfo transferInfo = msg.transferInfo;
    var colItems = List<Widget>();
    colItems.add(Text(
        '$transferSymbol Перенесено сообщений: ${transferInfo.count}',
        style: TextStyle(color: msg.color))); //TODO color text with
    colItems.add(Text('$transferSymbol Из чата №: ${transferInfo.from}',
        style: TextStyle(color: msg.color))); // Use author widget
    colItems.add(SizedBox(height: space));
    colItems.add(Container(height: 2.0, color: msg.color));
    return Column(
        children: colItems, crossAxisAlignment: CrossAxisAlignment.stretch);
  }
}
