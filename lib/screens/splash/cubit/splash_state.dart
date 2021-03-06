part of 'splash_cubit.dart';

abstract class SplashState extends Equatable {
  const SplashState() : this.receivedData = false;

  const SplashState.withData() : this.receivedData = true;

  final bool receivedData;

  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashSuccess extends SplashState {
  const SplashSuccess() : super.withData();
}

class SplashError extends SplashState {}
