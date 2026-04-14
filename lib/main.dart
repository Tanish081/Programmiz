import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:programming_learn_app/app.dart';
import 'package:programming_learn_app/core/utils/hive_boxes.dart';
import 'package:programming_learn_app/data/hive_adapters/certificate_adapter.dart';
import 'package:programming_learn_app/data/hive_adapters/interview_adapter.dart';
import 'package:programming_learn_app/data/hive_adapters/roadmap_adapter.dart';
import 'package:programming_learn_app/data/hive_adapters/user_progress_adapter.dart';
import 'package:programming_learn_app/data/models/certificate_model.dart';
import 'package:programming_learn_app/data/models/interview_models.dart';
import 'package:programming_learn_app/data/models/roadmap_model.dart';
import 'package:programming_learn_app/data/models/user_progress_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserProgressModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(RoadmapModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(RoadmapPhaseAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(RoadmapTopicAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(CertificateModelAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(InterviewSessionAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(InterviewQuestionAdapter());
  }

  await Hive.openBox<dynamic>(HiveBoxes.aiCache);
  await Hive.openBox<UserProgressModel>(HiveBoxes.userProgress);
  await Hive.openBox<RoadmapModel>(HiveBoxes.roadmap);
  await Hive.openBox<InterviewSession>(HiveBoxes.interview);
  await Hive.openBox<CertificateModel>(HiveBoxes.certificate);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CodeQuestApp();
  }
}
