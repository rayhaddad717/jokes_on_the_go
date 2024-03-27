import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jokes_on_the_go/components/joke.dart';
import 'package:jokes_on_the_go/services/api.dart';
import 'package:jokes_on_the_go/services/storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late API _api;
  late ScoreManager _scoreManager;
  late JokeManager _jokeManager;
  late StatisticsManager _statisticsManager;
  late int _page;

  List<Joke> allJokes = [];
  bool isLoading = true;

  //sets containing all the ids of the saved jokes
  Set<String> favoritedJokeIds = {};

  @override
  void initState() {
    super.initState();
    if (API.lastPage == 0) {
      //on the first init
      //get a random page every time to get a random joke
      //total number of jokes are 744 => safely use a total of 74 pages for 8 jokes per page
      Random random = Random();
      _page = random.nextInt(74) + 1;
    } else {
      //we are going back to this page from another page
      //used the last fetched paged
      //the results will be cached
      _page = API.lastPage;
    }
    _api = API();
    _statisticsManager = StatisticsManager();
    _statisticsManager.init();
    _scoreManager = ScoreManager();
    _scoreManager.init();
    _jokeManager = JokeManager();
    _jokeManager.init().then((value) async {
      final favoriteJokes = await _jokeManager.fetchFavJokesFromLocal();
      favoritedJokeIds = favoriteJokes.map((joke) => joke.id).toSet();
      _fetchJokes();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  //to resole the scores
  Future<void> _patchScores(List<Joke> jokes) async {
    for (Joke joke in jokes) {
      //check if joke already voted
      int? score = await _scoreManager.getScoreForId(joke.id);
      if (score != null) {
        joke.score = score;
      }
    }
  }

  //to fetch new jokes
  Future<void> _fetchJokes() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final jokesResponse =
    await _api.fetchJokes(_page); // Fetch jokes when the app initializes
    if (mounted) {
      //make sure we have the up to date scores
      await _patchScores(jokesResponse);

      setState(() {
        allJokes = [...jokesResponse];
        //increment the page count
        //make sure the page number is less than 74
        _page = (_page % 74) + 1;
        //the page is no longer loading
        isLoading = false;
      });
    }
  }

  //to upvote or downvote a joke
  void _toggleVote(Joke joke, UpdateAction action) {
    if (mounted) {
      setState(() {
        if (action == UpdateAction.upvote) {
          joke.score++;
        } else if (action == UpdateAction.downvote) {
          joke.score--;
        }
      });
      //save the voted score
      _scoreManager.setScoreForId(joke.id, joke.score);
    }
    //update the statistics
    if (action == UpdateAction.downvote) {
      _statisticsManager.incrementKey(STATISTICS.DOWNVOTE, 1);
    } else {
      _statisticsManager.incrementKey(STATISTICS.UPVOTE, 1);
    }
  }

  //check if a joke is already saved
  bool _isSaved(String id) {
    return favoritedJokeIds.contains(id);
  }

  //add a joke to our saved list
  void _saveJoke(String jokeID) {
    if (mounted) {
      setState(() {
        favoritedJokeIds.add(jokeID);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("New Jokes",
                  style: TextStyle(
                      color: Color(0xFF9575cd),
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              isLoading
                  ? const CircularProgressIndicator(
                  color: Color(
                      0xFF9575cd)) // Show loading indicator while fetching data
                  : allJokes.isEmpty
                  ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "We couldn't fetch any jokes!",
                    style:
                    TextStyle(fontSize: 32, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  Icon(
                    Icons.report_problem,
                    size: 90,
                    color: Colors.grey,
                  ),
                ],
              )
                  : Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 70),
                  itemCount: allJokes.length,
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    //sort the jokes based on their score
                    allJokes
                        .sort((a, b) => b.score.compareTo(a.score));
                    Joke joke = allJokes[index];
                    return Slidable(
                      // The start action pane is the left side when using a right-to-left swipe
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (BuildContext context) {
                                if (favoritedJokeIds
                                    .contains(joke.id)) return;
                                _saveJoke(joke.id);
                                _jokeManager
                                    .saveFavJokesToLocal(joke);
                              },
                              backgroundColor: _isSaved(joke.id)
                                  ? Colors.grey
                                  : const Color(0xFFF06292),
                              foregroundColor: Colors.white,
                              icon: Icons.favorite,
                              label: _isSaved(joke.id)
                                  ? 'Already in Favorites'
                                  : 'Add to Favorites',
                            ),
                          ],
                        ),
                        child: JokeCard(
                          joke: joke,
                          toggleVote: (UpdateAction action) {
                            _toggleVote(joke, action);
                          },
                          hasVote: true,
                          index: index,
                        ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFB3E5FC),
                  Color(0xFFF06292),
                ],
                stops: [0.5, 0],
                transform: GradientRotation(
                    140 * 3.14159 / 180), // Convert degrees to radians
              ),
            ),
            child: ElevatedButton(
              onPressed: () {
                // Handle button press here
                _fetchJokes();
              },
              style: ButtonStyle(
                shadowColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
                foregroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
              ),
              child: const Text('New Jokes',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
