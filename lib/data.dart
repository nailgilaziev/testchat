import 'package:meta/meta.dart';

class TransferInfo {
  int count;
  int from;

  TransferInfo({
    @required this.count,
    @required this.from,
  });
}

class Message {
  int id;
  User author;

  /// creation time by user
  DateTime originDateTime;

  /// registered on server time
  DateTime dateTime;
  DateTime editDateTime;
  TransferInfo transferInfo;
  String text;
  int replyTo;
  int transferMessageId;
  bool isImportant;

  Message({
    @required this.id,
    @required this.author,
    this.originDateTime,
    @required this.dateTime,
    this.editDateTime,
    @required this.text,
    this.isImportant,
    this.replyTo,
    this.transferInfo,
    this.transferMessageId,
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
