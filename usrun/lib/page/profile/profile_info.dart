import 'package:flutter/material.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/widget/event_list.dart';
import 'package:usrun/widget/follower_following_list.dart';
import 'package:usrun/widget/loading_dot.dart';
import 'package:usrun/widget/team_list.dart';
import 'package:usrun/widget/team_plan_list.dart';

// Demo data
import 'package:usrun/page/profile/demo_data.dart';

class ProfileInfo extends StatefulWidget {
  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  bool _isLoading;
  int _followingNumber;
  int _followerNumber;

  @override
  void initState() {
    _isLoading = true;
    _followingNumber = DemoData().ffItemList.length;
    _followerNumber = DemoData().ffItemList.length;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLoading());
  }

  void _updateLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void _pressFollowFuction(userCode) {
    // TODO: Implement function here
    print("[FFWidget] Follow this athlete with user code $userCode");
  }

  void _pressUnfollowFuction(userCode) {
    // TODO: Implement function here
    print("[FFWidget] Unfollow this athlete with user code $userCode");
  }

  void _pressProfileFunction(userCode) {
    // TODO: Implement function here
    print("[FFWidget] Direct to this athlete profile with user code $userCode");
  }

  void _pressEventItemFunction(eventID) {
    // TODO: Implement function here
    print("[EventWidget] Press event with id $eventID");
  }

  void _pressTeamItemFunction(teamID) {
    // TODO: Implement function here
    print("[TeamWidget] Press team with id $teamID");
  }

  void _pressTeamPlanItemFunction(planID) {
    // TODO: Implement function here
    print("[TeamPlanWidget] Press team plan with id $planID");
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading
        ? LoadingDotStyle02()
        : Column(
            children: <Widget>[
              // Following
              FollowerFollowingList(
                items: DemoData().ffItemList,
                enableFFButton: true,
                labelTitle: "Following",
                enableLabelShadow: true,
                subTitle: "$_followingNumber ATHLETE YOU FOLLOW",
                enableSubtitleShadow: true,
                enableScrollBackgroundColor: true,
                isFollowingList: true,
                pressFollowFuction: _pressFollowFuction,
                pressUnfollowFuction: _pressUnfollowFuction,
                pressProfileFunction: _pressProfileFunction,
              ),
              SizedBox(
                height: R.appRatio.appSpacing20,
              ),
              // Followers
              FollowerFollowingList(
                items: DemoData().ffItemList,
                enableFFButton: true,
                labelTitle: "Followers",
                enableLabelShadow: true,
                subTitle: "$_followerNumber ATHLETE FOLLOWING YOU",
                enableSubtitleShadow: true,
                enableScrollBackgroundColor: true,
                isFollowingList: false,
                pressFollowFuction: _pressFollowFuction,
                pressUnfollowFuction: _pressUnfollowFuction,
                pressProfileFunction: _pressProfileFunction,
              ),
              SizedBox(
                height: R.appRatio.appSpacing20,
              ),
              // Events
              EventList(
                items: DemoData().eventList,
                labelTitle: "Your Events",
                enableLabelShadow: true,
                enableScrollBackgroundColor: true,
                pressItemFuction: _pressEventItemFunction,
              ),
              SizedBox(
                height: R.appRatio.appSpacing20,
              ),
              // Teams
              TeamList(
                items: DemoData().teamList,
                labelTitle: "Your Teams",
                enableLabelShadow: true,
                enableScrollBackgroundColor: true,
                pressItemFuction: _pressTeamItemFunction,
              ),
              SizedBox(
                height: R.appRatio.appSpacing20,
              ),
              // Team plans
              TeamPlanList(
                items: DemoData().teamPlanList,
                labelTitle: "Your Team Plans",
                enableLabelShadow: true,
                enableScrollBackgroundColor: true,
                pressItemFuction: _pressTeamPlanItemFunction,
              ),
            ],
          ));
  }
}