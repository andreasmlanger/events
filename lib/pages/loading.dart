import 'package:flutter/material.dart';
import 'package:events/services/events.dart';
import 'package:events/services/shader.dart';


class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);
  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  late List<Event> events;
  late ShaderController shaderController;

  @override
  void initState() {
    super.initState();
    shaderController = ShaderController(this);
    setupEvents();
  }

  @override
  void dispose() {
    shaderController.dispose();
    super.dispose();
  }

  void setupEvents() async {
    Events instance = Events();
    await instance.getEvents();
    events = instance.events;
    navigateToHome();
  }

  void navigateToHome() {
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, '/home', arguments: {
        'events': events,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShaderWidget(context, shaderController);
  }
}

