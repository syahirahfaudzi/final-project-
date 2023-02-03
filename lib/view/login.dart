import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:homestay_raya/config.dart';
import 'package:homestay_raya/models/user.dart';
import 'package:homestay_raya/view/mainScreen.dart';
import 'package:homestay_raya/view/registrationScreen.dart';
import 'package:ndialog/ndialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passEditingController = TextEditingController();

  bool _passwordVisible = true;
  final _formKey = GlobalKey<FormState>();
  bool _isChecked = false;
  var screenHeight, screenWidth, cardWitdh;

  @override
  void initState() {
    super.initState();
    loadPref();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      cardWitdh = screenWidth;
    } else {
      cardWitdh = 400.00;
    }

    return Scaffold(
      appBar: AppBar(title: const Text("LOGIN SCREEN")),
      body: Center(
          child: SingleChildScrollView(
              child: SizedBox(
        width: cardWitdh,
        child: Column(
          children: [
            Card(
                elevation: 8,
                margin: const EdgeInsets.all(8),
                child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      child: Column(children: [
                        TextFormField(
                            controller: _emailEditingController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => val!.isEmpty ||
                                    !val.contains("@") ||
                                    !val.contains(".")
                                ? "enter a valid email"
                                : null,
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.email),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0),
                                ))),
                        TextFormField(
                            controller: _passEditingController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: _passwordVisible,
                            decoration: const InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(),
                                icon: Icon(Icons.password),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(width: 1.0),
                                ))),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Checkbox(
                                value: _isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isChecked = value!;
                                    saveremovepref(value);
                                  });
                                }),
                            Flexible(
                                child: GestureDetector(
                              onTap: null,
                              child: const Text('Remember Me',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  )),
                            )),
                            MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              minWidth: 116,
                              height: 60,
                              elevation: 10,
                              onPressed: _loginUser,
                              color: Theme.of(context).colorScheme.primary,
                              child: const Text('Login'),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                      ]),
                    ))),
            GestureDetector(
              onTap: _goLogin,
              child: const Text(
                "Dont't have an account. Register Now",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.deepOrange,
                    decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: _goHome,
              child: const Text("Continue as Guess ",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepOrange,
                      decoration: TextDecoration.underline)),
            )
          ],
        ),
      ))),
    );
  }

  void _loginUser() {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
          msg: "Please fill in the login credentials",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }

    String _email = _emailEditingController.text;
    String _password = _passEditingController.text;
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Please wait.."), title: const Text("Login user"));
    progressDialog.show();
    try {
      http.post(Uri.parse("${Config.server}/php/login_user.php"),
          body: {"email": _email, "password": _password}).then((response) {
        var jsonResponse = json.decode(response.body);
        if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
          User user = User.fromJson(jsonResponse['data']);
          Fluttertoast.showToast(
              msg: "Login Successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          progressDialog.dismiss();
          Navigator.push(context,
              MaterialPageRoute(builder: (content) => MainScreen(user: user)));
        } else {
          Fluttertoast.showToast(
              msg: "Login Failed, Try Again.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 14.0);
          progressDialog.dismiss();
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void _goLogin() {
    Navigator.push(
        context, MaterialPageRoute(builder: (content) => RegistrationScreen()));
    //Navigator.push(context,
    // MaterialPageRoute(builder: (content) => const RegistrationScreen()));
  }

  void _goHome() {
    User user = User(
        id: "0",
        email: "notregistered",
        phone: "notregistered",
        name: "notregistered",
        address: "na",
        regdate: "0");
    Navigator.push(context,
        MaterialPageRoute(builder: (content) => MainScreen(user: user)));
  }

  //Future<void> autoLogin() async {
  //SharedPreferences prefs = await SharedPreferences.getInstance();
  //String _email = (prefs.getString('email')) ?? '';
  //String _pass = (prefs.getString)('pass') ?? '';

  //if (_email.isNotEmpty) {
  //http.post(Uri.parse("${Config.server}/php/login_user.php"),
  //  body: {"email": _email, "password": _pass}).then((response) async {
  // print(response.body);
  //var jsonResponse = json.decode(response.body);
  // if (response.statusCode == 200 && jsonResponse['status'] == "success") {
  // User user = User.fromJson(jsonResponse['data']);
  //Timer(
  //  const Duration(seconds: 3),
  //() => Navigator.pushReplacement(
  //  context,
  //MaterialPageRoute(
  //   builder: (content) => MainScreen(user: user))));
  //} else {
  //User user = User(
  //  id: "0",
  //email: "notregistered",
  //phone: "notregistered",
  //name: "notregistered",
  //address: "na",
  //regdate: "0");
  //Timer(
  //  const Duration(seconds: 3),
  //() => Navigator.pushReplacement(
  //  context,
  //MaterialPageRoute(
  //  builder: (content) => MainScreen(user: user))));
  // }
  // });
  // } else {
  // User user = User(
  //   id: "0",
  // email: "notregistered",
  // phone: "notregistered",
  // name: "notregistered",
  // address: "na",
  // regdate: "0");
  // Timer(
  //   const Duration(seconds: 3),
  // () => Navigator.pushReplacement(context,
  //   MaterialPageRoute(builder: (content) => MainScreen(user: user))));
  // }
  //}

  void saveremovepref(bool value) async {
    String email = _emailEditingController.text;
    String password = _passEditingController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      if (!_formKey.currentState!.validate()) {
        Fluttertoast.showToast(
            msg: "Please fill in the login credentials",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        _isChecked = false;
        return;
      }
      await prefs.setString('email', email);
      await prefs.setString('pass', password);
      Fluttertoast.showToast(
          msg: "Preference Stored",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    } else {
      await prefs.setString('email', '');
      await prefs.setString('pass', '');
      setState(() {
        _emailEditingController.text = '';
        _passEditingController.text = '';
        _isChecked = false;
      });
      Fluttertoast.showToast(
          msg: "Preference Removed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    }
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email')) ?? '';
    String password = (prefs.getString('pass')) ?? '';
    if (email.isNotEmpty) {
      setState(() {
        _emailEditingController.text = email;
        _passEditingController.text = password;
        _isChecked = true;
      });
    }
  }
}
