import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:usrun/manager/user_manager.dart';

const ACTIVITY_SECRET_KEY = 'zXGtCuT6lpj4sqaPCLIq0HUYuw';
const TRACK_SECRET_KEY = 'trackusrun1620';

class UsrunCrypto{

  static String buildActivitySig(String requestTime){

    List<int> secretBytes = utf8.encode(ACTIVITY_SECRET_KEY);
    List<int> messageBytes = utf8.encode("${UserManager.currentUser.userId.toString()}|$requestTime");
    
    var hmac = new Hmac(sha256, secretBytes);
    Digest sha256Result = hmac.convert(messageBytes);

    return sha256Result.toString();
  }

   static String buildTrackSig(int trackID, int createTime){

    List<int> secretBytes = utf8.encode(TRACK_SECRET_KEY);
    List<int> messageBytes = utf8.encode('${trackID.toString()}|${createTime.toString()}');
    
    var hmac = new Hmac(sha256, secretBytes);
    Digest sha256Result = hmac.convert(messageBytes);

  }
}