import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/core/helper.dart';
import 'package:usrun/demo_data.dart';
import 'package:usrun/manager/team_manager.dart';
import 'package:usrun/model/response.dart';
import 'package:usrun/model/team.dart';
import 'package:usrun/page/team/team_info.dart';
import 'package:usrun/widget/avatar_view.dart';
import 'package:usrun/widget/custom_cell.dart';
import 'package:usrun/widget/input_field.dart';
import 'package:usrun/widget/loading_dot.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class TeamSearchPage extends StatefulWidget {
  final bool autoFocusInput;
  final int resultPerPage = 15;
  final List defaultList;

  TeamSearchPage({
    this.autoFocusInput = false,
    @required this.defaultList
  });

  @override
  _TeamSearchPageState createState() => _TeamSearchPageState();
}

class _TeamSearchPageState extends State<TeamSearchPage> {
  final TextEditingController _textSearchController = TextEditingController();
  bool _isLoading;
  bool remainingResults;
  List<Team> teamList;
  String curSearchString;
  int curResultPage;

  @override
  void initState() {
    super.initState();
    curSearchString = "";
    _isLoading = true;
    curResultPage = 1;
    remainingResults = true;
    teamList = List();

    if(widget.defaultList != null)
      teamList = widget.defaultList;
    else _findTeamByName();

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLoading());
  }

  void _updateLoading() {
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        _isLoading = !_isLoading;
      });
    });
  }


  void _findTeamByName() async {
    if(!remainingResults) return;

    remainingResults = false;
    Response<dynamic> response = await TeamManager.findTeamRequest(curSearchString, curResultPage, widget.resultPerPage);

    if(response.success && (response.object as List).isNotEmpty){
      List<Team> toAdd = response.object;
      setState(() {
        teamList.addAll(toAdd);
        remainingResults = true;
        curResultPage += 1;
      });
    }
  }

  void _onSubmittedFunction(data) {
    if (data.toString().length == 0) return;

    //reset states

    setState(() {
      _isLoading = !_isLoading;
      curSearchString = data.toString();
      teamList.clear();
      curResultPage = 0;
      remainingResults = true;
    });

    // TODO: Implement function here
    print("Data: $data");

    _findTeamByName();

    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void _onChangedFunction(data) {
    // [Demo] Clear all searching content => Render "SuggestedTeams" by setState
    if (data.toString().length == 0) {
      setState(() {
        teamList = widget.defaultList;
      });
    }
  }

  bool _isEmptyList() {
    return ((this.teamList == null || this.teamList.length == 0) ? true : false);
  }

  Widget _buildEmptyList() {
    String systemNoti =
        "No result";

    return Center(
      child: Container(
        padding: EdgeInsets.only(
          left: R.appRatio.appSpacing25,
          right: R.appRatio.appSpacing25,
        ),
        child: Text(
          systemNoti,
          textAlign: TextAlign.justify,
          style: TextStyle(
            color: R.colors.contentText,
            fontSize: R.appRatio.appFontSize14,
          ),
        ),
      ),
    );
  }

  Widget _renderSuggestedTeams() {
    return AnimationLimiter(
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels ==
            scrollInfo.metrics.maxScrollExtent) {
          if(remainingResults)
            _findTeamByName();
        }
        return true; // just to clear a warning
      },
      child: _isEmptyList()?
      _buildEmptyList():
      ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount:(teamList!=null)?teamList.length:0,
          itemBuilder: (BuildContext ctxt, int index) {
            String avatarImageURL = teamList[index].thumbnail;
            String supportImageURL = teamList[index].thumbnail;
            String teamName = teamList[index].teamName;
            String athleteQuantity = NumberFormat("#,##0", "en_US")
                .format(teamList[index].totalMember);
            String location = teamList[index].province.toString();

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 100.0,
                    child: FadeInAnimation(
                      child: Container(
                        padding: EdgeInsets.only(
                          top: (index == 0 ? R.appRatio.appSpacing20 : 0),
                          bottom: R.appRatio.appSpacing20,
                          left: R.appRatio.appSpacing15,
                          right: R.appRatio.appSpacing15,
                        ),
                        child: CustomCell(
                          avatarView: AvatarView(
                            avatarImageURL: avatarImageURL,
                            avatarImageSize: R.appRatio.appWidth60,
                            avatarBoxBorder: Border.all(
                              width: 1,
                              color: R.colors.majorOrange,
                            ),
                            supportImageURL: supportImageURL,
                            pressAvatarImage: () {
                              print("Pressing avatar image");
                            },
                          ),
                          // Content
                          title: teamName,
                          titleStyle: TextStyle(
                            fontSize: R.appRatio.appFontSize16,
                            color: R.colors.contentText,
                            fontWeight: FontWeight.w500,
                          ),
                          firstAddedTitle: athleteQuantity,
                          firstAddedTitleIconURL: R.myIcons.peopleIconByTheme,
                          firstAddedTitleIconSize: R.appRatio.appIconSize15,
                          secondAddedTitle: location,
                          secondAddedTitleIconURL: R.myIcons.gpsIconByTheme,
                          secondAddedTitleIconSize: R.appRatio.appIconSize15,
                          pressInfo: () {
                            print("Pressing info");
                            pushPage(context, TeamInfoPage(teamId: teamList[index].id));
                          },
                        ),
                      ),
                    ),
                  ),
                );
              })),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildElement = Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: R.colors.appBackground,
      appBar: GradientAppBar(
        leading: new IconButton(
          icon: Image.asset(
            R.myIcons.appBarBackBtn,
            width: R.appRatio.appAppBarIconSize,
          ),
          onPressed: () => pop(context),
        ),
        gradient: R.colors.uiGradient,
        title: InputField(
          controller: _textSearchController,
          hintText: R.strings.search,
          hintStyle: TextStyle(
            fontSize: R.appRatio.appFontSize18,
            color: Colors.white.withOpacity(0.5),
          ),
          contentStyle: TextStyle(
            color: Colors.white,
            fontSize: R.appRatio.appFontSize18,
            fontWeight: FontWeight.w500,
          ),
          bottomUnderlineColor: Colors.white,
          enableBottomUnderline: true,
          isDense: true,
          autoFocus: widget.autoFocusInput,
          textInputAction: TextInputAction.search,
          onSubmittedFunction: _onSubmittedFunction,
          onChangedFunction: _onChangedFunction,
        ),
      ),
      body: (_isLoading ? LoadingDot() : _renderSuggestedTeams()),
    );

    return NotificationListener<OverscrollIndicatorNotification>(
        child: _buildElement,
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        });
  }
}