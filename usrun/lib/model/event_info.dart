import 'package:usrun/model/event_organization.dart';
import 'package:usrun/util/reflector.dart';
import 'package:usrun/model/mapper_object.dart';

@reflector
class EventInfo with MapperObject {
  int status;
  String eventName;
  String subtitle;
  String description;
  String thumbnail;
  String poster;
  String banner;
  int totalDistance;
  int totalTeamParticipant;
  int totalParticipant;
  DateTime startTime;
  DateTime endTime;
  int teamId;
  String reward;

  /*
    Sponsor Type: Powered, Gold, Silver, Bronze, Collaborated
    sponsorIds[0]: List of powered-by
    [1]: List of Gold sponsors
    [2]: List of Silver sponsors
    [3]: List of Bronze sponsors
    [4]: List of Collaborators
   */
  List<dynamic> sponsorIds;

  EventInfo({
    this.status,
    this.eventName,
    this.subtitle,
    this.description,
    this.thumbnail,
    this.poster,
    this.banner,
    this.totalDistance,
    this.totalTeamParticipant,
    this.totalParticipant,
    this.startTime,
    this.endTime,
    this.teamId,
    this.reward,
    this.sponsorIds,
  });
}
