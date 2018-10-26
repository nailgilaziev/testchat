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

  String dependTimeFormatting(DateTime base, DateTime src,
      {bool separateLines: false, String pretendSymbol: ''}) {
    var t = timeFormatter.format(src);
    if (base == null) return t;
    t = pretendSymbol + t;
    if (daysDiffer(base, src)) {
      t = pretendSymbol + dayFormat(src) + (separateLines ? '\n' : ' ') + t;
      if (base.year != src.year) {
        t = '$pretendSymbol${src.year}${separateLines ? '\n' : ' '}$t';
      }
    }
    return t;
  }

  List<ChatItem> chatItemsFrom(List<Message> messages) {
    colorsSource.shuffle();

    var chatItems = List<ChatItem>();
    Message savedHeaderMessage;
    DateTime lastDayLabel;

    for (int i = 0; i < messages.length; i++) {
      var m = messages[i];
      var userColor = associatedColorWithUser(m.author);
      var msgTime = timeFormatter.format(m.dateTime);

      //TODO check for null in names
      Avatar avatar = Avatar(m.author.firstName[0] + m.author.lastName[0]);
      String authorName = m.author.fullName;
      Message pm = i > 0 ? messages[i - 1] : null;
      MsgHeaderInfo msgHeaderInfo;

      Reply reply;
      if (m.replyTo != null) {
        for (int h = i - 1; h > 0; h--) {
          if (m.replyTo == messages[h].id) {
            var rm = messages[h];
            String text = rm.text;
            if (text == null) {
              if (rm.headerInfo != null) {
                if (rm.headerInfo.type == HeaderType.transferring)
                  text = transferSymbol + 'Перенос сообщений';
                else
                  text = forwardSymbol + 'Пересылка сообщений';
              }
            }
            if (text == null) text = '<No data>';
            var mp = MsgPreview(rm.author.fullName, text);
            reply = p(30) ? Reply(mp, null) : Reply(null, 'Недоступно');
            break;
          }
        }
      }

      var timeLines = 1;
      if (m.headerInfo != null) {
        savedHeaderMessage = m;
        msgHeaderInfo = MsgHeaderInfo(m.headerInfo);
      }
      if (m.transferHeaderId != null || m.forwardHeaderId != null) {
        var symbol =
        savedHeaderMessage.headerInfo.type == HeaderType.transferring
            ? transferSymbol
            : forwardSymbol;
        authorName = symbol + authorName;

        if (m.forwardHeaderId != null) {
          avatar = null;
        }
        msgTime = dependTimeFormatting(savedHeaderMessage.dateTime, m.dateTime,
            separateLines: true, pretendSymbol: symbol);
        timeLines = '\n'
            .allMatches(msgTime)
            .length + 1;
      }

      //Следующее сообщение за заголовком пересылки тоже обязано имень имя автора
      // и не должно слипаться с заголовком. Гарантируется, что пересылается ≥ 1 сообщения
      bool isNextAfterHeader = (pm != null && pm.headerInfo != null);

      // Текущее сообщение идет сразу за пересылаемым блоком сообщений(transferred or forwarding)
      // Вне зависимости от других условий, это сообщение должно иметь имя автора.
      // Не должно быть попытки произвести слипание сообщений
      // Это для случая, когда в течении времени stickThreshold переслали
      // сообщения автора и он сразу после этого написал
      bool isNextAfterBlock = (pm != null &&
          (pm.transferHeaderId != null && m.transferHeaderId == null ||
              pm.forwardHeaderId != null && m.forwardHeaderId == null));

      // Если автор в течение stickThreshold дописал еще одно сообшение в добавок к предыдущему
      // то в этом случае сообщения слипаются - у первого сообщения есть имя автора и нет аватарки
      // а у последнего наоборот. Расстояния между bubble уменьшаются и они слипаются
      bool isContinuousMessage = (pm != null &&
          m.author == pm.author &&
          m.dateTime
              .difference(pm.dateTime)
              .inMilliseconds < stickThreshold);

      if (!isNextAfterHeader &&
          !isNextAfterBlock &&
          !m.isImportant &&
          isContinuousMessage) {
        //remove avatar from previous msg
        (chatItems[chatItems.length - 1] as Msg).avatar = null;
        //clear author name from current msg
        authorName = null;
      }

      if (isNextAfterBlock) {
        chatItems.add(BlockEnd(savedHeaderMessage));
      }

      if (pm == null /*first message*/ ||
          m.transferHeaderId == null /*transfered messages not used*/ &&
              m.forwardHeaderId == null /*forwarded messages not used*/ &&
              daysDiffer(lastDayLabel, m.dateTime)) {
        lastDayLabel = m.dateTime;
        chatItems.add(DaySeparator(m.dateTime));
      }

      List<ChatItemReaction> msgReactions;
      if (m.reactions != null) msgReactions = parseReactions(m.reactions);

      String editTime;
      if (m.editDateTime != null) {
        editTime =
            'изменено ' + dependTimeFormatting(m.dateTime, m.editDateTime);
      }

      var t = Msg(
          id: m.id,
          color: userColor,
          avatar: avatar,
          authorName: authorName,
          bubbleTimeLines: timeLines,
          bubbleTime: msgTime,
          editTime: editTime,
          text: m.text,
          isImportant: m.isImportant,
          headerInfo: msgHeaderInfo,
          isForwarding: m.forwardHeaderId != null,
          reply: reply,
          reactions: msgReactions);

      chatItems.add(t);
    }
    return chatItems;
  }

  var myUserId = 1;

  List<ChatItemReaction> parseReactions(List<Reaction> rs) {
    //Reactions must be sorted by date
    var m = Map<String, Set<int>>();
    rs.forEach((r) {
      var users = m.putIfAbsent(r.reaction, () {
        var s = Set<int>();
        s.add(r.userId);
        return s;
      });
      if (r.deleted)
        users.remove(r.userId);
      else
        users.add(r.userId);
    });
    var res = m.entries
        .where((e) => e.value.length > 0)
        .map((e) =>
        ChatItemReaction(e.key, e.value.length, e.value.contains(myUserId)))
        .toList();
    return res.isEmpty ? null : res;
  }

  List<ChatItem> generate() {
    DataGenerator dg = DataGenerator();
    var ms = dg.generateMessages();
    return chatItemsFrom(ms);
  }
}
