import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import '../models/event.dart';

class CalendarSyncService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/calendar.readonly',
    ],
  );

  static Future<List<Event>> importGoogleCalendar() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Google Sign In failed');

      final GoogleSignInAuthentication auth = await account.authentication;
      final credentials = AccessCredentials(
        AccessToken(
          'Bearer',
          auth.accessToken!,
          DateTime.now().add(const Duration(hours: 1)),
        ),
        null,
        ['https://www.googleapis.com/auth/calendar.readonly'],
      );

      final client = GoogleAuthClient(credentials);
      final calendar = google_calendar.CalendarApi(client);

      final calendarEvents = await calendar.events.list(
        'primary',
        timeMin: DateTime.now().subtract(const Duration(days: 30)).toUtc(),
        timeMax: DateTime.now().add(const Duration(days: 365)).toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      return calendarEvents.items?.map((googleEvent) {
        final startTime = googleEvent.start?.dateTime ?? DateTime.now();
        final endTime = googleEvent.end?.dateTime ?? startTime.add(const Duration(hours: 1));

        return Event(
          title: googleEvent.summary ?? 'No Title',
          startTime: startTime,
          endTime: endTime,
          description: googleEvent.description,
          location: googleEvent.location,
          isAllDay: googleEvent.start?.date != null,
        );
      }).toList() ?? [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Event>> importICSFile(String icsContent) async {
    try {
      final calendar = ICalendar.fromString(icsContent);
      final List<Event> events = [];

      for (final vevent in calendar.data) {
        if (vevent['type'] == 'VEVENT') {
          final startTime = DateTime.parse(vevent['dtstart']);
          final endTime = DateTime.parse(vevent['dtend']);

          events.add(Event(
            title: vevent['summary'] ?? 'No Title',
            startTime: startTime,
            endTime: endTime,
            description: vevent['description'],
            location: vevent['location'],
            isAllDay: false,
          ));
        }
      }

      return events;
    } catch (e) {
      rethrow;
    }
  }
}

class GoogleAuthClient extends http.BaseClient {
  final AccessCredentials credentials;
  final http.Client _client = http.Client();

  GoogleAuthClient(this.credentials);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['Authorization'] = 'Bearer ${credentials.accessToken.data}';
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
  }
}
