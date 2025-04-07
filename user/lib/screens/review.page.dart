import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:objectbox/objectbox.dart';
import '../entities/plan.entity.dart';
import '../entities/review.entity.dart';
import '../entities/user.entity.dart';
import '../objectbox.g.dart';
import '../utils/objectbox.store.dart';
import 'login.page.dart';

class ReviewsScreen extends StatefulWidget {
  final User? currentUser;

  ReviewsScreen({this.currentUser});

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late StreamSubscription<List<Reviews>> reviewsSub;
  late StreamController<List<Reviews>> reviewStreamController;
  Stream<List<Reviews>> get reviewStream => reviewStreamController.stream;
  User? currentUser;

 void _updateCurrentUser() async {
    if (widget.currentUser != null) {
      setState(() {
        currentUser = widget.currentUser;
      });
    } else {
      final userBox = await ObjectBox.getInstance().then((ObjectBox objectBox) {
        return objectBox.getUserBox();
      });
      currentUser = userBox.query(User_.id.notNull()).build().findFirst();
    }
  }

  @override
  void initState() {
    super.initState();
    reviewStreamController = StreamController<List<Reviews>>();
    ObjectBox.getInstance().then((objectBox) {
      reviewsSub = objectBox.getReviews().listen((retrievedReviews) {
        reviewStreamController.sink.add(retrievedReviews);
        setState(() {}); // Refresh the UI whenever the reviews change
      });
    });
    _updateCurrentUser();
  }

  @override
  void dispose() {
    reviewsSub.cancel();
    reviewStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Reviews>>(
      stream:  reviewStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.hasError) {
          return Text('Error: ${snapshot.error ?? "Unknown error"}');
        }
        final reviewsList = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text('Reviews'),
            backgroundColor: Colors.teal,
          ),
          body: ListView.builder(
            itemCount: reviewsList.length,
            itemBuilder: (context, index) {
              final review = reviewsList[index];
              return ListTile(
                title: Text('Plan: ${review.plan.target?.name ?? "Unknown"}'),
                subtitle: Text('Rating: ${review.rating}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReviewDetailPage(reviewId: review.id),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddReviewScreen(currentUser: currentUser),
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              }
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}

class AddReviewScreen extends StatefulWidget {
  final User? currentUser;

  AddReviewScreen({this.currentUser});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  late final Box<Reviews> _reviewsBox;
  late final Box<Plans> _plansBox;
  late List<Plans> plansList;

  String? selectedPlan;
  double? rating;
  String comment = '';

  @override
  void initState() {
    super.initState();
    ObjectBox.getInstance().then((ObjectBox objectBox) {
      _reviewsBox = objectBox.getReviewBox();
      _plansBox = objectBox.getPlanBox();
      setState(() {
        plansList = _plansBox.getAll(); // Update within setState
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Review'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              isExpanded: true,
              hint: Text('Select a plan'),
              value: selectedPlan,
              onChanged: (String? value) {
                setState(() {
                  selectedPlan = value;
                });
              },
              items: plansList?.map((Plans plan) {
                    return DropdownMenuItem<String>(
                      value: plan
                          .name, // Assuming 'name' exists in your Plans entity
                      child: Text(plan.name),
                    );
                  }).toList() ??
                  [],
            ),
            RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              direction: Axis.horizontal,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (ratingValue) {
                setState(() {
                  rating = ratingValue;
                });
              },
            ),
            TextField(
              maxLines: 5,
              maxLength: 500,
              onChanged: (value) {
                comment = value;
              },
              decoration: InputDecoration(
                labelText: 'Comment',
                hintText: 'Leave your comment here',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedPlan != null && rating != null) {
                  final plan =
                      plansList.firstWhere((p) => p.name == selectedPlan);
                  final newReview = Reviews(
                    rating: rating.toString(),
                    comment: comment,
                  );
                  newReview.plan.target = plan;
                  newReview.user.target = widget.currentUser; // Added this line
                  _reviewsBox.put(newReview);

                  Navigator.pop(context);
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewDetailPage extends StatefulWidget {
  final int reviewId;

  ReviewDetailPage({required this.reviewId});

  @override
  _ReviewDetailPageState createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  late final Future<Box<Reviews>> _reviewsBoxFuture;
  Reviews? review;

  @override
  void initState() {
    super.initState();
    // Initialize the Reviews box
    _reviewsBoxFuture = ObjectBox.getInstance().then((ObjectBox objectBox) {
      return objectBox.getReviewBox();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box<Reviews>>(
      future: _reviewsBoxFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final reviewsBox = snapshot.data!;
          review = reviewsBox.get(widget.reviewId);

          if (review == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Review Detail"),
              ),
              body: Center(child: Text("Review not found")),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text("Review Detail"),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rating: ${review!.rating}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Comment:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    review!.comment,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
