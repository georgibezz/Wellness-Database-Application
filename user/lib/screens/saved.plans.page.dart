import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:september_twenty_nine_user/screens/plan.page.dart';
import 'package:wikipedia/wikipedia.dart';
import '../utils/objectbox.store.dart';
import '../entities/plan.entity.dart';
import '../entities/user.entity.dart';
import 'dart:async';

class SavedPlansPage extends StatefulWidget {
  final User currentUser;  // Assumes User entity is passed from the previous screen

  SavedPlansPage({required this.currentUser});

  @override
  _SavedPlansPageState createState() => _SavedPlansPageState();
}

class _SavedPlansPageState extends State<SavedPlansPage> {
  late List<Plans> savedPlans;  // To hold the list of saved plans

  @override
  void initState() {
    super.initState();
    savedPlans = widget.currentUser.plan;
    // This assumes that widget.currentUser.savedPlans is a List<Plans>
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Saved Plans",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: savedPlans.length,
        itemBuilder: (context, index) {
          final plan = savedPlans[index];
          return ListTile(
            title: Text(
              plan.name,
              style: GoogleFonts.poppins(),
            ),
            subtitle: Text(
              plan.instructions,
              style: GoogleFonts.poppins(),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  widget.currentUser.plan.removeAt(index);
                  // You would typically also update this to your database here
                });
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => conditionPlanDetailPage(plan: plan),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
