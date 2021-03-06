import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/manager/user_manager.dart';
import 'package:usrun/model/user_activity.dart';
import 'package:usrun/util/validator.dart';
import 'package:usrun/widget/feed/compact_user_activity_item.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<UserActivity> _userActivityList;
  int _page;
  bool _allowLoadMore;

  @override
  void initState() {
    super.initState();
    _getNecessaryData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!_allowLoadMore) return;

    List<UserActivity> result = await UserManager.getUserActivity(
      UserManager.currentUser.userId,
      offset: _page,
    );

    if (result != null && result.length != 0) {
      setState(() {
        _userActivityList.insertAll(_userActivityList.length, result);
        _page += 1;
      });
    } else {
      setState(() {
        _allowLoadMore = false;
      });
    }
  }

  Future<void> _getNecessaryData() async {
    setState(() {
      _userActivityList = List();
      _page = 0;
      _allowLoadMore = true;
    });
    await _loadData();
    _refreshController.refreshCompleted();
  }

  Widget _buildEmptyList() {
    return Center(
      child: Container(
        padding: EdgeInsets.only(
          left: R.appRatio.appSpacing25,
          right: R.appRatio.appSpacing25,
        ),
        child: Text(
          R.strings.emptyFeedList,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: R.colors.contentText,
            fontSize: R.appRatio.appFontSize16,
          ),
        ),
      ),
    );
  }

  Widget _renderBodyContent() {
    if (checkListIsNullOrEmpty(_userActivityList)) {
      return _buildEmptyList();
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(0.0),
      itemCount: _userActivityList.length,
      itemBuilder: (context, index) {
        if (index == _userActivityList.length - 1) {
          _loadData();
        }

        return Container(
          margin: EdgeInsets.only(
              bottom: (index != _userActivityList.length - 1 ? 12.0 : 0)),
          child: CompactUserActivityItem(
            userActivity: _userActivityList[index],
            callbackFunc: () async {
              setState(() {
                _userActivityList = List();
                _page = 0;
                _allowLoadMore = true;
              });
              await _loadData();
              _refreshController.refreshCompleted();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget smartRefresher = SmartRefresher(
      enablePullUp: false,
      controller: _refreshController,
      child: _renderBodyContent(),
      physics: BouncingScrollPhysics(),
      footer: null,
      onRefresh: () => _getNecessaryData(),
      onLoading: () async {
        await Future.delayed(Duration(milliseconds: 200));
      },
    );

    Widget refreshConfigs = RefreshConfiguration(
      child: smartRefresher,
      headerBuilder: () => WaterDropMaterialHeader(
        backgroundColor: R.colors.majorOrange,
      ),
      footerBuilder: null,
      shouldFooterFollowWhenNotFull: (state) {
        return false;
      },
      hideFooterWhenNotFull: true,
    );

    return NotificationListener<OverscrollIndicatorNotification>(
      child: refreshConfigs,
      onNotification: (overScroll) {
        overScroll.disallowGlow();
        return false;
      },
    );
  }
}
