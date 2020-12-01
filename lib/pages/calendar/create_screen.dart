import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:intl/intl.dart';
import 'package:sign_plus/components/calendar_client.dart';
import 'package:sign_plus/components/event_info.dart';
import 'package:sign_plus/pages/calendar/dashboard_screen.dart';
import 'package:sign_plus/resources/color.dart';
import 'package:sign_plus/storage.dart';
import 'package:sign_plus/utils/style.dart';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  Storage storage = Storage();
  CalendarClient calendarClient = CalendarClient();

  TextEditingController textControllerDate;
  TextEditingController textControllerStartTime;
  TextEditingController textControllerEndTime;
  TextEditingController textControllerTitle;
  TextEditingController textControllerDesc;
  TextEditingController textControllerLocation;
  TextEditingController textControllerAttendee;

  FocusNode textFocusNodeTitle;
  FocusNode textFocusNodeDesc;
  FocusNode textFocusNodeLocation;
  FocusNode textFocusNodeAttendee;

  DateTime selectedDate = DateTime.now();
  DateTime selectedStartTime = DateTime.now();
  DateTime selectedEndTime = DateTime.now();

  final NOW = DateTime.now();

  String currentTitle;
  String currentDesc;
  String currentLocation;
  String currentEmail;
  String errorString = '';
  // List<String> attendeeEmails = [];
  List<calendar.EventAttendee> attendeeEmails = [];

  bool isEditingDate = false;
  bool isEditingStartTime = false;
  bool isEditingEndTime = false;
  bool isEditingBatch = false;
  bool isEditingTitle = false;
  // bool isEditingEmail = false;
  // bool isEditingLink = false;
  bool isErrorTime = false;
  // bool shouldNofityAttendees = false;
  // bool hasConferenceSupport = false;

  bool isDataStorageInProgress = false;

  _selectDate(BuildContext context) async {
    final DateTime picked = await DatePicker.showDatePicker(context,
        locale: LocaleType.heb,
        minTime: DateTime(2020),
        maxTime: DateTime(2050),
        currentTime: DateTime.now());

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        textControllerDate.text = DateFormat.yMMMMd().format(selectedDate);
      });
    }
  }

  _selectStartTime(BuildContext context) async {
    final picked =
        await DatePicker.showTimePicker(context, currentTime: DateTime.now());

    if (picked != null && picked != selectedStartTime) {
      setState(() {
        selectedStartTime = picked;
        textControllerStartTime.text = selectedStartTime.toString();
      });
    } else {
      setState(() {
        textControllerStartTime.text = selectedStartTime.toString();
      });
    }
  }

  _selectEndTime(BuildContext context) async {
    final picked = await DatePicker.showTimePicker(
      context,
      currentTime: NOW,
    );
    if (picked != null && picked != selectedEndTime) {
      setState(() {
        selectedEndTime = picked;
        textControllerEndTime.text = selectedEndTime.toString();
      });
    } else {
      setState(() {
        textControllerEndTime.text = selectedEndTime.toString();
      });
    }
  }

  String _validateTitle(String value) {
    if (value != null) {
      value = value?.trim();
      if (value.isEmpty) {
        return 'Title can\'t be empty';
      }
    } else {
      return 'Title can\'t be empty';
    }

    return null;
  }

  String _validateEmail(String value) {
    if (value != null) {
      value = value.trim();

      if (value.isEmpty) {
        return 'Can\'t add an empty email';
      } else {
        final regex = RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
        final matches = regex.allMatches(value);
        for (Match match in matches) {
          if (match.start == 0 && match.end == value.length) {
            return null;
          }
        }
      }
    } else {
      return 'Can\'t add an empty email';
    }

    return 'Invalid email';
  }

  @override
  void initState() {
    textControllerDate = TextEditingController();
    textControllerStartTime = TextEditingController();
    textControllerEndTime = TextEditingController();
    textControllerTitle = TextEditingController();
    textControllerDesc = TextEditingController();
    textControllerLocation = TextEditingController();
    textControllerAttendee = TextEditingController();

    textFocusNodeTitle = FocusNode();
    textFocusNodeDesc = FocusNode();
    textFocusNodeLocation = FocusNode();
    textFocusNodeAttendee = FocusNode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildNavBar(context, 'קביעת שיחה עם מתורגמן'),
      // AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   iconTheme: IconThemeData(
      //     color: Colors.grey, //change your color here
      //   ),
      //   title: Text(
      //     'קביעת שיחה עם מתורגמן',
      //     style: TextStyle(
      //       color: CustomColor.dark_blue,
      //       fontSize: 22,
      //     ),
      //   ),
      // ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'הזינו את הפרטים כאן ומתורגמן זמין יפגש איתכם',
                      style: TextStyle(
                        color: Colors.black87,
                        // fontFamily: 'Raleway',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        // letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Text(
                    //   'You will have access to modify or remove the event afterwards.',
                    //   style: TextStyle(
                    //     color: Colors.grey,
                    //     fontFamily: 'Raleway',
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //     letterSpacing: 0.5,
                    //   ),
                    // ),
                    SizedBox(height: 16.0),
                    RichText(
                      text: TextSpan(
                        text: 'בחר/י תאריך',
                        style: TextStyle(
                          color: CustomColor.dark_cyan,
                          fontFamily: 'Raleway',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: kIsWeb
                          ? EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width / 3)
                          : EdgeInsets.only(left: 10),
                      child: TextFormField(
                        textAlign: TextAlign.end,
                        cursorColor: CustomColor.sea_blue,
                        controller: textControllerDate,
                        textCapitalization: TextCapitalization.characters,
                        onTap: () => _selectDate(context),
                        readOnly: true,
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        decoration: new InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.dark_blue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: EdgeInsets.only(
                            left: 16,
                            bottom: 16,
                            top: 16,
                            right: 16,
                          ),
                          hintText: 'דוג: 19 ספטמבר 2020',
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          errorText:
                              isEditingDate && textControllerDate.text != null
                                  ? textControllerDate.text.isNotEmpty
                                      ? null
                                      : 'אנא הזנ/י תאריך'
                                  : null,
                          errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        text: 'שעת התחלה',
                        style: TextStyle(
                          color: CustomColor.dark_cyan,
                          fontFamily: 'Raleway',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: kIsWeb
                          ? EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width / 3)
                          : EdgeInsets.only(left: 10),
                      child: TextFormField(
                        textAlign: TextAlign.end,
                        cursorColor: CustomColor.sea_blue,
                        controller: textControllerStartTime,
                        onTap: () => _selectStartTime(context),
                        readOnly: true,
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        decoration: new InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.dark_blue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: EdgeInsets.only(
                            left: 16,
                            bottom: 16,
                            top: 16,
                            right: 16,
                          ),
                          hintText: 'דוגמא: 17:30',
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          errorText: isEditingStartTime &&
                                  textControllerStartTime.text != null
                              ? textControllerStartTime.text.isNotEmpty
                                  ? null
                                  : 'אנא הכנס/י שעת התחלה'
                              : null,
                          errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        text: 'שעת סיום',
                        style: TextStyle(
                          color: CustomColor.dark_cyan,
                          fontFamily: 'Raleway',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: kIsWeb
                          ? EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width / 3)
                          : EdgeInsets.only(left: 10),
                      child: TextFormField(
                        textAlign: TextAlign.end,
                        cursorColor: CustomColor.sea_blue,
                        controller: textControllerEndTime,
                        onTap: () => _selectEndTime(context),
                        readOnly: true,
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        decoration: new InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.dark_blue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: EdgeInsets.only(
                            left: 16,
                            bottom: 16,
                            top: 16,
                            right: 16,
                          ),
                          hintText: 'דוגמא: 18:30',
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          errorText: isEditingEndTime &&
                                  textControllerEndTime.text != null
                              ? textControllerEndTime.text.isNotEmpty
                                  ? null
                                  : 'אנא הזנ/י שעת סיום'
                              : null,
                          errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        text: 'כותרת',
                        style: TextStyle(
                          color: CustomColor.dark_cyan,
                          fontFamily: 'Raleway',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: kIsWeb
                          ? EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width / 3)
                          : EdgeInsets.only(left: 10),
                      child: TextField(
                        enabled: true,
                        cursorColor: CustomColor.sea_blue,
                        focusNode: textFocusNodeTitle,
                        controller: textControllerTitle,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          setState(() {
                            isEditingTitle = true;
                            currentTitle = value;
                          });
                        },
                        onSubmitted: (value) {
                          textFocusNodeTitle.unfocus();
                          FocusScope.of(context)
                              .requestFocus(textFocusNodeDesc);
                        },
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        decoration: new InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.dark_blue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: EdgeInsets.only(
                            left: 16,
                            bottom: 16,
                            top: 16,
                            right: 16,
                          ),
                          hintText: 'דוגמא: תרגום לשיחה עם בנקאי',
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          errorText: isEditingTitle
                              ? _validateTitle(currentTitle)
                              : null,
                          errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        text: 'תיאור',
                        style: TextStyle(
                          color: CustomColor.dark_cyan,
                          fontFamily: 'Raleway',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' ',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: kIsWeb
                          ? EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width / 3)
                          : EdgeInsets.only(left: 10),
                      child: TextField(
                        enabled: true,
                        maxLines: null,
                        cursorColor: CustomColor.sea_blue,
                        focusNode: textFocusNodeDesc,
                        controller: textControllerDesc,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          setState(() {
                            currentDesc = value;
                          });
                        },
                        onSubmitted: (value) {
                          textFocusNodeDesc.unfocus();
                          FocusScope.of(context)
                              .requestFocus(textFocusNodeLocation);
                        },
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        decoration: new InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.dark_blue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: EdgeInsets.only(
                            left: 16,
                            bottom: 16,
                            top: 16,
                            right: 16,
                          ),
                          hintText: 'דוגמא: שיחה לגבי לקיחת הלוואה',
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // RichText(
                    //   text: TextSpan(
                    //     text: 'Location',
                    //     style: TextStyle(
                    //       color: CustomColor.dark_cyan,
                    //       fontFamily: 'Raleway',
                    //       fontSize: 20,
                    //       fontWeight: FontWeight.bold,
                    //       letterSpacing: 1,
                    //     ),
                    //     children: <TextSpan>[
                    //       TextSpan(
                    //         text: ' ',
                    //         style: TextStyle(
                    //           color: Colors.red,
                    //           fontSize: 28,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(height: 10),
                    // TextFormField(  textAlign: TextAlign.end,

                    //   enabled: true,
                    //   cursorColor: CustomColor.sea_blue,
                    //   focusNode: textFocusNodeLocation,
                    //   controller: textControllerLocation,
                    //   textCapitalization: TextCapitalization.words,
                    //   textInputAction: TextInputAction.next,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       currentLocation = value;
                    //     });
                    //   },
                    //   onSubmitted: (value) {
                    //     textFocusNodeLocation.unfocus();
                    //     FocusScope.of(context)
                    //         .requestFocus(textFocusNodeAttendee);
                    //   },
                    //   style: TextStyle(
                    //     color: Colors.black87,
                    //     fontWeight: FontWeight.bold,
                    //     letterSpacing: 0.5,
                    //   ),
                    //   decoration: new InputDecoration(
                    //     disabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    //       borderSide: BorderSide(color: Colors.grey, width: 1),
                    //     ),
                    //     enabledBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    //       borderSide:
                    //           BorderSide(color: CustomColor.sea_blue, width: 1),
                    //     ),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    //       borderSide: BorderSide(
                    //           color: CustomColor.dark_blue, width: 2),
                    //     ),
                    //     errorBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    //       borderSide:
                    //           BorderSide(color: Colors.redAccent, width: 2),
                    //     ),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    //     ),
                    //     contentPadding: EdgeInsets.only(
                    //       left: 16,
                    //       bottom: 16,
                    //       top: 16,
                    //       right: 16,
                    //     ),
                    //     hintText: 'Place of the event',
                    //     hintStyle: TextStyle(
                    //       color: Colors.grey.withOpacity(0.6),
                    //       fontWeight: FontWeight.bold,
                    //       letterSpacing: 0.5,
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 10),
                    // RichText(
                    //   text: TextSpan(
                    //     text: 'Attendees',
                    //     style: TextStyle(
                    //       color: CustomColor.dark_cyan,
                    //       fontFamily: 'Raleway',
                    //       fontSize: 20,
                    //       fontWeight: FontWeight.bold,
                    //       letterSpacing: 1,
                    //     ),
                    //     children: <TextSpan>[
                    //       TextSpan(
                    //         text: ' ',
                    //         style: TextStyle(
                    //           color: Colors.red,
                    //           fontSize: 28,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(height: 10),
                    // ListView.builder(
                    //   shrinkWrap: true,
                    //   physics: PageScrollPhysics(),
                    //   itemCount: attendeeEmails.length,
                    //   itemBuilder: (context, index) {
                    //     return Padding(
                    //       padding: const EdgeInsets.only(bottom: 8.0),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Text(
                    //             attendeeEmails[index].email,
                    //             style: TextStyle(
                    //               color: CustomColor.neon_green,
                    //               fontWeight: FontWeight.w600,
                    //               fontSize: 16,
                    //             ),
                    //           ),
                    //           IconButton(
                    //             icon: Icon(Icons.close),
                    //             onPressed: () {
                    //               setState(() {
                    //                 attendeeEmails.removeAt(index);
                    //               });
                    //             },
                    //             color: Colors.red,
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // ),
                    // SizedBox(height: 10),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Expanded(
                    //       child: TextFormField(  textAlign: TextAlign.end,

                    //         enabled: true,
                    //         cursorColor: CustomColor.sea_blue,
                    //         focusNode: textFocusNodeAttendee,
                    //         controller: textControllerAttendee,
                    //         textCapitalization: TextCapitalization.none,
                    //         textInputAction: TextInputAction.done,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             currentEmail = value;
                    //           });
                    //         },
                    //         onSubmitted: (value) {
                    //           textFocusNodeAttendee.unfocus();
                    //         },
                    //         style: TextStyle(
                    //           color: Colors.black87,
                    //           fontWeight: FontWeight.bold,
                    //           letterSpacing: 0.5,
                    //         ),
                    //         decoration: new InputDecoration(
                    //           disabledBorder: OutlineInputBorder(
                    //             borderRadius:
                    //                 BorderRadius.all(Radius.circular(10.0)),
                    //             borderSide:
                    //                 BorderSide(color: Colors.grey, width: 1),
                    //           ),
                    //           enabledBorder: OutlineInputBorder(
                    //             borderRadius:
                    //                 BorderRadius.all(Radius.circular(10.0)),
                    //             borderSide: BorderSide(
                    //                 color: CustomColor.sea_blue, width: 1),
                    //           ),
                    //           focusedBorder: OutlineInputBorder(
                    //             borderRadius:
                    //                 BorderRadius.all(Radius.circular(10.0)),
                    //             borderSide: BorderSide(
                    //                 color: CustomColor.dark_blue, width: 2),
                    //           ),
                    //           errorBorder: OutlineInputBorder(
                    //             borderRadius:
                    //                 BorderRadius.all(Radius.circular(10.0)),
                    //             borderSide: BorderSide(
                    //                 color: Colors.redAccent, width: 2),
                    //           ),
                    //           border: OutlineInputBorder(
                    //             borderRadius:
                    //                 BorderRadius.all(Radius.circular(10.0)),
                    //           ),
                    //           contentPadding: EdgeInsets.only(
                    //             left: 16,
                    //             bottom: 16,
                    //             top: 16,
                    //             right: 16,
                    //           ),
                    //           hintText: 'Enter attendee email',
                    //           hintStyle: TextStyle(
                    //             color: Colors.grey.withOpacity(0.6),
                    //             fontWeight: FontWeight.bold,
                    //             letterSpacing: 0.5,
                    //           ),
                    //           errorText: isEditingEmail
                    //               ? _validateEmail(currentEmail)
                    //               : null,
                    //           errorStyle: TextStyle(
                    //             fontSize: 12,
                    //             color: Colors.redAccent,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     IconButton(
                    //       icon: Icon(
                    //         Icons.check_circle,
                    //         color: CustomColor.sea_blue,
                    //         size: 35,
                    //       ),
                    //       onPressed: () {
                    //         setState(() {
                    //           isEditingEmail = true;
                    //         });
                    //         if (_validateEmail(currentEmail) == null) {
                    //           setState(() {
                    //             textFocusNodeAttendee.unfocus();
                    //             calendar.EventAttendee eventAttendee =
                    //                 calendar.EventAttendee();
                    //             eventAttendee.email = currentEmail;
                    //
                    //             attendeeEmails.add(eventAttendee);
                    //
                    //             textControllerAttendee.text = '';
                    //             currentEmail = null;
                    //             isEditingEmail = false;
                    //           });
                    //         }
                    //       },
                    //     ),
                    //   ],
                    // ),
                    // Visibility(
                    //   visible: attendeeEmails.isNotEmpty,
                    //   child: Column(
                    //     children: [
                    //       SizedBox(height: 10),
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Text(
                    //             'Notify attendees',
                    //             style: TextStyle(
                    //               color: CustomColor.dark_cyan,
                    //               fontFamily: 'Raleway',
                    //               fontSize: 20,
                    //               fontWeight: FontWeight.bold,
                    //               letterSpacing: 0.5,
                    //             ),
                    //           ),
                    // Switch(
                    //   value: shouldNofityAttendees,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       shouldNofityAttendees = value;
                    //     });
                    //   },
                    //   activeColor: CustomColor.sea_blue,
                    // ),
                    SizedBox(height: 30),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 3),
                      width: double.maxFinite,
                      child: RaisedButton(
                        onPressed: isDataStorageInProgress
                            ? null
                            : () async {
                                setState(() {
                                  isErrorTime = false;
                                  isDataStorageInProgress = true;
                                });

                                textFocusNodeTitle.unfocus();
                                textFocusNodeDesc.unfocus();
                                textFocusNodeLocation.unfocus();
                                textFocusNodeAttendee.unfocus();

                                if (selectedDate != null &&
                                    selectedStartTime != null &&
                                    selectedEndTime != null &&
                                    currentTitle != null) {
                                  int startTimeInEpoch = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedStartTime.hour,
                                    selectedStartTime.minute,
                                  ).millisecondsSinceEpoch;

                                  int endTimeInEpoch = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedEndTime.hour,
                                    selectedEndTime.minute,
                                  ).millisecondsSinceEpoch;

                                  print(
                                      'DIFFERENCE: ${endTimeInEpoch - startTimeInEpoch}');

                                  print(
                                      'Start Time: ${DateTime.fromMillisecondsSinceEpoch(startTimeInEpoch)}');
                                  print(
                                      'End Time: ${DateTime.fromMillisecondsSinceEpoch(endTimeInEpoch)}');

                                  if (endTimeInEpoch - startTimeInEpoch > 0) {
                                    if (_validateTitle(currentTitle) == null) {
                                      calendar.EventAttendee eventAttendee =
                                          calendar.EventAttendee();
                                      eventAttendee.email =
                                          'mickykroapps@gmail.com';

                                      attendeeEmails.add(eventAttendee);
                                      await calendarClient
                                          .insert(
                                              title: currentTitle,
                                              description: currentDesc ?? '',
                                              // location: currentLocation,
                                              attendeeEmailList: attendeeEmails,
                                              shouldNotifyAttendees: true,
                                              hasConferenceSupport: true,
                                              startTime: DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      startTimeInEpoch),
                                              endTime: DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                      endTimeInEpoch))
                                          .then((eventData) async {
                                        String eventId = eventData['id'];
                                        String eventLink = eventData['link'];

                                        List<String> emails = [];

                                        for (int i = 0;
                                            i < attendeeEmails.length;
                                            i++)
                                          emails.add(attendeeEmails[i].email);

                                        EventInfo eventInfo = EventInfo(
                                          id: eventId,
                                          name: currentTitle,
                                          description:
                                              eventLink ?? currentDesc ?? '',
                                          // location: currentLocation,
                                          link: eventLink,
                                          attendeeEmails:
                                              'mickykroapps@gmail.com',
                                          startTimeInEpoch: startTimeInEpoch,
                                          endTimeInEpoch: endTimeInEpoch,
                                        );

                                        await storage
                                            .storeEventData(eventInfo)
                                            .whenComplete(() =>
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DashboardScreen())))
                                            .catchError(
                                              (e) => print(e),
                                            );
                                      }).catchError(
                                        (e) => print(e),
                                      );

                                      setState(() {
                                        isDataStorageInProgress = false;
                                      });
                                    } else {
                                      setState(() {
                                        isEditingTitle = true;
                                        // isEditingLink = true;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      isErrorTime = true;
                                      errorString =
                                          'Invalid time! Please use a proper start and end time';
                                    });
                                  }
                                } else {
                                  setState(() {
                                    isEditingDate = true;
                                    isEditingStartTime = true;
                                    isEditingEndTime = true;
                                    isEditingBatch = true;
                                    isEditingTitle = true;
                                    // isEditingLink = true;
                                  });
                                }
                                setState(() {
                                  isDataStorageInProgress = false;
                                });
                              },
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: isDataStorageInProgress
                              ? SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                  ),
                                )
                              : Text(
                                  'קבע',
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                        ),
                      ),
                    )
                  ],
                ),
                // ],
              ),
            ),
            // SizedBox(height: 10),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       'Add video conferencing',
            //       style: TextStyle(
            //         color: CustomColor.dark_cyan,
            //         fontFamily: 'Raleway',
            //         fontSize: 20,
            //         fontWeight: FontWeight.bold,
            //         letterSpacing: 0.5,
            //       ),
            //     ),
            //     Switch(
            //       value: hasConferenceSupport,
            //       onChanged: (value) {
            //         setState(() {
            //           hasConferenceSupport = value;
            //         });
            //       },
            //       activeColor: CustomColor.sea_blue,
            //     ),
            // ],
          ),
          Visibility(
            visible: isErrorTime,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorString,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
