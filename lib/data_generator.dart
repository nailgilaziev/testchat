import 'package:testchat/data.dart';
import 'package:testchat/utilities.dart';

class DataGenerator {
  var lorem =
      "Lorem ipsum. Dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore. Et dolore magna aliqua. Ut enim ad minim veniam. Quis nostrud exercitation ullamco. ok.  Laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Ok. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Okay. Sed ut perspiciatis unde omnis iste natus. Error sit voluptatem accusantium. doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo. Okey. Inventore veritatis et quasi architecto. beatae vitae dicta sunt explicabo. +. Nemo enim ipsam voluptatem quia voluptas. sit aspernatur. +1.  aut odit aut fugit, sed quia consequuntur. magni dolores eos qui ratione voluptatem sequi nesciunt. а. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit. 2. sed quia non numquam eius modi tempora incidunt ut labore et. dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem. ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit. Qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? But I must explain to you how all this mistaken idea of denouncing pleasure and praising pain was born. And I will give you a complete account of the system, and expound the actual teachings of the great explorer of the truth, the master-builder of human happiness. No one rejects, dislikes, or avoids pleasure itself, because it is pleasure, but because those who do not know how to pursue pleasure rationally encounter consequences that are extremely painful. Nor again is there anyone who loves or pursues or desires to obtain pain of itself, because it is pain, but because occasionally circumstances occur in which toil and pain can procure him some great pleasure.1. These cases are perfectly. simple and easy to distinguish. In a free hour, when our power. of choice is untrammelled and when nothing. prevents our being able to do what we like best. every pleasure is to be welcomed and every pain avoided. But in certain circumstances and owing to the claims. of duty or the obligations of business it will frequently occur that. pleasures have to be repudiated and annoyances accepted. The wise man therefore always holds. in these matters to this principle of selection. he rejects pleasures. to secure other greater pleasures, or else he endures. pains to avoid worse pains. I seeI quitLet goMe too. My god!No way!Come on. Hold on. I agreeNot bad. Not yet. See you. Shut up!So long. Why not?Allow me. Be quiet!Cheer up!Good job!Have fun!How much?I'm full. I'm home. I'm lost. My treat. So do I. This way.After you. Bless you!Follow me. Forget it!Good luck!I decline!I promise. Of course!Slow down!Take care!They hurt. Try again. Watch out!What's up?Be careful!Bottoms up!Don't move!Guess what?I doubt itI think so. I'm single. Keep it up!Let me see. Never mind. No problem !That's all !";

  var users = [
    User(id: 1, firstName: 'Nail', lastName: 'Gilaziev'),
    User(id: 1, firstName: 'Dmitryi', lastName: 'Ulyanov'),
    User(id: 1, firstName: 'Marat', lastName: 'Ismagilov'),
    User(id: 1, firstName: 'Dmitryi', lastName: 'Borisov'),
    User(id: 1, firstName: 'Sergey', lastName: 'Shiskin'),
    User(id: 1, firstName: 'Julia', lastName: 'Volkova(Perelman)'),
    User(id: 1, firstName: 'Igor', lastName: 'Zinoviev'),
  ];

  List<Message> generateMessages() {
    var messages = List<Message>();
    var longSentences = lorem.split('.');
    var sentences =
        longSentences.map((l) => l.split('?')).expand((f) => f).toList();
    sentences..shuffle();

    var timeDifference = Duration(days: 360);
    int userIndex = 0;
    for (int i = 0, lastTransferTime = 0; i < 300; i++, lastTransferTime++) {
      var msgId = i;
      if (p(40)) userIndex = rnd.nextInt(users.length);

      var secondsIncrement = rnd.nextInt(200);
      var minutesIncrement = 0;
      if (p(80)) minutesIncrement = rnd.nextInt(200);
      var dayIncrement = 0;
      if (p(90)) dayIncrement = rnd.nextInt(10);

      timeDifference -= Duration(
          days: dayIncrement,
          minutes: minutesIncrement,
          seconds: secondsIncrement);
      var msgDateTime = DateTime.now().subtract(timeDifference);

      var sentenceCount = rnd.nextInt(2) + 1;
      var messageText = "";
      for (int k = 0; k < sentenceCount; k++) {
        messageText += sentences[rnd.nextInt(sentences.length)];
        if (p(97)) messageText += "\n";
      }

      var msgText = messageText.trim();
      var msgIsImportant = p(95);
      TransferInfo ti;
      if (i > 10 && lastTransferTime > 10 && p(50)) {
        lastTransferTime = 0;
        //time to mark items forvarded
        int count = rnd.nextInt(10);
        msgId = i - count;
        ti = TransferInfo(
          count: count,
          from: 100000 + i, //must be entityId
        );
        for (int h = i - 1; h > i - 1 - count; h--) {
          messages[h].transferMessageId = msgId;
          messages[h].id++;
        }
      }

      int replyMsgId;
      if (i > 10 && p(80)) {
        replyMsgId = i - 10 - rnd.nextInt(20);
      }

      var m = Message(
          id: msgId,
          author: users[userIndex],
          dateTime: msgDateTime,
          text: msgText,
          isImportant: msgIsImportant,
          transferInfo: ti,
          replyTo: replyMsgId);
      if (ti != null)
        messages.insert(i - ti.count, m);
      else
        messages.add(m);
    }
    return messages;
  }
}
