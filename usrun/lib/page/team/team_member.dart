import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/core/define.dart';
import 'package:usrun/core/helper.dart';
import 'package:usrun/manager/team_manager.dart';
import 'package:usrun/model/response.dart';
import 'package:usrun/page/team/team_member_all.dart';
import 'package:usrun/page/team/team_member_blocked.dart';
import 'package:usrun/page/team/team_member_pending.dart';
import 'package:usrun/util/image_cache_manager.dart';
import 'package:usrun/util/team_member_util.dart';
import 'package:usrun/widget/custom_dialog/custom_alert_dialog.dart';
import 'package:usrun/widget/custom_dialog/custom_complex_dialog.dart';
import 'package:usrun/widget/custom_gradient_app_bar.dart';
import 'package:usrun/widget/custom_popup_menu/custom_popup_item.dart';
import 'package:usrun/widget/custom_tab_bar.dart';
import 'package:usrun/widget/input_field.dart';

import 'member_search_page.dart';

class TeamMemberPage extends StatefulWidget {
  final adminTabBarItems = [
    R.strings.all,
    R.strings.requesting,
    R.strings.blocking,
  ];

  final tabBarItems = [R.strings.all];

  final int teamId;
  final TeamMemberType teamMemberType;
  final int resultPerPage = 10;

  static final popUpMenu = [
    PopupItem(
      iconURL: R.myIcons.closeIconByTheme,
      iconSize: R.appRatio.appIconSize15,
      title: R.strings.kickAMember,
      value: "Kick",
    ),
    PopupItem(
      iconURL: R.myIcons.blockIconByTheme,
      iconSize: R.appRatio.appIconSize15,
      title: R.strings.blockAPerson,
      value: "Block",
    ),
    PopupItem(
      iconURL: R.myIcons.starIconByTheme,
      iconSize: R.appRatio.appIconSize15,
      title: R.strings.promoteAPerson,
      value: "Promote",
    ),
    PopupItem(
      iconURL: R.myIcons.caloriesStatsIconByTheme,
      iconSize: R.appRatio.appIconSize15,
      title: R.strings.demoteAPerson,
      value: "Demote",
    ),
  ];

  final List<List<PopupItem>> adminOptions = [
    [],
    [],
    [
      popUpMenu[0],
      popUpMenu[1],
    ],
  ];

  final List<List<PopupItem>> ownerOptions = [
    [],
    [
      popUpMenu[0],
      popUpMenu[1],
      popUpMenu[3],
    ],
    popUpMenu.sublist(0, 3),
  ];

  final List memberTypes = [
    'Owner',
    'Admin',
    'Member',
    'Pending',
    'Invited',
    'Blocked',
    'Guest'
  ];

  TeamMemberPage({@required this.teamId, @required this.teamMemberType});

  @override
  _TeamMemberPageState createState() => _TeamMemberPageState();
}

