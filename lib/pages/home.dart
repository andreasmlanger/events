import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:events/services/events.dart';


class EventIcon extends StatefulWidget {
  final bool attending;
  final bool isNew;

  EventIcon({required this.attending, required this.isNew});

  @override
  _EventIconState createState() => _EventIconState();
}

class _EventIconState extends State<EventIcon> {
  @override
  Widget build(BuildContext context) {
    if (widget.attending) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (widget.isNew) {
      return const Icon(Icons.whatshot, color: Colors.indigo);
    }
    return const Icon(Icons.event, color: Colors.white);
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Map data = {};

  @override
  Widget build(BuildContext context) {

    final routeArguments = ModalRoute.of(context)?.settings.arguments;
    data = data.isNotEmpty ? data : routeArguments as Map<String, dynamic>? ?? {};
    List<Event> events = data['events'];

    void deleteItem(int index) {
      setState(() {
        events.removeAt(index);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Eventbrite & Meetup',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Nunito',
            fontSize: 24.0,
            fontWeight: FontWeight.w400,
          )
        ),
        backgroundColor: Colors.purple[800],
        actions: <Widget>[
          TextButton.icon(
            label: const Text(''),
            icon: const Icon(Icons.refresh),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
            onPressed: () {
              // Navigate to Loading Screen
              Navigator.of(context).pushReplacementNamed('/');
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          Event event = events[index];
          Color? bgColor = Colors.white;
          return Dismissible(
            key: Key(event.id.toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                event.hide();
                deleteItem(index);
              }
            },
            background: Container(
              color: Colors.red,
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 10.0),
            ),
            child: Card (
              elevation: 5,
              child: ListTile(
                tileColor: bgColor,
                title: GestureDetector(
                  onTap: () => {event.openUrl()},
                  child: Text(
                    event.event,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                subtitle: GestureDetector(
                  onTap: () => {event.openUrl()},
                  child: Text(
                    event.location,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                leading: GestureDetector(
                  onTap: () => {event.openUrl()},
                  child: SizedBox(
                    width: 38.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: event.website == 'meetup' ? const EdgeInsets.all(0.0) : const EdgeInsets.all(1.0),
                          child: CircleAvatar(
                              radius: event.website == 'meetup' ? 16.0 : 14.0,
                              backgroundColor: bgColor,
                              backgroundImage: AssetImage('assets/${event.website}.png')
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          formatDate(event.date),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                trailing: SizedBox(
                  width: 56.0,
                  child: Row(
                    children: [
                      EventIcon(attending: event.attending, isNew: isNew(event.createdAt)),
                      SizedBox(
                        width: 28.0,
                        child: PopupMenuButton<String>(
                          itemBuilder: (context) {
                            return [
                              const PopupMenuItem(
                                value: 'location',
                                child: Text(
                                  'Open location',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'attendOrSkip',
                                child: event.attending ? Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ) : Text(
                                  'Attend',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ];
                          },
                          onSelected: (value) {
                            if (value == 'location') {
                              MapsLauncher.launchCoordinates(event.latitude, event.longitude);
                            } else if (value == 'attendOrSkip') {
                              setState(() {
                                event.attending = !event.attending;
                                event.attending ? event.attend() : event.skip();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                contentPadding: EdgeInsets.only(left: 10.0, right: 0.0),
              ),
            ),
          );
        },
      ),
    );
  }
}
