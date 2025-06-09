import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ulearna_task/screens/new_screen/new_screen.dart';
import 'package:ulearna_task/service_locator/service_locator.dart';
import 'features/video/presentation/bloc/video_display_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  try {
    log("setup locator worked");
    await setupLocator();
  } catch (e) {
    log("Error setting up locator: $e");
  }

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<VideoBloc>()),
      

    ],
    child: MyApp(
      
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VideoBloc>(
      create: (_) => sl<VideoBloc>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ulearna Task',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
