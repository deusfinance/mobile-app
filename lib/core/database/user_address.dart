import 'package:floor/floor.dart';

@Entity(tableName: 'UserAddress')
class UserAddress {
  @PrimaryKey(autoGenerate: true)
  int? id;

  String name;
  String address;

  UserAddress({this.id, required this.name, required this.address});
}
