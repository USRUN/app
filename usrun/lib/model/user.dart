import 'package:usrun/core/define.dart';


import 'package:usrun/model/mapper_object.dart';

import 'package:usrun/util/reflector.dart';

@reflector
class User extends MapperObject {
  int userId;
  String openId;
  LoginChannel type;
  String code;
  String email;
  String img;
  String name;
  String nameSlug;
  bool isActive;
  String deviceToken;
  DateTime birthday;
  String phone;
  String country;
  String city;
  Gender gender;
  num weight;
  num height;
  // test tạm thời
  String accessToken = "Bearer  eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2IiwiaWF0IjoxNTg1ODEwNDE5LCJleHAiOjE1ODY0MTUyMTl9.CSIQmHZgpde8TVX6PKZxpqBujqgKQ2Hsy5j4HSTPZvA";
  // --------------
  DateTime lastLogin;

  DateTime addDate;
  DateTime updateDate;

  int mainTeam;
  DateTime switchTeamDate;

  int followerCount;
  int followingCount;
  int activityCount;


  num distance;
  int rank;
  int activeDays;

  FollowingPrivacy followingPrivacy;
  ActivitiesPrivacy activitiesPrivacy;

  FollowStatus followStatus;

  List<int> notifications;

  UserRole teamRole;

  @override
  bool operator == (other) {
    if (other is User) {
      return userId == other.userId;
    }
    return false;
  }
}