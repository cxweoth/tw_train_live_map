import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tw_train_live_map/src/app.dart';
import 'package:tw_train_live_map/src/blocs/simple_bloc_delegate.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(App());
}
