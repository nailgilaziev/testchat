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

class TransferredDaySeparator extends DaySeparator {
  TransferredDaySeparator(DateTime dateTime) : super(dateTime) {
    _text = '$transferSymbol $_text';
  }
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

//TODO User IN OUT ChatItem when transfer occurred(In)

//Для того, чтобы можно было посмотреть когда осуществлен трансфер в конце блока пересланных сообщений нужно добавить подсказку
class BlockEnd implements ChatItem {
  Message header;

  //TODO сделать полностью как блок сообщения
  BlockEnd(this.header);

  @override
  String get text {
    var action = header.headerInfo.type == HeaderType.transferring
        ? 'Перенесено'
        : 'Переслано';
    return '$action в ${timeFormatter.format(header.dateTime)} ${header.author
        .fullName}';
  }

  @override
  String get uniqueKey => "blockEndHint${header.id}";
}

class MsgPreview {
  String author;
  String content;

  MsgPreview(this.author, this.content);
}

class Reply {
  MsgPreview preview;
  String fallback;

  Reply(this.preview, this.fallback);
}

class MsgHeaderInfo {
  String line1;
  String line2;
  bool withIndicator;

  MsgHeaderInfo(HeaderInfo info) {
    String symbol;
    String action;
    if (info.type == HeaderType.transferring) {
      symbol = transferSymbol;
      action = 'Перенесено';
      withIndicator = true;
    } else {
      symbol = forwardSymbol;
      action = 'Переслано';
      withIndicator = false;
    }

    line1 = symbol + action + ' сообщений: ${info.count}';
    line2 = symbol + 'Из чата: ${info.fromName} ${info.from}';
  }
}

class ChatItemReaction {
  String reaction;
  int count;
  bool iReacted;

  ChatItemReaction(this.reaction, this.count, this.iReacted);
}




class Msg implements ChatItem {
  int id;
  Color color;
  Avatar avatar;
  String authorName;
  String authorInfo; // роль и время в перенесенных сообщениях
  int bubbleTimeLines; //transferred messages can have multiline day/month and year
  String bubbleTime;
  String editTime;
  MsgHeaderInfo headerInfo;

  bool isForwarding;

  String text;
  bool isImportant;
  Reply reply;
  List<ChatItemReaction> reactions;

  int modificationCount = 0;

  Msg({
    @required this.id,
    @required this.color,
    @required this.avatar,
    @required this.authorName,
    this.bubbleTimeLines = 1,
    @required this.bubbleTime,
    @required this.text,
    this.editTime,
    this.isForwarding,
    this.isImportant: false,
    this.reply,
    this.headerInfo,
    this.reactions,
  });

  @override
  String get uniqueKey => id.toString();

  bool get isModified => modificationCount > 0;

  bool get isContinuation => authorName == null || isForwarding;
}
