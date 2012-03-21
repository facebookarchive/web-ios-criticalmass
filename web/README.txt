This document will walk you through the same steps that were presented during the GDC 5 Steps talk.  The original app is in /criticalmass and the final, integrated app is in /criticalmasscomplete

Step 0 (Set Up)
- Copy criticalmass to criticalmasscanvas
- Create Critical Mass App in the Developer App (developers.facebook.com/apps)
- In Basic Settings
  - Enter name Critical Mass
  - Enter namespace (make it unique)
  - Enter Canvas URLs in App on Facebook (example: www.bitdecay.net/labs/criticalmasscomplete)
- In Advanced Settings
  - Set sandbox mode = false
  - Set Canvas Width to Fluid, Canvas Height to settable (600px)
  - Add our Developers to the Developer Role
- Load in our Canvas Page URL and test it works (apps.facebook.com/NAMESPACE)

Step 1 Auth for Canvas (App on Facebook)
- Download the PHP SDK (curl -L https://github.com/facebook/php-sdk/tarball/master > php-sdk.tgz)
- tar zxfv php-sdk.tgz
- Copy src into server/fb-php-sdk
- Copy lines 1-31 from example.txt into index.php at line 1.
- Make sure to update the global variables to include your namespace, app id and app secret
- Show Critical Mass on Canvas and Authorize the app

Step 1 Auth for Mobile Web
- In the Developer App, Basic Settings
  - Enter the mobile web index_mobile.php path for Mobile Web URL
- Copy index.php to index_mobile.php
- Delete any PHP code in index_mobile.php (if you are doing both Canvas and Mobile Web)
- Copy lines 34-57 from example.txt into index_mobile.php at line 32
- Make sure to update the appID variable with your app id
- In client/ui.js replaced startGame() with startGame from example.txt, line 60

Step 2 Implement Requests as Invites
- If you haven't already loaded the JavaScript SDK in index.php, index_mobile.php
- In client/ui.js
  - Add createButton('invite', 'sendInvite') at line 38
  - Copy and paste sendInvite() implementation in client/ui.js from example.txt
  - Copy and paste fbCallback() implementation in client/ui.js from example .txt
- Show Critical Mass on Canvas and send an Invite to a Friend
- Notice that friend doesn't receive the request as she is not a tester and it's in sandbox mode
- Add friend as a tester and repeat
- Accept the Request as Friend and install the game
- Show that the Request is not cleared.  Oh noes!
- Copy and paste PHP code from example.txt line 102 into index.php to clear any requests on click through into index.php

Step 3 Implement Feed Post
- If you haven't already loaded the JavaScript SDK in index.php, index_mobile.php
- In client/ui.js
  - Add createButton('brag', 'sendBrag') at line 39
  - Copy and Paste sendBrag() implementation in client/ui.js from example.txt
- Post Critical Mass Feed story

Step 4 Implement the Facebook Scores API
- You should already have server/savescore.php defined to save scores back to Facebook
- In client/game.js at line 179 replace saveScore() with implementation from example.txt to make AJAX request to savescore.php

Step 5 Load a leaderboard of Facebook friends
- In client/ui.js
  - copy leaderInit() from example.txt to line 162
- In client/core.js
  - Add leaderboardInit() in init() at line 46
- The createLeaderboard() function and CSS classes should already be defined, to draw the leaderboard

Done!