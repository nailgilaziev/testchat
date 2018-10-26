import 'package:flutter/material.dart';
import 'package:testchat/ui.dart';
import 'package:testchat/utilities.dart';

class _ReactionButton extends StatelessWidget {
  final ChatItemReaction reaction;

  const _ReactionButton(this.reaction);

  void _tap() {
    if (reaction != null)
      print('reaction pressed, send event and momentally react in ui');
    else
      print(
          'add new reactions pressed, call callback from inherited widget open window');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(width: 0.0, color: _borderColor(context)),
          borderRadius: new BorderRadius.circular(space2),
        ),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _tap,
              borderRadius: BorderRadius.circular(space2),
              child: Container(
                  padding: EdgeInsets.only(left: space2, right: space2),
                  child: reaction == null
                      ? _buildAddIcon()
                      : _buildReactionItem()),
            )));
  }

  Row _buildReactionItem() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          reaction.reaction,
          textScaleFactor: 1.6,
        ),
        SizedBox(width: space, height: 30.0),
        //addicon button and this must be the same size
        Text(
          reaction.count.toString(),
          textScaleFactor: 1,
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Padding _buildAddIcon() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Icon(Icons.playlist_add, color: Colors.grey),
    );
  }

  Color _borderColor(BuildContext context) {
    return reaction?.iReacted == true
        ? Colors.blueAccent
        : Theme.of(context).cardColor;
  }
}

class ReactionsBlock extends StatelessWidget {
  final List<ChatItemReaction> reactions;

  const ReactionsBlock(this.reactions);

  @override
  Widget build(BuildContext context) {
    var items = reactions.map(_toReactionButton).toList();
    items.add(_ReactionButton(null)); //trailing add button
    return Wrap(
      spacing: space,
      runSpacing: space,
      children: items,
    );
  }

  Widget _toReactionButton(ChatItemReaction r) => _ReactionButton(r);
}
