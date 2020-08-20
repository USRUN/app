import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/core/define.dart';
import 'package:usrun/core/helper.dart';
import 'package:usrun/manager/user_manager.dart';
import 'package:usrun/model/event_leaderboard.dart';
import 'package:usrun/model/object_filter.dart';
import 'package:usrun/util/image_cache_manager.dart';
import 'package:usrun/util/string_utils.dart';
import 'package:usrun/util/validator.dart';
import 'package:usrun/widget/avatar_view.dart';
import 'package:usrun/widget/custom_cell.dart';
import 'package:usrun/widget/custom_dialog/custom_selection_dialog.dart';
import 'package:usrun/widget/custom_gradient_app_bar.dart';
import 'package:usrun/widget/header_rank_lead.dart';
import 'package:usrun/widget/loading_dot.dart';

class EventLeaderboardPage extends StatefulWidget {
  @override
  _EventLeaderboardPageState createState() => _EventLeaderboardPageState();
}

class _EventLeaderboardPageState extends State<EventLeaderboardPage> {
  ObjectFilter<LeaderBoardType> _selectedFilter;
  List<ObjectFilter<LeaderBoardType>> _filterList;

  List<EventLeaderboard> _originalList;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _filterList = [
      ObjectFilter<LeaderBoardType>(
        value: LeaderBoardType.Team,
        name: R.strings.teams,
      ),
      ObjectFilter<LeaderBoardType>(
        value: LeaderBoardType.Individual,
        name: R.strings.individuals,
      ),
    ];

