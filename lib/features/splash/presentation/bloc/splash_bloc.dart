import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/wait_for_splash.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final WaitForSplash waitForSplash;

  SplashBloc({required this.waitForSplash})
      : super(const SplashState()) {
    on<SplashStarted>(_onStarted);
  }

  Future<void> _onStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    if (state.status == SplashStatus.loading ||
        state.status == SplashStatus.completed) {
      return;
    }

    emit(const SplashState(status: SplashStatus.loading));

    try {
      await waitForSplash();
      emit(const SplashState(status: SplashStatus.completed));
    } catch (error) {
      emit(SplashState(
        status: SplashStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }
}
