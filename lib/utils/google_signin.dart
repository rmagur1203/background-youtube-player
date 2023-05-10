import 'dart:io';

import 'package:desktop_webview_auth/desktop_webview_auth.dart';
import 'package:desktop_webview_auth/google.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:http/http.dart' as http;

AccessToken? _accessToken;

Future<AuthClient> googleSignIn() async {
  if (Platform.isWindows) {
    if (_accessToken != null && !_accessToken!.hasExpired) {
      return gapis.authenticatedClient(
        http.Client(),
        gapis.AccessCredentials(
          _accessToken!,
          null,
          [YouTubeApi.youtubeScope, YouTubeApi.youtubeForceSslScope],
        ),
      );
    }
    final googleSignInArgs = GoogleSignInArgs(
      clientId:
          '1088790244412-kua6usim031tqqae5so9fme6oud9df6e.apps.googleusercontent.com',
      redirectUri: 'https://ytbg-player.firebaseapp.com/__/auth/handler',
      scope: 'https://www.googleapis.com/auth/userinfo.email '
          '${YouTubeApi.youtubeScope} '
          '${YouTubeApi.youtubeForceSslScope} ',
    );
    final googleAuth = await DesktopWebviewAuth.signIn(googleSignInArgs);
    final httpClient = gapis.authenticatedClient(
      http.Client(),
      gapis.AccessCredentials(
        _accessToken = gapis.AccessToken(
          'Bearer',
          googleAuth!.accessToken!,
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
        null,
        [YouTubeApi.youtubeScope, YouTubeApi.youtubeForceSslScope],
      ),
    );
    return httpClient;
  } else {
    GoogleSignIn googleSignIn = GoogleSignIn(
      clientId:
          '1088790244412-kua6usim031tqqae5so9fme6oud9df6e.apps.googleusercontent.com',
      scopes: [
        'email',
        YouTubeApi.youtubeScope,
        YouTubeApi.youtubeForceSslScope
      ],
    );
    var httpClient = (await googleSignIn.authenticatedClient());
    if (httpClient == null) {
      await googleSignIn.signIn();
      httpClient = (await googleSignIn.authenticatedClient())!;
    }
    return httpClient;
  }
}
