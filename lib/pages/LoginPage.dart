import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_browser.dart' as auth;
import 'package:googleapis_auth/auth_io.dart';
import 'package:sign_plus/components/calendar_client.dart';
import 'package:sign_plus/main.dart';
import 'package:sign_plus/pages/CallAnswerPage.dart';
import 'package:sign_plus/pages/calendar/create_screen.dart';
import 'package:sign_plus/utils/secrets.dart';
import 'package:sign_plus/utils/style.dart';
import 'package:googleapis/calendar/v3.dart' as cal;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// firebase auth instance
  FirebaseAuth _auth = FirebaseAuth.instance;

  /// boolean parameters
  bool _deafCheck = false;
  bool _translatorCheck = false;
  bool _validate = true;

  /// textEditing Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // a function who provides a connection to google user
  /**
   * A function to handle GoogleSignIn
   * @params _auth :  FireBaseAuth _auth -  authentication to firebase Instance
   * this method does *double authentication*
   *
   * */
  void googleSignIn(FirebaseAuth _auth) async {
    // Trigger the authentication flow
    /// _clientID - the client of the app from google cloud platform
    var _clientID = new ClientId(Secret.getId(), "ku6x0zAKIbXvU7X_Kx9nY8_T");

    /// _scopes - persmissions for using the user's Calendar
    const _scopes = const [cal.CalendarApi.CalendarScope];

    ///  auth.createImplicitBrowswerFlow - a method that creates a login flow via browser
    ///  the method return a browser auth connection.
    ///  we use then function to use the flow we got from method above
    ///  flow.clientViaUserConsest - a authentication method that returns an AuthClient, to use for Calendar API
    await auth
        .createImplicitBrowserFlow(_clientID, _scopes)
        .then((auth.BrowserOAuth2Flow flow) {
      flow.clientViaUserConsent().then((auth.AuthClient client) async {
        CalendarClient.calendar = cal.CalendarApi(client);

        String adminPanelCalendarId = 'primary';

        var event = CalendarClient.calendar.events;

        var events = event.list(adminPanelCalendarId);

        events.then((showEvents) {
          showEvents.items.forEach((cal.Event ev) {
            print(ev.summary);
          });
        });

        /// second sign in for connecting to firebase,
        final GoogleSignInAccount googleUser = await GoogleSignIn(
                scopes: ['https://www.googleapis.com/auth/userinfo.email'])
            .signInSilently();
        // await GoogleSignIn(
        //         scopes: ['https://www.googleapis.com/auth/userinfo.email'])
        //     .signIn();
        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        //
        // // Create a new credential
        final GoogleAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        final User user = userCredential.user;
        if (user != null) {
          print(user.email);

          String userKind = _deafCheck
              ? 'deaf'
              : _translatorCheck
                  ? 'translator'
                  : '';

          if (userKind == 'deaf') {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => CreateScreen()));
          }
        }
      });
    });

    // Obtain the auth details from the request
    // final GoogleSignInAuthentication googleAuth =
    //     await googleUser.authentication;
    //
    // // Create a new credential
    // final GoogleAuthCredential credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth.accessToken,
    //   idToken: googleAuth.idToken,
    // );

    // Once signed in, return the UserCredential
  }

  @override
  void initState() {
    FirebaseAnalytics fa = FirebaseAnalytics();
    fa.setAnalyticsCollectionEnabled(true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Todo: move all widgets to UI folder and create them methodically
    return Scaffold(
      appBar: buildNavBar(context, ''),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: Colors.grey, blurRadius: 24, spreadRadius: 24)
            ],
            color: Color(0xffFAFAFA).withOpacity(0.9),
          ),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Center(
                    child: Container(
                      margin: kIsWeb
                          ? EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width / 4,
                              16,
                              MediaQuery.of(context).size.width / 4,
                              0)
                          : EdgeInsets.fromLTRB(20, 16, 15, 0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Color(0xffFFFFFF)),
                      child: CheckboxListTile(
                        title: Text(
                          'אני כבד/ת שמיעה ',
                          textAlign: TextAlign.center,
                        ),
                        secondary: Image.asset(
                          'images/Ear Icon.png',
                          height: 35,
                        ),
                        subtitle: !_validate
                            ? Text(
                                'אנא סמנ/י',
                                style: homePageText(
                                    12, Colors.red, FontWeight.normal),
                              )
                            : null,
                        activeColor: Colors.blue,
                        value: _deafCheck,
                        onChanged: (value) {
                          setState(() {
                            _translatorCheck = !value;
                            _deafCheck = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    margin: kIsWeb
                        ? EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width / 4,
                            16,
                            MediaQuery.of(context).size.width / 4,
                            0)
                        : EdgeInsets.fromLTRB(20, 8, 15, 0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Color(0xffFFFFFF)),
                    child: CheckboxListTile(
                      title: Text(
                        'אני מתורגמנ/ית ',
                        textAlign: TextAlign.center,
                      ),
                      secondary: Image.asset(
                        'images/Translator Icon.png',
                        height: 35,
                      ),
                      subtitle: !_validate
                          ? Text(
                              'אנא סמנ/י',
                              style: homePageText(
                                  12, Colors.red, FontWeight.normal),
                            )
                          : null,
                      activeColor: Colors.blue,
                      value: _translatorCheck,
                      onChanged: (value) {
                        setState(() {
                          _deafCheck = !value;
                          _translatorCheck = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (!_deafCheck && !_translatorCheck) {
                          _validate = false;
                        } else {
                          googleSignIn(_auth);
                        }
                      });
                    },
                    child: Container(
                      margin: kIsWeb
                          ? EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width / 4,
                              16,
                              MediaQuery.of(context).size.width / 4,
                              0)
                          : EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Color(0xff004E98)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'images/googleLogo.png',
                            height: 40,
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 32, 0),
                            child: Text(
                              'התחבר באמצעות גוגל',
                              textAlign:
                                  kIsWeb ? TextAlign.start : TextAlign.end,
                              style: homePageText(
                                  14,
                                  Color(0xffFFFFFF).withOpacity(0.9),
                                  FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 45,
                    margin: kIsWeb
                        ? EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width / 4,
                            16,
                            MediaQuery.of(context).size.width / 4,
                            0)
                        : EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                    child: TextFormField(
                      controller: emailController,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                          fillColor: Color(0xffFFFFFF),
                          suffixIcon: Icon(Icons.email),
                          filled: true,
                          hintText: 'הזנ/י מייל כאן ',
                          hintStyle: TextStyle(fontSize: 14),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                    ),
                  ),
                  Container(
                    height: 45,
                    margin: kIsWeb
                        ? EdgeInsets.fromLTRB(
                            MediaQuery.of(context).size.width / 4,
                            16,
                            MediaQuery.of(context).size.width / 4,
                            0)
                        : EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                    child: TextField(
                      controller: emailController,
                      textAlign: TextAlign.end,
                      decoration: InputDecoration(
                          fillColor: Color(0xffFFFFFF),
                          suffixIcon: Icon(Icons.remove_red_eye),
                          hintText: 'הזנ/י סיסמא כאן ',
                          hintStyle: TextStyle(fontSize: 14),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          )),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4 + 15,
                      ),
                      Text(
                        'שכחתי סיסמא',
                        // textAlign: TextAlign.end,
                        style: homePageText(
                            12, Colors.lightBlue, FontWeight.normal),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      print('inkwell');
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      margin: kIsWeb
                          ? EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width / 4,
                              16,
                              MediaQuery.of(context).size.width / 4,
                              0)
                          : EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.blue),
                      child: Text(
                        'להתחברות',
                        style: homePageText(18, Colors.white, FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
