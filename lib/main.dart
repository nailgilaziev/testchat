import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testchat/repository.dart';
import 'package:testchat/ui.dart';
import 'package:testchat/utilities.dart';
import 'package:testchat/widgets/chatitem/reactions_block.dart';

void main() => runApp(MyApp());

//const bg =  Color(0xFFEEEEEE);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    final brightness = Brightness.light;
    bool isDark = brightness == Brightness.dark;
    final bg = Colors.grey;
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: brightness,
          primarySwatch: bg,
          primaryColor: isDark ? bg[900] : bg[50],
          cardColor: isDark ? Colors.grey[900] : Colors.white,
          scaffoldBackgroundColor: isDark ? Colors.black : bg[200],
        ),

        home: MyScreen()
    );
  }
}

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("test"),
      ),
      body: MyHomePage(title: 'Flutter Demo Home Page'),
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

  Widget _itemBuilder(BuildContext context, int index) {
    var chatItem = chatItems[index];
    if (chatItem is Msg) return _buildMsg(chatItem);
    if (chatItem is DaySeparator) return _buildDaySeparator(chatItem);
    if (chatItem is TransferredDaySeparator)
      return _buildDaySeparator(chatItem, isTransferred: true);
    if (chatItem is BlockEnd) return _buildTransferEndBlock(chatItem);

    return Container(child: Text("Upsupported item"));
  }

  Widget _buildDaySeparator(DaySeparator daySeparator,
      {bool isTransferred: false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: (isTransferred ? 4.0 : 8.0), horizontal: 16.0),
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
  Widget _buildTransferEndBlock(BlockEnd chatItem) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: space),
        child: Center(
          child: Text(
            chatItem.text,
            textScaleFactor: 0.7,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );

  Widget _buildMsg(Msg msg) {
    var mainContent = Padding(
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

    if (msg.reactions != null) {
      var reactions = ReactionsBlock(msg.reactions);
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            mainContent,
            Padding(
              padding: const EdgeInsets.only(
                  left: 39.0, right: 36, top: space, bottom: space05),
              child: reactions,
            )
          ]);
    } else
      return mainContent;
  }

  Widget _avatarArea(Msg msg) {
    var avatarSize = 32.0;
    var time = Text(
      msg.bubbleTime,
      style: TextStyle(color: Colors.grey), //TODO monospace here needed
      textScaleFactor: 0.7,
    );

    var lines = msg.bubbleTimeLines;
    var offset = -14.0 * lines + lines - 1;

    var items = <Widget>[
      SizedBox(width: avatarSize),
      Positioned(
        //TODO for transferredMessages that has additionally day or year increase bottom padding (-38,-26)
        bottom: (msg.avatar != null ? offset : 0.0),
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
            color: Theme
                .of(context)
                .cardColor,
            border: !msg.isImportant ? null : Border.all(color: msg.color),
            borderRadius: BorderRadius.only(
                topLeft: msg.isContinuation
                    ? Radius.circular(space2)
                    : Radius.circular(space4),
                topRight: msg.isContinuation
                    ? Radius.circular(space2)
                    : Radius.circular(space4),
                bottomRight: msg.avatar == null ||
                    msg.headerInfo?.withIndicator ==
                        false //forwarding header block
                    ? Radius.circular(space2)
                    : Radius.circular(space4),
                bottomLeft:
                msg.avatar == null ? Radius.circular(space2) : Radius.zero

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
    if (msg.text != null) {
      var text = Text(msg.text,
          style: DefaultTextStyle
              .of(context)
              .style
              .apply(fontSizeFactor: 1.2));
      if (msg.editTime != null)
        t.add(Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: <Widget>[
              text,
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(msg.editTime, textScaleFactor: 0.7),
              )
            ]));
      else
        t.add(text);
    }

    if (msg.headerInfo != null) t.add(_buildHeaderInfo(msg));
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
      colItems.add(ReplyText(p.author)); // Use author widget
      colItems.add(ReplyText(p.content)); // Use author widget
    }
    return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Container(width: 2.0, height: 32.0, color: Colors.blueAccent),
      SizedBox(width: space2),
      Flexible(
        child: Column(
          children: colItems,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      )
    ]);
  }

  Widget _buildHeaderInfo(Msg msg) {
    var headerInfo = msg.headerInfo;
    var colItems = List<Widget>();
    colItems.add(SizedBox(height: space));
    colItems.add(Text(headerInfo.line1, style: TextStyle(color: msg.color)));
    colItems.add(Text(headerInfo.line2,
        style: TextStyle(color: msg.color))); //TODO Use author widget
    if (msg.headerInfo.withIndicator) {
      colItems.add(SizedBox(height: space));
      colItems.add(Container(height: 2.0, color: msg.color));
    }
    return Column(
        children: colItems, crossAxisAlignment: CrossAxisAlignment.stretch);
  }
}

class ReplyText extends StatelessWidget {
  final String text;

  ReplyText(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text,
          maxLines: 1, overflow: TextOverflow.ellipsis, textScaleFactor: 0.9);
}
