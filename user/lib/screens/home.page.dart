import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:september_twenty_nine_user/screens/condition.page.dart';
import 'package:september_twenty_nine_user/screens/symptom.page.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Database'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 27.0),
            CarouselSlider(
              items: [
                _buildRoundedImage('assets/images/slide1.jpg'),
                _buildRoundedImage('assets/images/slide2.jpg'),
                _buildRoundedImage('assets/images/slide3.jpg'),
                _buildRoundedImage('assets/images/slide4.jpg'),
                _buildRoundedImage('assets/images/slide5.jpg'),
                _buildRoundedImage('assets/images/slide6.jpg'),
                _buildRoundedImage('assets/images/slide7.jpg'),
              ],
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: 16 / 9,
                enlargeCenterPage: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              'Explore Symptoms',
              style: GoogleFonts.poppins(
                fontSize: 15.0,
              ),
            ),
            _buildIllnessLink(context),
            SizedBox(height: 27.0),

            Text(
              'Explore Conditions',
              style: GoogleFonts.poppins(
                fontSize: 15.0,
              ),
            ),
            _buildConditionsLink(context),
            SizedBox(height: 27.0),

            Text(
              'Explore Remedies',
              style: GoogleFonts.poppins(
                fontSize: 15.0,
              ),
            ),
            SizedBox(height: 16.0),
            _buildImageGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedImage(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250.0,
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8.0,
      mainAxisSpacing: 8.0,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildImageLink('assets/images/link1.png', '', () {}),
        _buildImageLink('assets/images/link2.png', '', () {}),
        _buildImageLink('assets/images/link3.png', '', () {}),
        _buildImageLink('assets/images/link4.png', '', () {}),
      ],
    );
  }

  Widget _buildImageLink(String imagePath, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: 160.0,
              height: 160.0,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllnessLink(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0), // Adjust the margin as needed
      child: GestureDetector(
        onTap: () {
          // Add navigation logic to the desired page when "illness.png" is tapped.
          // You can use Navigator to navigate to the appropriate page.
          Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => SymptomList(), // Replace with the actual page you want to navigate to
          ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset(
            'assets/images/illness.png', // Replace with the actual path to "illness.png"
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200.0, // Adjust the height as needed
          ),
        ),
      ),
    );
  }


  Widget _buildConditionsLink(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0), // Adjust the margin as needed
      child: GestureDetector(
        onTap: () {
           Navigator.push(
           context,
          MaterialPageRoute(
            builder: (context) => ConditionList(), // Replace with the actual page you want to navigate to
          ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset(
            'assets/images/ribbons.png', // Replace with the actual path to "illness.png"
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200.0, // Adjust the height as needed
          ),
        ),
      ),
    );
  }

}