    _selectedFilter = _filterList[0];
    _getNecessaryData();
  }

  void _getNecessaryData() async {
    if (_selectedFilter == null) return;

    if (checkListIsNullOrEmpty(_originalList)) {
      _originalList = List();
    } else {
      _originalList.clear();
    }

    setState(() {
      _isLoading = true;
    });

    List<EventLeaderboard> result = List();
    if (_selectedFilter.value == LeaderBoardType.Individual) {
      // TODO: Use API of "Individual"
      result = [
        EventLeaderboard(
          name: "Quốc Trần Kiến",
          avatar: R.images.avatarQuocTK,
          distance: 285000,
          itemId: 1,
        ),
        EventLeaderboard(
          name: "Võ Thị Thanh Ngọc",
          avatar: R.images.avatarNgocVTT,
          distance: 272000,
          itemId: 2,
        ),
        EventLeaderboard(
          name: "Trần Minh Kha",
          avatar: R.images.avatarKhaTM,
          distance: 185900,
          itemId: 3,
        ),
      ];
    } else {
      // TODO: Use API of "Team"
      result = [
        EventLeaderboard(
          name: "Trường Đại học Khoa học Tự nhiên - ĐHQG HCM",
          avatar: R.images.avatarHuyTA,
          distance: 285000,
          itemId: 1,
        ),
        EventLeaderboard(
          name: "Công ty Cổ phần Hải Âu",
          avatar: R.images.avatarPhucTT,
          distance: 272000,
          itemId: 2,
        ),
        EventLeaderboard(
          name: "Tập đoàn Tôn Đông Âu",
          avatar: R.images.logo,
          distance: 185900,
          itemId: 3,
        ),
      ];
    }

    setState(() {
      _isLoading = false;
      if (!checkListIsNullOrEmpty(result)) {
        _originalList.addAll(result);
      }
    });
  }

  void _filterButton() async {
    int findArrayIndexOfSelectedFilter() {
      if (_selectedFilter == null || checkListIsNullOrEmpty(_filterList)) {
        return null;
      }

      for (int i = 0; i < _filterList.length; ++i) {
        if (_filterList[i].value == _selectedFilter.value) {
          return i;
        }
      }

      return null;
    }

    int selectedArrayIndex = findArrayIndexOfSelectedFilter();
    if (selectedArrayIndex == null) return;

    int newArrayIndex = await showCustomSelectionDialog(
      context,
      _filterList,
      selectedArrayIndex,
      title: R.strings.changeLeaderboardTypeTitle,
      description: R.strings.changeLeaderboardTypeDescription,
    );

    if (newArrayIndex == null) return;

    setState(() {
      _selectedFilter = _filterList[newArrayIndex];
    });

    // This function will be asynchronous
    _getNecessaryData();
  }

  void _goToAthleteOrTeamPage() {
    if (_selectedFilter.value == LeaderBoardType.Individual) {
      // TODO: Push "Profile" page - Nhớ push đúng page, thắc mắc, liên hệ Ngọc
      print("[EVENT_LEADERBOARD] Push 'Profile' page");
    } else {
      // TODO: Push "Team" page - Nhớ push đúng page, thắc mắc, liên hệ Kha
      print("[EVENT_LEADERBOARD] Push 'Team' page");
    }
  }

  Widget _renderFilterButton() {
    return Container(
      width: 55,
      child: FlatButton(
        padding: EdgeInsets.all(0.0),
        splashColor: R.colors.lightBlurMajorOrange,
        textColor: Colors.white,
        onPressed: _filterButton,
        child: ImageCacheManager.getImage(
          url: R.myIcons.appBarFunnelBtn,
          width: 18,
          height: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _renderDataList() {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.only(
          top: R.appRatio.appSpacing15,
        ),
        child: LoadingIndicator(),
      );
    }

    if (checkListIsNullOrEmpty(_originalList)) {
      return Container(
        padding: EdgeInsets.only(
          top: R.appRatio.appSpacing15,
        ),
        alignment: Alignment.center,
        child: Text(
          R.strings.noResult,
          textAlign: TextAlign.justify,
          style: TextStyle(
            color: R.colors.contentText,
            fontSize: R.appRatio.appFontSize18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: EdgeInsets.only(
        left: R.appRatio.appSpacing10,
        right: R.appRatio.appSpacing10,
      ),
      itemCount: _originalList.length,
      itemBuilder: (BuildContext context, int index) {
        EventLeaderboard data = _originalList[index];

        int id = data.itemId;
        String avatar = data.avatar;
        String name = data.name;
        String formattedDistance = NumberFormat("#,##0.##", "en_US").format(
          switchBetweenMeterAndKm(
            data.distance,
            formatType: RunningUnit.KILOMETER,
          ),
        );

        /*
            TODO: Nếu như "id" là userId (UserManager.currentUser.userId)
             hoặc là teamId (duy nhất 1 team mà user đã chọn khi đăng ký tham gia sự kiện)
        */
        Color contentColor = R.colors.contentText;
        if (_selectedFilter.value == LeaderBoardType.Individual) {
          if (id == UserManager.currentUser.userId) {
            contentColor = R.colors.majorOrange;
          }
        } else {
          // TODO: Không biết phải check thế nào khi thiếu dữ kiện!!!
        }

        return Container(
          key: Key(id.toString()),
          padding: EdgeInsets.only(
            top: (index == 0 ? R.appRatio.appSpacing15 : 0),
            bottom: R.appRatio.appSpacing15,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Number order
              Container(
                width: R.appRatio.appWidth50,
                alignment: Alignment.center,
                child: FittedBox(
                  child: Text(
                    (index + 1).toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: contentColor,
                      fontSize: R.appRatio.appFontSize16,
                    ),
                  ),
                ),
              ),
              // Custom cell
              Expanded(
                child: CustomCell(
                  enableSplashColor: false,
                  avatarView: AvatarView(
                    avatarImageURL: avatar,
                    avatarImageSize: R.appRatio.appWidth50,
                    avatarBoxBorder: Border.all(
                      width: 1,
                      color: R.colors.majorOrange,
                    ),
                    pressAvatarImage: _goToAthleteOrTeamPage,
                  ),
                  // Content
                  title: name,
                  titleStyle: TextStyle(
                    fontSize: R.appRatio.appFontSize16,
                    color: contentColor,
                  ),
                  enableAddedContent: false,
                  pressInfo: _goToAthleteOrTeamPage,
                ),
              ),
              // Distance
              Container(
                width: R.appRatio.appWidth80,
                alignment: Alignment.center,
                child: FittedBox(
                  child: Text(
                    formattedDistance,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: contentColor,
                      fontSize: R.appRatio.appFontSize16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _renderBodyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // HeaderRankLead
        Container(
          decoration: BoxDecoration(
            color: R.colors.boxBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 2.0,
                offset: Offset(0.0, 1.0),
                color: R.colors.btnShadow,
              ),
            ],
          ),
          child: HeaderRankLead(),
        ),
        // All contents
        Expanded(
          child: _renderDataList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = uppercaseFirstLetterEachWord(
      content: R.strings.eventLeaderboard,
      pattern: " ",
    );

    Widget _buildElement = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: R.colors.appBackground,
      appBar: CustomGradientAppBar(
        title: appBarTitle,
        actions: <Widget>[
          _renderFilterButton(),
        ],
      ),
      body: _renderBodyContent(),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
      child: _buildElement,
      onNotification: (overScroll) {
        overScroll.disallowGlow();
        return false;
      },
    );
  }
}