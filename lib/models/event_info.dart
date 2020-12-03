import 'package:flutter/material.dart';

/// class for events to firebase and read from firebase
class EventInfo {
  final String id;
  final String name;
  final String description;
  // final String location;
  final String link;
  // final List<dynamic> attendeeEmails;
  final String attendeeEmails;
  // final bool shouldNotifyAttendees;
  // final bool hasConfereningSupport;
  final int startTimeInEpoch;
  final int endTimeInEpoch;

  /// constructor will require what parameters must EventInfo class have in each instance
  EventInfo({
    @required this.id,
    @required this.name,
    @required this.description,
    // @required this.location,
    @required this.link,
    @required this.attendeeEmails,
    // @required this.shouldNotifyAttendees,
    // @required this.hasConfereningSupport,
    @required this.startTimeInEpoch,
    @required this.endTimeInEpoch,
  });

  /// create instance of EventInfo and fill from a Map/dictionary
  EventInfo.fromMap(Map snapshot)
      : id = snapshot['id'] ?? '',
        name = snapshot['name'] ?? '',
        description = snapshot['desc'],
        // location = snapshot['loc'],
        link = snapshot['link'],
        attendeeEmails = snapshot['emails'] ?? '',
        // shouldNotifyAttendees = snapshot['should_notify'],
        // hasConfereningSupport = snapshot['has_conferencing'],
        startTimeInEpoch = snapshot['start'],
        endTimeInEpoch = snapshot['end'];

  /// convert EventInfo to Json
  toJson() {
    return {
      'id': id,
      'name': name,
      'desc': description,
      // 'loc': location,
      'link': link,
      'emails': attendeeEmails,
      // 'should_notify': shouldNotifyAttendees,
      // 'has_conferencing': hasConfereningSupport,
      'start': startTimeInEpoch,
      'end': endTimeInEpoch,
    };
  }
}
