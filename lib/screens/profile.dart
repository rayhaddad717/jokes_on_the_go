import 'package:flutter/material.dart';
import 'package:jokes_on_the_go/services/storage.dart';

import '../services/api.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late StatisticsManager _statisticsManager;
  int nbUpvotes = 0;
  int nbDownvotes = 0;
  int nbViewed = 0;
  int nbSaved = 0;

  @override
  void initState() {
    _statisticsManager = StatisticsManager();
    _statisticsManager.init().then((value) {
      fetchStatistics();
    });
  }

  //fetch the statistics
  void fetchStatistics() async {
    int? nbDownvotesResult =
    await _statisticsManager.getStatistics(STATISTICS.DOWNVOTE);
    int? nbUpvotesResult =
    await _statisticsManager.getStatistics(STATISTICS.UPVOTE);
    int? nbViewedResult =
    await _statisticsManager.getStatistics(STATISTICS.VIEWED_JOKES);
    int? nbSavedResult =
    await _statisticsManager.getStatistics(STATISTICS.SAVED_JOKES);
    if (mounted) {
      setState(() {
        if (nbDownvotesResult != null) nbDownvotes = nbDownvotesResult;
        if (nbUpvotesResult != null) nbUpvotes = nbUpvotesResult;
        if (nbViewedResult != null) nbViewed = nbViewedResult;
        if (nbSavedResult != null) nbSaved = nbSavedResult;
      });
    }
  }

  void _clearData() async {
    if (mounted) {
      setState(() {
        nbUpvotes = 0;
        nbDownvotes = 0;
        nbViewed = 0;
        nbSaved = 0;
      });
    }
    _statisticsManager.clearData();
    API.lastPage = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(15, 10, 15, 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const Text("My Statistics",
                  style: TextStyle(
                      color: Color(0xFF9575cd),
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF9575cd), width: 5)),
                      child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            children: [
                              Text(
                                "$nbUpvotes",
                                style: const TextStyle(fontSize: 36),
                              ),
                              const Text("  Upvotes  ")
                            ],
                          ))),
                  Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF9575cd), width: 5)),
                      child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            children: [
                              Text(
                                "$nbDownvotes",
                                style: const TextStyle(fontSize: 36),
                              ),
                              const Text(" Downvotes")
                            ],
                          ))),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                          Border.all(color: Color(0xFF9575cd), width: 5)),
                      child: Padding(
                          padding: EdgeInsets.all(25),
                          child: Column(
                            children: [
                              Text(
                                "$nbViewed",
                                style: TextStyle(fontSize: 36),
                              ),
                              const Text("Viewed Jokes")
                            ],
                          ))),
                  Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                          Border.all(color: Color(0xFF9575cd), width: 5)),
                      child: Padding(
                          padding: const EdgeInsets.all(25),
                          child: Column(
                            children: [
                              Text(
                                "$nbSaved",
                                style: const TextStyle(fontSize: 36),
                              ),
                              const Text("Saved Jokes")
                            ],
                          ))),
                ],
              ),
            ],
          ),
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
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm'),
                        content: const Text('This will clear all your data.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // Close the dialog when the "Close" button is pressed
                              Navigator.of(context).pop();
                            },
                            child: const Text('Close'),
                          ),
                          TextButton(
                            onPressed: () {
                              _clearData();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Confirm'),
                          ),
                        ],
                      );
                    });
              },
              style: ButtonStyle(
                shadowColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
                foregroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
              ),
              child: const Text('Clear Data',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
