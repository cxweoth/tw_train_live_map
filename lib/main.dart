import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_live_train/src/app.dart';
import 'package:map_live_train/src/blocs/simple_bloc_delegate.dart';

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(App());
}
