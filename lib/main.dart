import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mahaweli_admin_system/firebase_options.dart';
import 'package:mahaweli_admin_system/providers.dart';
import 'package:mahaweli_admin_system/screens/employee_profiles.dart';
import 'package:mahaweli_admin_system/screens/upcoming_salary_increment_screen.dart';
import 'package:mahaweli_admin_system/services/auth/login.dart';
import 'package:mahaweli_admin_system/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'services/dispatch/dispatc_for_screen.dart';
import 'services/dispatch/view_dispatch_screen.dart';
import 'services/note/presentation/data/notes.dart';
import 'services/todo/presentation/data/todo_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(ToDoModelAdapter());
  Hive.registerAdapter(NoteAdapter());

  await Hive.openBox('to-do-box');
  await Hive.openBox<Note>('notes');

  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (_) => FirestoreService(),
        ),
        ChangeNotifierProvider(
          create: (_) => NavigationProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mahaweli Admin System',
      home: PurpleLoginPage(),
    );
  }
}