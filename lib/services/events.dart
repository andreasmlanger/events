import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:events/services/storage_local.dart';
import 'package:events/services/storage_sql.dart';

// Specify if app user is admin or normal user
const bool userIsAdmin = true ;

final List<String> weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
final DateTime now = DateTime.now();

String formatDate(DateTime date) {
  Duration difference = date.difference(now);
  // Weekday is shown if event is less than 7 days in the future
  return difference.inDays < 6 ? weekdays[date.weekday - 1] : DateFormat('MM/dd').format(date);
}

bool isNew(DateTime date) {
  Duration difference = now.difference(date);
  return difference.inDays < 2;
}

class Event {
  final int id;
  final String website;
  final DateTime date;
  final String event;
  final String location;
  final String url;
  final double latitude;
  final double longitude;
  bool attending;
  bool hidden;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.website,
    required this.date,
    required this.event,
    required this.location,
    required this.url,
    required this.latitude,
    required this.longitude,
    required this.attending,
    required this.hidden,
    required this.createdAt,
  });

  void openUrl() async {
    Uri uri = Uri.parse(url);
    await launchUrl(uri);  // open Event webpage
  }

  void hide() async {
    if (userIsAdmin) {
      executeSqlQuery('UPDATE "public"."events_event" SET hidden = true WHERE id = @id');
    } else {
      saveLocalData(id, 'hidden');
    }
  }

  void attend() async {
    if (userIsAdmin) {
      executeSqlQuery('UPDATE "public"."events_event" SET attending = true WHERE id = @id');
    } else {
      saveLocalData(id, 'attending');
    }
  }

  void skip() async {
    if (userIsAdmin) {
      executeSqlQuery('UPDATE "public"."events_event" SET attending = false WHERE id = @id');
    } else {
      removeLocalData(id);
    }
  }

  void executeSqlQuery(String q) async {
    Connection conn = await connectToDatabase();
    await conn.execute(q, parameters: {'id': id});
    await conn.close();
  }
}

class Events {
  late List<Event> events;

  Future<void> getEvents() async {
    Connection conn = await connectToDatabase();
    print('connection done');
    String optionalHidden = userIsAdmin ? 'AND hidden = false ' : '';
    String q = 'SELECT * FROM "public"."events_event" WHERE user_id = 1 $optionalHidden ORDER BY date';
    final results = await conn.execute(q);

    events = results.map((row) {
      return Event(
        id: row[0] as int,
        website: row[1] as String,
        date: row[2] as DateTime,
        event: row[3] as String,
        location: row[4] as String,
        url: row[5] as String,
        latitude: row[6] as double,
        longitude: row[7] as double,
        attending: row[9] as bool,
        hidden: row[10] as bool,
        createdAt: row[11] as DateTime,
      );
    }).toList();

    if (!userIsAdmin) {
      events = await adaptEventsBasedOnLocalStorage(events);
      removeDeprecatedKeys(events);  // clean up
    }

    await conn.close();
  }

  Future<List<Event>> adaptEventsBasedOnLocalStorage(List<Event> events) async {
    List<Event> adaptedEvents = [];
    for (var event in events) {
      event.attending = await checkLocalStorage(event.id, 'attending');
      event.hidden = await checkLocalStorage(event.id, 'hidden');
      if (!event.hidden) {
        adaptedEvents.add(event);
      }
    }
    return adaptedEvents;
  }
}
