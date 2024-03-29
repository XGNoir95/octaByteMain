import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../auth_screens/auth_page.dart';
import '../dasboard_screens/marketplace/buy/purchasehistory.dart';
import '../dasboard_screens/pc_builder/pages/build_history.dart';
import '../navigation_menu.dart';

import '../reusable_widgets/custom_scaffold.dart';
import '../reusable_widgets/custom_scaffold2.dart';
import '../reusable_widgets/custom_scaffold3.dart';
import 'notification/notificationService.dart';
import 'notification/settings_screen.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isUpdating = false;

  late final LocalNotificationService service;

  @override
  void initState() {
    service = LocalNotificationService();
    service.initialize();
    listenToNotification();
    super.initState();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails(String email) {
    return FirebaseFirestore.instance.collection('users').doc(email).get();
  }

  void _signOut(BuildContext context) async {
    await _auth.signOut();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Signed Out Successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Get.offAllNamed(AuthPage as String);
  }

  Future<File?> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    return image != null ? File(image.path) : null;
  }

  Future<String> _uploadImage(File image, String path) async {
    final ref = FirebaseStorage.instance.ref(path);
    await ref.putFile(image);

    return await ref.getDownloadURL();
  }

  void _editUser(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _firstNameController =
        TextEditingController(text: userData['First Name']);
        final TextEditingController _lastNameController =
        TextEditingController(text: userData['Last Name']);
        final TextEditingController _userNameController =
        TextEditingController(text: userData['User Name']);

        File? _pickedImage;

        return AlertDialog(
          title: Center(
            child: Text(
              'Edit User',
              style: TextStyle(fontFamily: 'RobotoCondensed', fontSize: 30),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 31,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 31,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    labelText: 'User Name',
                    labelStyle: TextStyle(
                      fontFamily: 'RobotoCondensed',
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                _pickedImage = await _pickImage();
              },
              child: Text('Pick Image'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _isUpdating = true;
                });

                User? currentUser = _auth.currentUser;

                String? imageUrl;
                if (_pickedImage != null) {
                  imageUrl = await _uploadImage(
                      _pickedImage!, 'user_images/${currentUser!.uid}');
                }

                await updateUserData(
                  currentUser!.email!,
                  _firstNameController.text,
                  _lastNameController.text,
                  _userNameController.text,
                  imageUrl,
                );

                setState(() {
                  _isUpdating = false;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'User data updated successfully!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'RobotoCondensed',
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUserData(
      String email,
      String firstName,
      String lastName,
      String userName,
      String? imageUrl,
      ) async {
    try {
      Map<String, dynamic> userData = {
        'First Name': firstName,
        'Last Name': lastName,
        'User Name': userName,
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        userData['Image URL'] = imageUrl;
      }

      await FirebaseFirestore.instance.collection('users').doc(email).update(userData);
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white, size: 32),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          SizedBox(width: 10),
        ],
        centerTitle: true,
      ),
      endDrawer: Drawer(
        child: Container(
          color: Colors.grey[900],
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                ),
                child: Center(
                  child: Text(
                    'Octabyte',
                    style: GoogleFonts.bebasNeue(fontSize: 42, color: Colors.white),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings_outlined, color: Colors.amber, size: 32),
                title: Text('Edit User details', style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 25)),
                onTap: () async {
                  User? currentUser = _auth.currentUser;
                  DocumentSnapshot<Map<String, dynamic>> snapshot = await getUserDetails(currentUser!.email!);
                  Map<String, dynamic> userData = snapshot.data()!;
                  _editUser(context, userData);
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart, color: Colors.amber, size: 32),
                title: Text('Purchase History', style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 25)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PurchaseHistoryPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.build, color: Colors.amber, size: 32),
                title: Text('Past Builds', style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 25)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PastBuildsPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.amber, size: 32),
                title: Text('Notifications', style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 25)),
                onTap: () async {
                  await service.showNotificationWithPayload(
                    id: 0,
                    title: 'Welcome',
                    body: 'Lets build PC.',
                    payload: 'Hey Explore the latest and new products. ',
                  );
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 50,),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.amber, size: 32),
                title: Text('Log Out', style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 25)),
                onTap: () {
                  _signOut(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bg.jpg',
            fit: BoxFit.cover,
            width: 411.4,
            height: 770.3,
            alignment: Alignment.center,
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<User?>(
                    stream: _auth.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(color: Colors.amber),
                        );
                      }

                      if (snapshot.hasData && snapshot.data != null) {
                        User? currentUser = snapshot.data;

                        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: getUserDetails(currentUser!.email!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(color: Colors.amber),
                              );
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else if (snapshot.hasData && snapshot.data!.exists) {
                              Map<String, dynamic>? user = snapshot.data!.data();

                              return SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [],
                                    ),
                                    SizedBox(
                                      height: 0,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                          color: Colors.grey[700]!,
                                          width: 2.0,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(25),
                                      child: Stack(
                                        children: [
                                          if (user!['Image URL'] != null && user['Image URL'].isNotEmpty)
                                            CircleAvatar(
                                              radius: 50,
                                              backgroundImage: NetworkImage(user['Image URL']),
                                            )
                                          else
                                            const Icon(Icons.person, size: 80, color: Colors.white),
                                          Container(
                                            child: Positioned(
                                              bottom: 0,
                                              left: 0,
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey[800],
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.edit, color: Colors.amber, size: 15),
                                                  onPressed: () async {
                                                    User? currentUser = _auth.currentUser;
                                                    DocumentSnapshot<Map<String, dynamic>> snapshot =
                                                    await getUserDetails(currentUser!.email!);
                                                    Map<String, dynamic> userData = snapshot.data()!;
                                                    _editUser(context, userData);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      user['User Name'],
                                      style: GoogleFonts.bebasNeue(
                                        fontSize: 53,
                                        color: Colors.amber,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    Text(currentUser.email!,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'RobotoCondensed',
                                            fontSize: 20)),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                ' User Information:',
                                                style: GoogleFonts.bebasNeue(
                                                  color: Colors.amber,
                                                  fontSize: 46,
                                                ),
                                                textAlign: TextAlign.left,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 56,
                                                  margin: EdgeInsets.symmetric(vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[800],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width: 10),
                                                      Icon(Icons.first_page, color: Colors.white),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        'First Name: ',
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.amber,
                                                          fontFamily: 'RobotoCondensed',
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Text(
                                                        user['First Name'],
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.white,
                                                          fontFamily: 'RobotoCondensed',
                                                        ),
                                                      ),
                                                      SizedBox(width: 10,),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  height: 56,
                                                  margin: EdgeInsets.symmetric(vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[800],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width: 10),
                                                      Icon(Icons.info_outline, color: Colors.white),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        'Last Name: ',
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.amber,
                                                          fontFamily: 'RobotoCondensed',
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Text(
                                                        user['Last Name'],
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.white,
                                                          fontFamily: 'RobotoCondensed',
                                                        ),
                                                      ),
                                                      SizedBox(width: 10,),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  height: 56,
                                                  margin: EdgeInsets.symmetric(vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[800],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width: 10),
                                                      Icon(Icons.android_outlined, color: Colors.white),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        'User Name: ',
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.amber,
                                                          fontFamily: 'RobotoCondensed',
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Text(
                                                        user['User Name'],
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.white,
                                                          fontFamily: 'RobotoCondensed',
                                                        ),
                                                      ),
                                                      SizedBox(width: 10,),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  height: 56,
                                                  margin: EdgeInsets.symmetric(vertical: 5),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[800],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width: 10),
                                                      Icon(Icons.email_outlined, color: Colors.white),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        'Email:',
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.amber,
                                                          fontFamily: 'RobotoCondensed',
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Text(
                                                        user['Email'],
                                                        style: TextStyle(
                                                          fontSize: 24,
                                                          color: Colors.white,
                                                          fontFamily: 'RobotoCondensed',
                                                        ),
                                                      ),
                                                      SizedBox(width: 10,),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Text("No data");
                            }
                          },
                        );
                      } else {
                        return Text("User not signed in");
                      }
                    },
                  ),
                  SizedBox(height: 15),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onNotificationListener(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      print('payload $payload');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsScreen(payload: payload)),
      );
    }
  }

  void listenToNotification() => service.onNotificationClick.stream.listen(onNotificationListener);
}
