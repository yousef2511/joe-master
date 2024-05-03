import 'package:flutter/material.dart';
import 'package:joe/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isPassengerChecked = false;
  bool isStaffChecked = false;
  String userId = '';

  Future<void> saveIDToDatabase(String userType, String id) async {
    final database = FirebaseDatabase.instance;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    DatabaseReference collectionRef = database.reference().child('ID');

    if (userType == 'Passenger') {
      collectionRef = collectionRef.child('passengers');
      prefs.setBool("stuff", false);
    } else if (userType == 'Staff') {
      collectionRef = collectionRef.child('staff');
      prefs.setBool("stuff", true);
    }

    collectionRef.child(id).set({'id': id}).then((value){
      // Successfully saved the ID to the collection
      print('User ID saved: $id');

      // Obtain shared preferences.
      prefs.setString("uid", id);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }).catchError((error) {
      // Handle error saving the ID
      print('Error saving user ID: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/pp2.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      userId = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter Your ID',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Passenger'),
                        Checkbox(
                          value: isPassengerChecked,
                          onChanged: (value) {
                            setState(() {
                              isPassengerChecked = value!;
                              if (isPassengerChecked) {
                                isStaffChecked = false;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Staff'),
                        Checkbox(
                          value: isStaffChecked,
                          onChanged: (value) {
                            setState(() {
                              isStaffChecked = value!;
                              if (isStaffChecked) {
                                isPassengerChecked = false;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (isPassengerChecked || isStaffChecked) {
                    if (userId.isNotEmpty) {
                      String userType = isPassengerChecked ? 'Passenger' : 'Staff';
                      saveIDToDatabase(userType, userId);
                    } else {
                      showErrorMessage('Please Enter Your ID');
                    }
                  } else {
                    showErrorMessage('Please Choose Passenger or Staff');
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}