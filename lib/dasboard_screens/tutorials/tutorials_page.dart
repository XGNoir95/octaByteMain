import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tutorials_screen.dart';  // Import the tutorials screen file

class TutorialsPage extends StatelessWidget {
  const TutorialsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: Text(
          'OCTAHUB',
          style: GoogleFonts.bebasNeue(
            color: Colors.amber,
            fontSize: 40,
            letterSpacing: 6,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.fill,  // Use BoxFit.fill to cover the entire screen
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TutorialsScreen()),  // Navigate to the tutorials screen on tap
            );
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 45),  // Add padding to the top of the image
                  child: Image.asset('assets/images/DIY.jpg', width: 200, height: 200),
                ),
                SizedBox(height: 3),  // Adjust the gap between the image and text
                Text(
                  'DIY PC Build Guide',
                  style: TextStyle(fontSize: 18, color: Colors.amberAccent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}