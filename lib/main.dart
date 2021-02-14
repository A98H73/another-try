import 'package:flutter/material.dart';
//import 'LoginPage.dart';
//import 'ImageUploadPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/authentication_service.dart';
import 'MapGoogle.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
        ),
      ],
      child: new MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({
    Key key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      //return Testing();
    }
    print("DATE MANUPULATION");
    final curr = DateTime.now();
    final prev = DateTime.now().subtract(Duration(
      days: 2,
    ));
    //final prev = DateTime(curr.year, curr.month, curr.day);
    print(curr);
    print(prev);
    final difference = curr.difference(prev).inHours;
    print(difference);
    // final birthday = DateTime(2020, 12, 12);
    // final date2 = DateTime.now();
    // final difference = date2.difference(birthday).inDays;
    //print(difference);
    print("TESTING PAGE");
    return LoginPage();
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Colors.green[800],
            Colors.green[500],
            Colors.green[300]
          ]),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 80,
            ),
            header(),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  )),
              child: InputWrapper(),
            ))
          ],
        ),
      ),
    );
  }
}

class InputWrapper extends StatelessWidget {
  String _email, _pass;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.grey[200]))),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Enter your Email",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none),
                    controller: emailController,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.grey[200]))),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: "Enter your Password",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none),
                    controller: passwordController,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Text(
            "Forget Password",
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(
            height: 40,
          ),
          Material(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: BorderRadius.circular(30.0),
              ),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              child: RaisedButton(
                onPressed: () {
                  print("CHECKER DATE TIME");
                  var addDt = DateTime.now();
                  print(addDt.add(Duration(
                      days: 2,
                      hours: 0,
                      minutes: 0))); //2020–04–07 21:02:09.367
                  Future<String> str =
                      context.read<AuthenticationService>().signIn(
                            email: emailController.text,
                            pass: passwordController.text,
                          );
                  print("INSIDE RAISE BUTTON");
                  print(str);
                  // Navigator.of(context).pushReplacement(
                  //     MaterialPageRoute(builder: (context) => Testing()));
                },
                child: Text("Login",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              "Kisan Ki Baat",
              style: TextStyle(color: Colors.white, fontSize: 40),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              "LOGIN PAGE",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          )
        ],
      ),
    );
  }
}
