import 'package:usrun/model/mapper_object.dart';
import 'package:usrun/util/reflector.dart';

@reflector
class UserActivity with MapperObject {
  int userActivityId;
  int userId;
  String userDisplayName;
  int eventId;
  String eventName;
  DateTime createTime;
  int totalDistance;
  int totalTime;
  int totalStep;
  double avgPace;
  double avgHeart;
  double maxHeart;
  int calories;
  double elevGain;
  double elevMax;
  List<String> photos;
  String title;
  String description;
  int totalLove;
  int totalComment;
  int totalShare;

  UserActivity(
    this.userActivityId,
    this.userId,
    this.userDisplayName,
    this.eventId,
    this.eventName,
    this.createTime,
    this.totalDistance,
    this.totalTime,
    this.totalStep,
    this.avgPace,
    this.avgHeart,
    this.maxHeart,
    this.calories,
    this.elevGain,
    this.elevMax,
    this.photos,
    this.title,
    this.description,
    this.totalLove,
    this.totalComment,
    this.totalShare,
  );

  // Chưa có mảng dữ liệu cho Splits (KM, Pace, Elev,...)
}
