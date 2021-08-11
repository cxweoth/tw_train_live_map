import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_live_train/src/resources/repository.dart';
import 'package:map_live_train/src/blocs/live_train_map_bloc/train_map_state.dart';
import 'package:map_live_train/src/blocs/live_train_map_bloc/live_train_map_event.dart';
import 'package:map_live_train/src/models/live_train_model.dart';
import 'package:map_live_train/src/models/train_station_model.dart';
import 'package:map_live_train/src/models/train_line_model.dart';
import 'dart:developer' as developer;

class LiveTrainMapBloc extends Bloc<LiveTrainMapEvent, TrainMapState> {

    late Repository _repository;

    LiveTrainMapBloc({Repository ?repository}) : _repository = repository!, super(TrainMapState());

    @override
    Stream<TrainMapState> mapEventToState(LiveTrainMapEvent event) async* {
      switch (event.runtimeType) {

        case InitLiveTrainMap:
          state.formInit();
          try{
            TrainStationModel trainStationModel = await _repository.fetchTrainStationData();
            TrainLineModel trainLineModel = await _repository.fetchTrainLineData();
            state.formInitSucceed(trainStationModel, trainLineModel);
            yield state;
          } on Exception catch (e) {
            state.formInitFailed(e);
            yield state;
          }
          break;

        case InitLiveTrainMapComplete:
          state.formInitComplete();
          yield state;
          break;
        
        case RefreshLiveTrainMap:
          state.formRefresh();
          try{
            LiveTrainModel liveTrainModel = await _repository.fetchLiveTrainData();
            state.formRefreshSucceed(liveTrainModel);
            developer.log(state.liveTrainMapFormStatus.toString());
            yield state;
          } on Exception catch (e) {
            state.formRefreshFailed(e);
            yield state;
          }
          break;

        case RefreshLiveTrainMapComplete:
          state.formRefreshComplete();
          yield state;
          break;
      } 
    }
}