import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../components/joke.dart';
import '../services/storage.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late JokeManager _jokeManager;

  List<Joke> favJokes = [];

  @override
  void initState() {
    super.initState();
    _jokeManager = JokeManager();
    _jokeManager.init().then((value) => _fetchFavJokes());
  }

  void _fetchFavJokes() async {
    //fetch the saved jokes from the device storage
    final result = await _jokeManager.fetchFavJokesFromLocal();
    //check if the component is mounted first
    if (mounted) {
      setState(() {
        favJokes = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text("My Favorites",
              style: TextStyle(
                  color: Color(0xFFF06292),
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          SizedBox(
            height: 15,
          ),
          Expanded(
            child: favJokes.isEmpty
                ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "You have no\nFavorites yet!",
                  style: TextStyle(fontSize: 32, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Icon(
                  Icons.heart_broken,
                  size: 90,
                  color: Colors.grey,
                ),
              ],
            )
                : ListView.separated(
              itemCount: favJokes.length,
              separatorBuilder: (context, index) => Container(
                child: const SizedBox(height: 10),
              ),
              itemBuilder: (context, index) {
                //sort the jokes based on their score
                favJokes.sort((a, b) => b.score.compareTo(a.score));
                Joke joke = favJokes[index];
                return Slidable(
                  // The start action pane is the left side when using a right-to-left swipe
                    endActionPane: ActionPane(
                      motion: const BehindMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (BuildContext context) {
                            _jokeManager.unsaveFavJokesFromLocal(joke);
                            //check the component is mounted
                            if (mounted) {
                              setState(() {
                                favJokes.removeAt(index);
                              });
                            }

                            // Handle favorite action
                            // For example, update the state to mark the joke as favorite
                          },
                          backgroundColor: const Color(0xFFF06292),
                          foregroundColor: Colors.white,
                          icon: Icons.heart_broken,
                          label: 'Remove from Favorites',
                        ),
                      ],
                    ),
                    child: JokeCard(
                      joke: joke,
                      toggleVote: (UpdateAction action) {
                        //no action
                      },
                      hasVote: false,
                      index: index,
                    ));
              },
            ),
          )
        ],
      ),
    );
  }
}
