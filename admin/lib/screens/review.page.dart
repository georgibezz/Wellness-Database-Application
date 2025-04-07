import 'package:flutter/material.dart';
import '../entities/review.entity.dart';
import '../main.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _searchController = TextEditingController();
  int currentPage = 0;
  final int reviewsPerPage = 10;
  int totalReviews = 0;

  void _deleteReview(int id) {
    objectbox.removeReview(id);
  }

  void _viewReview(Reviews review) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(review.comment),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('User: ${review.user.target?.name ?? 'Unknown'}'), // Show the category
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Page'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  // Trigger rebuild for updated search
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Reviews>>(
              stream: objectbox.getReviews(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var reviews = snapshot.data!;
                  //totalItems = items.length;
                  // Case-insensitive search
                  if (_searchController.text.isNotEmpty) {
                    reviews = reviews.where((review) =>
                        review.comment.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
                  }
                  // Case-insensitive sort
                  reviews.sort((a, b) => a.comment.toLowerCase().compareTo(b.comment.toLowerCase()));

                  // Pagination
                  final totalReviews = reviews.length;
                  final start = currentPage * reviewsPerPage;
                  final end = start + reviewsPerPage > totalReviews ? totalReviews : start + reviewsPerPage;
                  final currentReviews = reviews.sublist(start, end);

                  return ListView.builder(
                    itemCount: currentReviews.length,
                    itemBuilder: (context, index) {
                      final review = currentReviews[index];
                      return Container(
                        height: 100.0, // Fixed height for the container
                        child: ListTile(
                          title: Text(review.comment),
                          trailing: Wrap(
                            spacing: 12, // space between two icons
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.visibility),
                                onPressed: () => _viewReview(review),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteReview(review.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  if (currentPage > 0) {
                    setState(() {
                      currentPage--;
                    });
                  }
                },
                child: Text('<'),
              ),
              StreamBuilder<List<Reviews>>(
                stream: objectbox.getReviews(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final totalUsers = snapshot.data!.length;
                    return Text(
                        'Viewing ${currentPage * reviewsPerPage + 1} - ${(currentPage + 1) * reviewsPerPage} of $totalUsers');
                  }
                  return Text('Loading...');
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    currentPage++; // Increment the current page
                  });
                },
                child: Text('>'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}