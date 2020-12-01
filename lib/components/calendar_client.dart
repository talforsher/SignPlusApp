import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';

class CalendarClient {
  static var calendar;

  Future<Map<String, String>> insert({
    @required String title,
    @required String description,
    // @required String location,
    @required List<EventAttendee> attendeeEmailList,
    @required bool shouldNotifyAttendees,
    @required bool hasConferenceSupport,
    @required DateTime startTime,
    @required DateTime endTime,
  }) async {
    Map<String, String> eventData;

    String calendarId = "primary";
    Event event = Event();

    event.summary = title;
    event.description = description;
    event.attendees = attendeeEmailList;
    event.location = 'online';

    if (hasConferenceSupport) {
      ConferenceData conferenceData = ConferenceData();

      CreateConferenceRequest conferenceRequest = CreateConferenceRequest();
      conferenceRequest.requestId =
          "${startTime.millisecondsSinceEpoch}-${endTime.millisecondsSinceEpoch}";
      print('CALENDAR CLIENT 32 req id: ' + conferenceRequest.requestId);
      conferenceData.createRequest = conferenceRequest;
      print('CALENDAR CLIENT 34  createRequest:' + conferenceData.toString());

      event.conferenceData = conferenceData;
    }

    EventDateTime start = new EventDateTime();
    start.dateTime = startTime;
    start.timeZone = "GMT+05:30";
    event.start = start;

    EventDateTime end = new EventDateTime();
    end.timeZone = "GMT+05:30";
    end.dateTime = endTime;
    event.end = end;

    try {
      print(calendar);
      await calendar.events
          .insert(event, calendarId,
              conferenceDataVersion: hasConferenceSupport ? 1 : 0,
              sendUpdates: shouldNotifyAttendees ? "all" : "none")
          .then((value) {
        print("Event Status: ${value.status}");
        if (value.status == "confirmed") {
          String joiningLink;
          String eventId;

          eventId = value.id;

          if (hasConferenceSupport) {
            joiningLink =
                "https://meet.google.com/${value.conferenceData.conferenceId}";
          }

          // if (hasConferenceSupport) {
          //   joiningLink = "https://meet.jit.si/signnow";
          // }

          eventData = {'id': eventId, 'link': joiningLink};

          print('Event added to Google Calendar');
        } else {
          print("Unable to add event to Google Calendar");
        }
      });
    } catch (e) {
      print('Error creating event $e');
    }
    print(event.attendees);
    print(event);
    print(eventData);
    return eventData;
  }

  // Future<Map<String, String>> insert({
  //   @required String title,
  //   @required String description,
  //   // @required String location,
  //   @required List<EventAttendee> attendeeEmailList,
  //   @required bool shouldNotifyAttendees,
  //   @required bool hasConferenceSupport,
  //   @required DateTime startTime,
  //   @required DateTime endTime,
  // }) async {
  //   Map<String, String> eventData;
  //
  //   String calendarId = "primary";
  //   Event event = Event();
  //   print(event.description);
  //   event.summary = title;
  //   event.description = description;
  //   event.attendees = attendeeEmailList;
  //   event.location = 'online';
  //
  //   print(event.description);
  //   if (hasConferenceSupport) {
  //     ConferenceData conferenceData = ConferenceData();
  //
  //     CreateConferenceRequest conferenceRequest = CreateConferenceRequest();
  //     conferenceRequest.requestId =
  //         "${startTime.millisecondsSinceEpoch}-${endTime.millisecondsSinceEpoch}";
  //     print('CALENDAR CLIENT 32 req id: ' + conferenceRequest.requestId);
  //     conferenceData.createRequest = conferenceRequest;
  //     print('CALENDAR CLIENT 34  createRequest:' + conferenceData.toString());
  //
  //     event.conferenceData = conferenceData;
  //     print(event.description);
  //   }
  //
  //   EventDateTime start = new EventDateTime();
  //   start.dateTime = startTime;
  //   start.timeZone = "GMT+05:30";
  //   event.start = start;
  //
  //   EventDateTime end = new EventDateTime();
  //   end.timeZone = "GMT+05:30";
  //   end.dateTime = endTime;
  //   event.end = end;
  //
  //   print(event.status);
  //
  //   try {
  //     await calendar.events
  //         .insert(event, calendarId,
  //             conferenceDataVersion: hasConferenceSupport ? 1 : 0,
  //             sendUpdates: shouldNotifyAttendees ? "all" : "none")
  //         .then((value) {
  //       print("Event Status: ${value.status}");
  //       if (value.status == "confirmed") {
  //         String joiningLink;
  //         String eventId;
  //
  //         eventId = value.id;
  //
  //         if (hasConferenceSupport) {
  //           joiningLink = "https://meet.jit.si/signnow";
  //         }
  //
  //         eventData = {'id': eventId, 'link': joiningLink};
  //
  //         print('Event added to Google Calendar');
  //       } else {
  //         print("Unable to add event to Google Calendar");
  //       }
  //       print(event.status);
  //     });
  //   } catch (e) {
  //     print('Error creating event $e');
  //   }
  //   print(event.attendees);
  //   print(event.status);
  //   print(eventData.isEmpty);
  //   return eventData;
  // }

  Future<Map<String, String>> modify({
    @required String id,
    @required String title,
    @required String description,
    @required String location,
    @required List<EventAttendee> attendeeEmailList,
    @required bool shouldNotifyAttendees,
    @required bool hasConferenceSupport,
    @required DateTime startTime,
    @required DateTime endTime,
  }) async {
    Map<String, String> eventData;

    // If the account has multiple calendars, then select the "primary" one
    String calendarId = "primary";
    Event event = Event();

    event.summary = title;
    event.description = description;
    event.attendees = attendeeEmailList;
    event.location = location;

    ConferenceData conferenceData = ConferenceData();
    CreateConferenceRequest conferenceRequest = CreateConferenceRequest();
    conferenceRequest.requestId =
        "${startTime.millisecondsSinceEpoch}-${endTime.millisecondsSinceEpoch}";
    conferenceData.createRequest = conferenceRequest;

    event.conferenceData = conferenceData;

    EventDateTime start = new EventDateTime();
    start.dateTime = startTime;
    start.timeZone = "GMT+05:30";
    event.start = start;

    EventDateTime end = new EventDateTime();
    end.timeZone = "GMT+05:30";
    end.dateTime = endTime;
    event.end = end;

    try {
      await calendar.events
          .insert(event, calendarId,
              conferenceDataVersion: hasConferenceSupport ? 1 : 0,
              sendUpdates: shouldNotifyAttendees ? "all" : "none")
          .then((value) {
        print("Event Status: ${value.status}");
        if (value.status == "confirmed") {
          String joiningLink;
          String eventId;

          eventId = value.id;

          joiningLink =
              "https://meet.google.com/${value.conferenceData.conferenceId}";

          eventData = {'id': eventId, 'link': joiningLink};

          print('Event added to Google Calendar');
        } else {
          print("Unable to add event to Google Calendar");
        }
      });
    } catch (e) {
      print('Error creating event $e');
    }

    return eventData;
  }

  Future<void> delete(String eventId, bool shouldNotify) async {
    String calendarId = "primary";

    try {
      await calendar.events
          .delete(calendarId, eventId,
              sendUpdates: shouldNotify ? "all" : "none")
          .then((value) {
        print('Event deleted from Google Calendar');
      });
    } catch (e) {
      print('Error deleting event: $e');
    }
  }
}
