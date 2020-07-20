import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:usrun/core/R.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:usrun/core/helper.dart';
import 'package:usrun/demo_data.dart';
import 'package:usrun/manager/user_manager.dart';
import 'package:usrun/model/response.dart';
import 'package:usrun/model/team.dart';
import 'package:usrun/page/team/team_info.dart';
import 'package:usrun/page/team/team_search_page.dart';
import 'package:usrun/util/image_cache_manager.dart';
import 'package:usrun/widget/line_button.dart';
import 'package:usrun/widget/loading_dot.dart';
import 'package:usrun/widget/team_list/team_item.dart';
import 'package:usrun/widget/team_list/team_list.dart';
import 'package:usrun/manager/team_manager.dart';

class TeamPage extends StatefulWidget {
  final int suggestionLength = 15;
  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  bool _isLoading;
  List<TeamItem> _myTeamList;
  List<TeamItem> _teamSuggestionList;
  List<TeamItem> _myInvitedTeamList;
  List<TeamItem> _myRequestingTeamList;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _teamSuggestionList = List();
    _myTeamList = List();
//    _getMyTeamList(UserManager.currentUser.userId);
//    _getSuggestionList(widget.suggestionLength);

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLoading());
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _getMyTeamList(UserManager.currentUser.userId));
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _getSuggestionList(widget.suggestionLength));
  }

  void reloadTeamList() {
    _getMyTeamList(UserManager.currentUser.userId);
    _getSuggestionList(widget.suggestionLength);
    _refreshController.refreshCompleted();
  }

  void _updateLoading() {
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        _isLoading = !_isLoading;
      });
    });
  }

  List<dynamic> _getBannerList() {
    if (_teamSuggestionList == null) {
      List<dynamic> bannerList = List<dynamic>();
      for (int i = 0; i < DemoData().bannerList.length; ++i) {
        bannerList
            .add(ImageCacheManager.getImageData(url: DemoData().bannerList[i]));
      }
      return bannerList;
    }
    ;

    List<dynamic> bannerList = List<dynamic>();
    for (int i = 0; i < _teamSuggestionList.length; ++i) {
      bannerList.add(ImageCacheManager.getImageData(
          url: _teamSuggestionList[i].bannerImageURL));
    }

    return bannerList;
  }

  void _getMyTeamList(int userId) async {
    Response<dynamic> response = await TeamManager.getMyTeam();
    if (response.success && (response.object).isNotEmpty) {
      List<TeamItem> _toMyTeamList = List();
      List<TeamItem> _toMyInvitedTeamList = List();
      List<TeamItem> _toMyRequestingTeamList = List();

      response.object.forEach((Team element) {
        switch (element.teamMemberType) {
          case 5:
            _toMyInvitedTeamList.add(new TeamItem.from(element));
            break;
          case 4:
            _toMyRequestingTeamList.add(new TeamItem.from(element));
            break;
          default:
            _toMyTeamList.add(new TeamItem.from(element));
            break;
        }
      });
      setState(() {
        _myTeamList = _toMyTeamList;
        _myRequestingTeamList = _toMyRequestingTeamList;
        _myInvitedTeamList = _toMyInvitedTeamList;
      });
    } else {
      _myTeamList = null;
      _myRequestingTeamList = null;
      _myInvitedTeamList = null;
    }
  }

  void _getSuggestionList(int howMany) async {
    Response<dynamic> response = await TeamManager.getTeamSuggestion(howMany);
    if (response.success && (response.object).isNotEmpty) {
      List<TeamItem> toAdd = List();

      response.object.forEach((element) {
        toAdd.add(new TeamItem.from(element));
      });

      setState(() {
        _teamSuggestionList = toAdd;
      });
    } else {
      _teamSuggestionList = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: R.colors.appBackground,
        body: RefreshConfiguration(
          maxOverScrollExtent: 50,
          headerTriggerDistance: 50,
          child: SmartRefresher(
            enablePullDown: true,
            controller: _refreshController,
            onRefresh: () => {reloadTeamList()},
            child: (_isLoading
                ? LoadingDot()
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          height: R.appRatio.appHeight250,
                          width: R.appRatio.deviceWidth,
                          child: Carousel(
                            images: _getBannerList(),
                            defaultImage: R.images.smallDefaultImage,
                            dotSize: R.appRatio.appIconSize5,
                            dotSpacing: R.appRatio.appSpacing20,
                            dotColor: Colors.white,
                            dotIncreasedColor: R.colors.majorOrange,
                            dotBgColor: Colors.black.withOpacity(0.25),
                            boxFit: BoxFit.cover,
                            indicatorBgPadding: 5.0,
                            animationDuration: Duration(milliseconds: 500),
                            autoplayDuration: Duration(seconds: 8),
                          ),
                        ),
                        SizedBox(
                          height: R.appRatio.appSpacing20,
                        ),
                        TeamList(
                          items: _myTeamList,
                          labelTitle: R.strings.yourTeams,
                          enableLabelShadow: true,
                          enableScrollBackgroundColor: true,
                          pressItemFunction: (teamItem) {
                            // TODO: Test
                            pushPage(context,
                                    TeamInfoPage(teamId: teamItem.teamId));
                            print(
                                "[YourTeams] This team with id ${teamItem.teamId} is pressed");
                          },
                        ),
                        (_myInvitedTeamList.isEmpty
                            ? Container()
                            : SizedBox(
                                height: R.appRatio.appSpacing20,
                              )),
                        (_myInvitedTeamList.isEmpty
                            ? Container()
                            : TeamList(
                                items: _myInvitedTeamList,
                                labelTitle: "You are invited to join ",
                                enableLabelShadow: true,
                                enableScrollBackgroundColor: true,
                                enableSplitListToTwo: false,
                                pressItemFunction: (teamItem) {
                                  pushPage(context,
                                          TeamInfoPage(teamId: teamItem.teamId));
                                  print(
                                      "[Invited] This team with id ${teamItem.teamId} is pressed");
                                },
                              )),
                        (_myRequestingTeamList.isEmpty
                            ? Container()
                            : SizedBox(
                                height: R.appRatio.appSpacing20,
                              )),
                        (_myRequestingTeamList.isEmpty
                            ? Container()
                            : TeamList(
                                items: _myRequestingTeamList,
                                labelTitle: "Requesting teams",
                                enableLabelShadow: true,
                                enableScrollBackgroundColor: true,
                                enableSplitListToTwo: false,
                                pressItemFunction: (teamItem) {
                                  pushPage(context,
                                          TeamInfoPage(teamId: teamItem.teamId));
                                  print(
                                      "[Requested] This team with id ${teamItem.teamId} is pressed");
                                },
                              )),
                        SizedBox(
                          height: R.appRatio.appSpacing20,
                        ),
                        TeamList(
                          items: _teamSuggestionList,
                          labelTitle: R.strings.weSuggestYou,
                          enableLabelShadow: true,
                          enableScrollBackgroundColor: true,
                          enableSplitListToTwo: false,
                          pressItemFunction: (teamItem) {
                            pushPage(context,
                                    TeamInfoPage(teamId: teamItem.teamId));
                            print(
                                "[WeSuggestYou] This team with id ${teamItem.teamId} is pressed");
                          },
                        ),
                        SizedBox(
                          height: R.appRatio.appSpacing20,
                        ),
                        LineButton(
                          mainText: R.strings.viewAllTeams,
                          mainTextFontSize: R.appRatio.appFontSize16,
                          enableSuffixIcon: true,
                          suffixIconSize: R.appRatio.appIconSize15,
                          suffixIconImageURL: R.myIcons.nextIconByTheme,
                          enableBottomUnderline: true,
                          enableTopUnderline: true,
                          lineFunction: () {
                            pushPage(
                              context,
                              TeamSearchPage(
                                  autoFocusInput: false,
                                  defaultList: _teamSuggestionList),
                            );
                          },
                        ),
                      ],
                    ),
                  )),
          ),
        ));
  }
}
