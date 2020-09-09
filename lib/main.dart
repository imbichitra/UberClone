import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uberclone/screens/home.dart';
import 'package:uberclone/screens/map.dart';
import 'package:uberclone/states/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: AppState())
  ],
  child: MyApp(),));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'uber clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(title: 'Map',)
      //home:MyHomePage(title: 'Uber clone'),
    );
  }
}