class _TeamMemberPageState extends State<TeamMemberPage>
    with SingleTickerProviderStateMixin {
  List<String> tabItems;
  List options = List();
  TabController _tabController;
  List<Widget> tabBarViewItems;
  GlobalKey<AllMemberPageState> allMemberPage = GlobalKey();
  GlobalKey<PendingMemberPageState> pendingMemberPage = GlobalKey();
  GlobalKey<BlockedMemberPageState> blockedMemberPage = GlobalKey();
  bool renderAsMember;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    switch (widget.teamMemberType) {
      case TeamMemberType.Owner:
        options = List<List<PopupItem>>();
        options = widget.ownerOptions;
        break;
      case TeamMemberType.Admin:
        options = widget.adminOptions;
        break;
      default:
        options = null;
        break;
    }

    if (TeamMemberUtil.authorizeHigherLevel(
      TeamMemberType.Admin,
      widget.teamMemberType,
    )) {
      initAsAdmin();
    } else {
      initAsMember();
    }
  }

  Widget renderAsUnauthorized() {
    return Center(
        child: RefreshConfiguration(
      maxOverScrollExtent: 50,
      headerTriggerDistance: 50,
      child: SmartRefresher(
        enablePullDown: true,
        controller: _refreshController,
        onRefresh: () {
          setState(() {});
          _refreshController.refreshCompleted();
        },
        footer: null,
        child: Container(
          padding: EdgeInsets.only(
            left: R.appRatio.appSpacing25,
            right: R.appRatio.appSpacing25,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                R.strings.memberOnly,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: R.colors.contentText,
                  fontSize: R.appRatio.appFontSize18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                R.strings.memberOnlySubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: R.colors.contentText,
                  fontSize: R.appRatio.appFontSize14,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void initAsAdmin() {
    tabItems = widget.adminTabBarItems;
    renderAsMember = false;
    tabBarViewItems = [
      AllMemberPage(
        teamId: widget.teamId,
        teamMemberType: widget.teamMemberType,
        options: options,
        renderAsMember: renderAsMember,
        key: allMemberPage,
      ),
      PendingMemberPage(
        teamId: widget.teamId,
        teamMemberType: widget.teamMemberType,
        key: pendingMemberPage,
      ),
      BlockedMemberPage(
        teamId: widget.teamId,
        teamMemberType: widget.teamMemberType,
        key: blockedMemberPage,
      ),
    ];

    _tabController = TabController(length: tabItems.length, vsync: this);

    _tabController.addListener(() {
      int prevIndex = _tabController.previousIndex;
      switch (prevIndex) {
        case 0:
          handleCallReload(allMemberPage.currentState.callReload);
          allMemberPage.currentState.callReload = -1;
          break;
        case 1:
          handleCallReload(pendingMemberPage.currentState.callReload);
          pendingMemberPage.currentState.callReload = -1;
          break;
        case 2:
          handleCallReload(blockedMemberPage.currentState.callReload);
          blockedMemberPage.currentState.callReload = -1;
          break;
        default:
          break;
      }
    });
  }

  void handleCallReload(int callReload) {
    switch (callReload) {
      case 0:
        allMemberPage.currentState.reloadItems();
        break;
      case 1:
        pendingMemberPage.currentState.reloadItems();
        break;
      case 2:
        blockedMemberPage.currentState.reloadItems();
        break;
      default:
        break;
    }
  }

  void initAsMember() {
    renderAsMember = true;
    tabBarViewItems = [
      AllMemberPage(
        teamId: widget.teamId,
        teamMemberType: widget.teamMemberType,
        options: options,
        renderAsMember: renderAsMember,
      )
    ];
    tabItems = widget.tabBarItems;

    _tabController = TabController(length: tabItems.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildElement = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: R.colors.appBackground,
      appBar: CustomGradientAppBar(
        title: R.strings.teamMember,
        actions: <Widget>[
          Container(
            width: 55,
            child: (TeamMemberUtil.authorizeHigherLevel(
                    TeamMemberType.Member, widget.teamMemberType))
                ? FlatButton(
                    onPressed: () async {
                      await _showCustomDialog(context, widget.teamId);
                    },
                    padding: EdgeInsets.all(0.0),
                    splashColor: R.colors.lightBlurMajorOrange,
                    textColor: Colors.white,
                    child: ImageCacheManager.getImage(
                      url: R.myIcons.addIcon02ByTheme,
                      width: R.appRatio.appAppBarIconSize,
                      height: R.appRatio.appAppBarIconSize,
                      color: Colors.white,
                    ),
                  )
                : Container(),
          ),
          Container(
            width: 55,
            child: (TeamMemberUtil.authorizeHigherLevel(
                    TeamMemberType.Member, widget.teamMemberType))
                ? FlatButton(
                    onPressed: () {
                      pushPage(
                        context,
                        //MEMBER SEARCH PAGE
                        MemberSearchPage(
                          autoFocusInput: true,
                          tabItems: tabItems,
                          selectedTab: _tabController.index,
                          teamId: widget.teamId,
                          options: options,
                          renderAsMember: renderAsMember,
                        ),
                      );
                    },
                    padding: EdgeInsets.all(0.0),
                    splashColor: R.colors.lightBlurMajorOrange,
                    textColor: Colors.white,
                    child: ImageCacheManager.getImage(
                      url: R.myIcons.appBarSearchBtn,
                      width: R.appRatio.appAppBarIconSize,
                      height: R.appRatio.appAppBarIconSize,
                      color: Colors.white,
                    ))
                : Container(),
          ),
        ],
      ),
      body: (TeamMemberUtil.authorizeHigherLevel(
              TeamMemberType.Member, widget.teamMemberType))
          ? CustomTabBarStyle03(
              tabBarTitleList: tabItems,
              tabController: _tabController,
              tabBarViewList: tabBarViewItems,
            )
          : renderAsUnauthorized(),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
      child: _buildElement,
      onNotification: (overScroll) {
        overScroll.disallowGlow();
        return false;
      },
    );
  }

//  final FocusNode _inviteNode = FocusNode();

  static Future<void> _showCustomDialog(
      BuildContext context, int teamId) async {
    TextEditingController _nameController = TextEditingController();

    await showCustomComplexDialog<bool>(
      context,
      headerContent: R.strings.inviteNewMember,
      descriptionContent: R.strings.inviteNewMemberContent,
      inputFieldList: [
        InputField(
          controller: _nameController,
          enableFullWidth: true,
          labelTitle: R.strings.invitationFieldTitle,
          hintText: R.strings.invitationFieldTitle,
          autoFocus: true,
        ),
      ],
      firstButtonText: R.strings.invite.toUpperCase(),
      firstButtonFunction: () async {
        Response<dynamic> res = await TeamManager.inviteNewMember(
            teamId, _nameController.text.trim());

        if (res.success) {
          pop(context);
          showCustomAlertDialog(
            context,
            title: R.strings.notice,
            content: R.strings.invitationSent,
            firstButtonText: R.strings.ok.toUpperCase(),
            firstButtonFunction: () {
              pop(context);
            },
          );
        } else {
          pop(context);
          showCustomAlertDialog(
            context,
            title: R.strings.error,
            content: res.errorMessage,
            firstButtonText: R.strings.ok.toUpperCase(),
            firstButtonFunction: () {
              pop(context);
            },
          );
        }
      },
      secondButtonText: R.strings.cancel.toUpperCase(),
      secondButtonFunction: () => pop(context),
    );
  }
}
