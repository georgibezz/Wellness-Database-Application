import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //setting the expansion function for the navigation rail

  @override
  Widget build(BuildContext context) {

    return AdminScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Wellness Database Admin'),
        backgroundColor: Colors.orange,
      ),
      sideBar: SideBar(
        items: const [
          AdminMenuItem(
            title: 'Manage Content',
            icon: Icons.file_copy,
            children: [
                AdminMenuItem(
                  title: 'Categories',
                  route: '/CategoryScreen',
                ),
                AdminMenuItem(
                  title: 'Items',
                  route: '/ItemScreen',
                ),
                AdminMenuItem(
                  title: 'Interactions',
                  route: '/InteractionScreen',
                ),

                  AdminMenuItem(
                    title: 'Conditions',
                    route: '/ConditionScreen',
                  ),
                  AdminMenuItem(
                    title: 'Symptoms',
                    route: '/SymptomScreen',
                  ),

              AdminMenuItem(
                title: 'Remedy Plans',
                route: '/PlanScreen',
              ),

            ],
          ),
          AdminMenuItem(
            title: 'Manage User',
            icon: Icons.person,
            children: [
            AdminMenuItem(
            title: 'User Profiles',
              route: '/UserScreen',
          ),
            AdminMenuItem(
            title: 'Reviews',
            route: '/ReviewsScreen',
          ),
        ]
          ),

        ],
        selectedRoute: '/',
        onSelected: (item) {
          if (item.route != null) {
            Navigator.of(context).pushNamed(item.route!);
          }
        },
        header: Container(
          height: 80,
          width: double.infinity,
          color: const Color(0xFF00695C),
          child: const Center(
            child: Text(
              'DASHBOARD',
              style: TextStyle(
                color: Colors.white,

              ),
            ),
          ),
        ),
        footer: Container(
          height: 50,
          width: double.infinity,
          color: const Color(0xFF00695C),
          child: const Center(
            child: Text(
              '',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
        body: Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png', // Replace with your actual logo asset path
                      width: 100, // Adjust width as needed
                      height: 100, // Adjust height as needed
                    ),
                    SizedBox(height: 20), // Add some spacing between logo and text
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 30,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded( // Using Expanded to fill the remaining space
                child: Center( // Wrapping the bottom image in a Center widget
                  child: Image.asset(
                    'assets/images/welcome.png',
                    width: 900, // Adjust width as needed
                    height: 900, // Adjust height as needed
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}