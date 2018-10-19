import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testchat/data.dart';
import 'package:testchat/utilities.dart';


class Avatar {
  String text;
  Avatar(this.text);
}

abstract class ChatItem {
  String get uniqueKey;

  String get text;
}

class DaySeparator implements ChatItem {
  String _text;

  var mdy = DateFormat.yMMMMEEEEd();
  var md = DateFormat.MMMMEEEEd();

  DaySeparator(DateTime dateTime) {
    var now = DateTime.now();
    if (dateTime.year == now.year) {
      _text = md.format(dateTime);
      if (dateTime.month == now.month && dateTime.day == now.day)
        _text = "Сегодня - $_text"; //TODO Localize - today if EN
    } else {
      _text = mdy.format(dateTime);
    }
  }

  @override
  String get text => _text;

  @override
  String get uniqueKey => 'day' + text;
}

//TODO User IN OUT ChatItem when transfer ocurred(In)

//Для того, чтобы можно было посмотреть когда осуществлен трансфер в конце блока пересланных сообщений нужно добавить подсказку
class TransferEndBlock implements ChatItem {

  Message transfer;

  TransferEndBlock(this.transfer);

  @override
  String get text => 'Перенесено в ${timeFormatter.format(transfer.dateTime)} ${transfer.author.fullName}';

  @override
  String get uniqueKey => "transferEndHint${transfer.id}";

}

class MsgPreview {
  String author;
  String content;

  MsgPreview(this.author,this.content);
}

class Reply {
  MsgPreview preview;
  String fallback;

  Reply(this.preview, this.fallback);
}

class Msg implements ChatItem {
  int id;
  Color color;
  Avatar avatar;
  String authorName;
  String authorInfo; // роль и время в перенесенных сообщениях
  int bubbleTimeLines; //transfered messages can have multiline day/month and year
  String bubbleTime;
  TransferInfo transferInfo;

  bool isForeign;

  String text;
  bool isImportant;
  Reply reply;

  int modificationCount = 0;

  Msg({@required this.id,
    @required this.color,
    @required this.avatar,
    @required this.authorName,
    this.bubbleTimeLines = 1,
    @required this.bubbleTime,
    @required this.text,
    this.isImportant: false,
    this.reply,
    this.transferInfo,
    this.isForeign,
  });

  @override
  String get uniqueKey => id.toString();

  bool get isModified => modificationCount > 0;

  bool get isContinuation => authorName == null || isForeign;
}
