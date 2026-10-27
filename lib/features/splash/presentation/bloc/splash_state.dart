import 'package:equatable/equatable.dart';

enum SplashStatus { initial, loading, completed, failure }

class SplashState extends Equatable {
  final SplashStatus status;
  final String? errorMessage;

  const SplashState({
    this.status = SplashStatus.initial,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, errorMessage];
}
