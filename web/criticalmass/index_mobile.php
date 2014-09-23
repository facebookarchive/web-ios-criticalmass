FB.init is used to initialize the JavaScript SDK. You only need to pass in your App ID, not your App Secret, which should never be stored client side. Next we attempt to retrive the User ID for the current user with FB.getLoginStatus. If uid was not set then the user has not authorized the game. Finally we create a new function called authUser that we can use to Authorize the user. When invoked this function will call FB.login from the JavaScript SDK. This will pop up a new window with the Login Dialog.

<!--authUser 
* Copyright 2012 Facebook, Inc.
*
* You are hereby granted a non-exclusive, worldwide, royalty-free license to
* use, copy, modify, and distribute this software in source code or binary
* form for use in connection with the web services and APIs provided by
* Facebook.
*
* As with any software that integrates with the Facebook platform, your use
* of this software is subject to the Facebook Developer Principles and
* Policies [http://developers.facebook.com/policy/]. This copyright notice
* shall be included in all copies or substantial portions of the software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
* DEALINGS IN THE SOFTWARE.
-->

<!DOCTYPE html>

<html>
<head>
  <title>Critical Mass</title>

  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <meta name="apple-mobile-web-app-capable" content="yes" />
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
  <meta property="og:image" content="http://www.mattwkelly.com/html5/critical-mass/critical_mass.png"/>

  <link href="client/style.css" rel="stylesheet" type="text/css">
  <link rel="apple-touch-icon" href="http://www.mattwkelly.com/html5/critical-mass/critical_mass.png" />

</head>
<body ontouchmove="BlockMove(event);">
<div id="fb-root"></div>
<script src="//connect.facebook.net/en_US/all.js"></script>

  <div id="stage">
    <div id="gameboard">
      <canvas id="myCanvas"></canvas>
    </div>
  </div>

  <script src="client/core.js"></script>
  <script src="client/game.js"></script>
  <script src="client/ui.js"></script>
  <script src="http://code.jquery.com/jquery-1.5.min.js"></script>

<script>
  var appId = 'APP_ID';
  var uid;

  // Initialize the JS SDK
  FB.init({
    appId: appId,
    cookie: true,
  });

  // Get the user's UID and first name
  FB.getLoginStatus(function(response) {
    uid = response.authResponse.userID ? response.authResponse.userID : null;
  });

  function authUser() {
    FB.login(function(response) {
      uid = response.authResponse.userID ? response.authResponse.userID : null;
    }, {scope:'email,publish_actions'});
  }
</script>

</body>
</html>
