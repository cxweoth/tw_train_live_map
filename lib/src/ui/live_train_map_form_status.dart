abstract class LiveTrainMapFormStatus {
  const LiveTrainMapFormStatus();
}

class InitialLiveTrainMapForm extends LiveTrainMapFormStatus {}

class InitLiveTrainMapFormInit extends LiveTrainMapFormStatus {}

class InitLiveTrainMapFormSucceed extends LiveTrainMapFormStatus {}

class InitLiveTrainMapFormFailed extends LiveTrainMapFormStatus {
  final Exception exception;
  InitLiveTrainMapFormFailed(this.exception);
}

class InitLiveTrainMapFormComplete extends LiveTrainMapFormStatus {}

class RefreshLiveTrainMapFormRefreshing extends LiveTrainMapFormStatus {}

class RefreshLiveTrainMapFormSucceed extends LiveTrainMapFormStatus {}

class RefreshLiveTrainMapFormFailed extends LiveTrainMapFormStatus {
  final Exception exception;
  RefreshLiveTrainMapFormFailed(this.exception);
}

class RefreshLiveTrainMapFormComplete extends LiveTrainMapFormStatus {}