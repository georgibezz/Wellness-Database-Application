import 'dart:async';
import 'package:flutter/material.dart';
import 'package:september_twenty_nine_user/screens/symptom.page.dart';
import 'screens/category.page.dart';
import 'screens/condition.page.dart';
import 'screens/home.page.dart';
import 'screens/item.page.dart';
import 'screens/plan.page.dart';
import 'screens/interaction.page.dart';
import 'screens/review.page.dart';
import 'screens/user.page.dart';
import 'utils/objectbox.store.dart';

late ObjectBox objectbox;

Future<void> main() async {
  // This is required so ObjectBox can get the application directory
  // to store the database in.
  WidgetsFlutterBinding.ensureInitialized();
  objectbox = await ObjectBox.create();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      routes: {
        '/CategoryScreen': (context) => CategoryPage(),
        '/ItemScreen':(context)=> ItemPage(),
        '/SymptomScreen':(context)=> SymptomPage(),
        '/ConditionScreen': (context)=> ConditionPage(),
        '/PlanScreen':(context)=> PlanPage(),
        '/InteractionScreen': (context)=> InteractionsPage(),
        '/UserScreen': (context)=> UserPage(),
        '/ReviewsScreen' : (context) => ReviewPage(),
      //  '/CalculatorScreen': (context) => CalculatorPage(),
        //'/DeleteConditionScreen': (context)=> DeleteConditionPage(selectedConditions: selectedConditions),
      },
    );
  }
}
