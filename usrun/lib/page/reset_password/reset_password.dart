import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:usrun/core/R.dart';
import 'package:usrun/core/helper.dart';
import 'package:usrun/manager/user_manager.dart';
import 'package:usrun/model/response.dart';
import 'package:usrun/widget/custom_dialog/custom_alert_dialog.dart';
import 'package:usrun/widget/custom_gradient_app_bar.dart';
import 'package:usrun/widget/ui_button.dart';
import 'package:usrun/widget/input_field.dart';
import 'package:usrun/util/validator.dart';

class ResetPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: R.colors.appBackground,
      appBar: CustomGradientAppBar(title: R.strings.resetPassword),
      body: Container(
        padding: EdgeInsets.only(
          left: R.appRatio.appSpacing15,
          right: R.appRatio.appSpacing15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: R.appRatio.appSpacing20,
            ),
            Text(
              R.strings.resetPasswordNotice,
              style: TextStyle(
                color: R.colors.majorOrange,
                fontSize: R.appRatio.appFontSize18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: R.appRatio.appSpacing30,
            ),
            InputField(
              focusNode: _emailNode,
              controller: _emailController,
              enableFullWidth: true,
              hintText: R.strings.email,
              autoFocus: true,
            ),
            SizedBox(
              height: R.appRatio.appSpacing40,
            ),
            UIButton(
                width: R.appRatio.appWidth381,
                height: R.appRatio.appHeight50,
                gradient: R.colors.uiGradient,
                text: R.strings.reset,
                textSize: R.appRatio.appFontSize18,
                boxShadow: R.styles.boxShadowB,
                onTap: () async {
                  String email = _emailController.text.trim();
                  if(checkStringNullOrEmpty(email) || !validateEmail(email)){
                    await showCustomAlertDialog(
                      context,
                      title: R.strings.error,
                      content: "Please input a valid email.",
                      firstButtonText: R.strings.ok,
                      firstButtonFunction: () {
                        pop(context);
                      },
                    );

                    return;
                  }

                  FocusScope.of(context).requestFocus(new FocusNode());

                  Response<dynamic> response = await UserManager.resetPassword(
                      _emailController.text.trim());
                  if (response.success && response.errorCode == -1) {
                    //success
                    await showCustomAlertDialog(
                      context,
                      title: R.strings.notice,
                      content: R.strings.resetPasswordSuccessful,
                      firstButtonText: R.strings.ok,
                      firstButtonFunction: () {
                        pop(context);
                      },
                    );
                  } else {
                    // fail
                    await showCustomAlertDialog(
                      context,
                      title: R.strings.error,
                      content: response.errorMessage,
                      firstButtonText: R.strings.ok,
                      firstButtonFunction: () {
                        pop(context);
                      },
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
