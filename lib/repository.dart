import 'package:flutter/material.dart';
import 'package:testchat/data.dart';
import 'package:testchat/data_generator.dart';
import 'package:testchat/ui.dart';
import 'package:testchat/utilities.dart';

class MessageSource {
  // if message from same user and time between messages lower than this threshold
  // messages positioned closer to each other
  static const stickThreshold = 1000 * 60 * 2;



  var usersToColorMap = Map<User, Color>();
  var unusedColorIndex = 0;

  //TODO remove black colors and ann more colors between
  // не надо делать shuffle, распределить цвета сначала с сильным отличием, потом разбавлять промежуточными цветами
  var colorsSource = List<MaterialColor>.from(Colors.primaries);

  Color associatedColorWithUser(User user) {
    return usersToColorMap.putIfAbsent(user, () {
      return colorsSource[unusedColorIndex++ % colorsSource.length].shade800;
    });
  }

  List<ChatItem> chatItemsFrom(List<Message> messages) {
    colorsSource.shuffle();

    var chatItems = List<ChatItem>();
    Message savedTransferMessage;
    DateTime lastDayLabel;

    for (int i = 0; i < messages.length; i++) {
      var m = messages[i];
      var userColor = associatedColorWithUser(m.author);
      var msgTime = timeFormatter.format(m.dateTime);

      Avatar avatar;
      String authorName;
      Message pm = i > 0 ? messages[i - 1] : null;

      Reply reply;
      if (m.replyTo != null) {
        for (int h = i - 1; h > 0; h--) {
          if (m.replyTo == messages[h].id) {
            var rm = messages[h];
            var mp = MsgPreview(rm.author.fullName, rm.text);
            reply = p(90) ? Reply(mp, null) : Reply(null, 'Недоступно');
            break;
          }
        }
      }

      var timeLines = 1;
      if (m.transferInfo != null) savedTransferMessage = m;
      if (m.transferMessageId != null) {
        //we must choose avatar
        msgTime = transferSymbol + msgTime;
        if (daysDiffer(savedTransferMessage.dateTime, m.dateTime)) {
          // Year not supported yet
          msgTime = transferSymbol + dayFormat(m.dateTime) + '\n' + msgTime;
          timeLines = 2;
        }
      }


      //TODO check for null
      avatar = Avatar(m.author.firstName[0] + m.author.lastName[0]);
      if (pm != null &&
          pm.transferInfo == null &&
          m.author == pm.author &&
          m.dateTime.difference(pm.dateTime).inMilliseconds < stickThreshold) {
        authorName = null;
        try {
          (chatItems[chatItems.length - 1] as Msg).avatar = null;
        } catch(e) {
          print('e');
        }
      } else {
        authorName = (m.transferMessageId != null ? transferSymbol : '')+m.author.fullName ;
      }

      if (pm != null &&
          m.transferMessageId == null &&
          pm.transferMessageId != null) {
        chatItems.add(TransferEndBlock(savedTransferMessage));
      }

      if (pm == null /*first message*/ ||
          m.transferMessageId == null /*transfered messages not used*/ &&
              daysDiffer(lastDayLabel, m.dateTime)) {
        lastDayLabel = m.dateTime;
        chatItems.add(DaySeparator(m.dateTime));
      }

      var t = Msg(
        id: m.id,
        color: userColor,
        avatar: avatar,
        authorName: authorName,
        bubbleTimeLines: timeLines,
        bubbleTime: msgTime,
        text: m.text,
        isImportant: m.isImportant,
        transferInfo: m.transferInfo,
        isForeign: m.transferMessageId != null,
        reply: reply,
      );

      chatItems.add(t);
    }
    return chatItems;
  }

  List<ChatItem> generate() {
    DataGenerator dg = DataGenerator();
    var ms = dg.generateMessages();
    return chatItemsFrom(ms);
  }

//  void nextModification(int modificationNumber) {
//    var nail = AuthorName("Nail Gilaziev", Colors.amber);
//    var borisov = AuthorName("Dmitriy Borisov", Colors.indigoAccent);
//    var fail = AuthorName("Fail Fachriev", Colors.teal);
//    switch (modificationNumber) {
//      case 0:
//        var m = Msg(
//          0,
//          Avatar(nail.color),
//          nail,
//          "08:11",
//          "First simple text mesage",
//        );
//        msgs.add(m);
//        break;
//      case 1:
//        var m = Msg(
//          1,
//          Avatar(nail.color),
//          nail,
//          "08:28",
//          "second message",
//        );
//        msgs.add(m);
//        break;
//      case 2:
//        var m = Msg(
//          2,
//          Avatar(borisov.color),
//          borisov,
//          "12:59",
//          "Third MESSAGE that use capitalisation. And it use new sentences too. It have a very long text, but without new lines. ",
//        );
//        msgs.add(m);
//        break;
//      case 3:
//        var msg = msgs[0];
//        msg.text = "First Simple Text Mesage (modified)";
//        msg.modificationCount++;
//        break;
//      case 4:
//        var msg = msgs[1];
//        msg.text =
//        "Second message is modified now. And it has a lot of symbols. And it has a new line symbols.\n\nGetters and setters are special methods that provide read and write access to an object’s properties. Recall that each instance variable has an implicit getter, plus a setter if appropriate.";
//        msg.modificationCount++;
//        break;
//      default:
//        String text = "";
//        var rnd = new Random();
//        int symbolsCount = rnd.nextInt(200);
//        bool caps = rnd.nextInt(100) > 70;
//        for (int i = 0; i < symbolsCount; i++) {
//          var charCode = rnd.nextInt(25) + (caps ? 65 : 97);
//          text += String.fromCharCode(charCode);
//        }
//        text = text.trim();
//        var authors = [nail, borisov, fail];
//        var author = authors[rnd.nextInt(3)];
//        var m = Msg(
//          modificationNumber,
//          Avatar(author.color),
//          author,
//          "14:" +
//              (modificationNumber % 60 < 10
//                  ? ("0" + (modificationNumber % 60).toString())
//                  : (modificationNumber % 60).toString()),
//          text,
//        );
//        msgs.add(m);
//
//        if (rnd.nextInt(100) > 80) {
//          var msg = msgs[rnd.nextInt(modificationNumber - 2)];
//          msg.text = text;
//          msg.modificationCount++;
//        }
//    }
//  }

}
