import 'package:hive/hive.dart';

//part 'parameter.g.dart';

@HiveType(typeId: 0)
class Parameter extends HiveObject {
  @HiveField(0)
  late String header;

  @HiveField(1)
  late String description;
}
