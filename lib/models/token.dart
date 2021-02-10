import 'package:equatable/equatable.dart';

class Token extends Equatable{
  final String name;
  final String shortName;
  final String logoPath;

  const Token(this.name, this.shortName, this.logoPath);

  @override
  List<Object> get props => [shortName];
}