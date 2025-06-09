import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:ulearna_task/service/api_service.dart';
import 'package:ulearna_task/local_database/local_database.dart';

import 'package:ulearna_task/features/video/data/data_sources/video_remote_data_source.dart';
import 'package:ulearna_task/features/video/data/repositories/video_repository.dart';
import 'package:ulearna_task/features/video/domain/video_repository.dart';
import 'package:ulearna_task/features/video/domain/video_use_cases.dart';
import 'package:ulearna_task/features/video/presentation/bloc/video_display_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  log('🚀 Setting up GetIt service locator');

  WidgetsFlutterBinding.ensureInitialized();

  // Core
  sl.registerLazySingleton(() => ApiService(baseUrl: ''));

  // ---------------- Video ----------------
  
  // Data Sources
  sl.registerLazySingleton<VideoRemoteDataSource>(
      () => VideoRemoteDataSource(apiService: sl()));
  sl.registerLazySingleton<VideoLocalDataSource>(
      () => VideoLocalDataSourceImpl());

  // Repository
  sl.registerLazySingleton<VideoRepository>(() => VideoRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetVideosUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedVideosUseCase(sl()));
  sl.registerLazySingleton(() => ClearVideoCacheUseCase(sl()));

  // BLoC
  sl.registerFactory(() => VideoBloc(
        getVideosUseCase: sl(),
        getCachedVideosUseCase: sl(),
        clearVideoCacheUseCase: sl(),
      ));

  log('✅ All services registered successfully');
}