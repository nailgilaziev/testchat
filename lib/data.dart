import 'package:meta/meta.dart';

enum HeaderType { transferring, forwarding }

class HeaderInfo {
  int count;
  int from;
  String fromName;
  HeaderType type;

  HeaderInfo({
    @required this.type,
    @required this.count,
    @required this.from,
    @required this.fromName,
  });
}

class Reaction {
  DateTime dateTime;
  int userId;
  String reaction;
  bool deleted;

  Reaction({
    @required this.dateTime,
    @required this.userId,
    @required this.reaction,
    this.deleted: false,
  });
}

class Message {
  int id;
  User author;

  // creation time by user on device (is for analyze only)

  /// registered on server time
  DateTime dateTime;
  DateTime editDateTime;
  HeaderInfo headerInfo;
  String text;
  int replyTo;
  int transferHeaderId;
  int forwardHeaderId;
  bool isImportant;
  List<Reaction> reactions;

  Message({
    @required this.id,
    @required this.author,
    @required this.dateTime,
    this.editDateTime,
    @required this.text,
    this.isImportant: false,
    this.replyTo,
    this.headerInfo,
    this.transferHeaderId,
    this.forwardHeaderId,
    this.reactions
  });
}

class User {
  int id;
  bool isBot;
  String firstName;
  String lastName;

  User({
    @required this.id,
    this.isBot = false,
    @required this.firstName,
    @required this.lastName,
  });

  //TODO protect from nulls
  String get fullName => firstName + ' ' + lastName;
}
