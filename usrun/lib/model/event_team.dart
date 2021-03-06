import 'package:usrun/model/mapper_object.dart';

class EventTeam with MapperObject {
  int teamId;
  String name;
  String avatar;
  int totalMember;
  int province;

  EventTeam({
    this.teamId,
    this.name,
    this.avatar,
    this.totalMember,
    this.province,
  });
}
