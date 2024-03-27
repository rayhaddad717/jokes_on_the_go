import 'dart:ffi';
import 'package:flutter/material.dart';

class Joke {
  String joke;
  String id;
  int score;

  Joke(this.joke, this.id, this.score);

  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(json['joke'], json['id'],
        json.containsKey('score') ? json['score'] : 0);
  }

  toJson() {
    return {'joke': joke, 'id': id, 'score': score};
  }
}

//set the update action types
enum UpdateAction {
  upvote,
  downvote,
}

const Map<String, String> EMOJIE = {
  'LAUGHING': '😂',
  'HAPPY': '😀',
  'OK': '😑',
  'SAD': '😔',
  'ANGRY': '😡',
};

class JokeCard extends StatelessWidget {
  final Joke joke;
  final bool hasVote;
  final int index; //used to know the positioning for styling
  final Function(UpdateAction) toggleVote;

  const JokeCard(
      {super.key,
        required this.hasVote,
        required this.joke,
        required this.toggleVote,
        required this.index});

  String _getEmojie() {
    if (joke.score >= 10) {
      return EMOJIE['LAUGHING'] as String;
    } else if (joke.score > 0) {
      return EMOJIE['HAPPY'] as String;
    } else if (joke.score == 0) {
      return EMOJIE['OK'] as String;
    } else if (joke.score >= -10) {
      return EMOJIE['SAD'] as String;
    }
    return EMOJIE['ANGRY'] as String;
  }

  //get score border color based on score
  Color _getBorderColor() {
    Color borderColor = Colors.red; // Default border color

    if (joke.score > 0) {
      borderColor = Colors.green;
    } else if (joke.score >= 0) {
      borderColor = Colors.orange;
    }
    return borderColor;
  }

  Border _getBorder() {
    if (index == 0) {
      //add a top border for the first element only
      return const Border(
          bottom: BorderSide(width: 1, color: Colors.grey),
          top: BorderSide(width: 1, color: Colors.grey));
    } else {
      return const Border(bottom: BorderSide(width: 1, color: Colors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: _getBorder()),
      child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 8, top: 8, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              !hasVote
                  ? SizedBox(
                width: 20,
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    iconSize: 20,
                    color: Colors.blueGrey,
                    onPressed: () {
                      toggleVote(UpdateAction
                          .upvote); // Call toggleVote with upvote action
                    },
                  ),
                  Container(
                      width: 50,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: _getBorderColor(), width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${joke.score}",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 20,
                    color: Colors.blueGrey,
                    onPressed: () {
                      toggleVote(UpdateAction
                          .downvote); // Call toggleVote with upvote action
                    },
                  ),
                ],
              ),
              Expanded(
                child: Text(joke.joke),
              ),
              Text(_getEmojie(), style: const TextStyle(fontSize: 35))
            ],
          )),
    );
  }
}
