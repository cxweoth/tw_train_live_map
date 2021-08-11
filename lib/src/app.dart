import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tw_train_live_map/src/blocs/live_train_map_bloc/live_train_map_bloc.dart';
import 'package:tw_train_live_map/src/resources/repository.dart';
import 'package:flutter/material.dart';
import 'ui/live_train_map_form_view.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LIVE TRAIN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => LiveTrainMapBloc(repository: Repository()),
        child: LiveTrainMapView(),
      ) 
    );
  }
}
