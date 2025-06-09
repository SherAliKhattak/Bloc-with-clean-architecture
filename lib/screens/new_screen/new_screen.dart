import 'package:flutter/material.dart';
import 'package:ulearna_task/features/video/domain/video_use_cases.dart';
import 'package:ulearna_task/features/video/presentation/bloc/video_display_bloc.dart';
import 'package:ulearna_task/screens/video_screen.dart';
import 'package:ulearna_task/service/api_service.dart';
import 'package:ulearna_task/service_locator/service_locator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to Video Screen'),
          onPressed: () async{
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VideoScreen()),
            );
          },
        ),
      ),
    );
  }
}
