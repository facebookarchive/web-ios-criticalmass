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

Step 6 Add Achievement API support
- Create your achievement Object (server/goldmedal.php)
  - Make sure to add your App ID here and update the URL to your server
- Verify the Achievement Object in the Debug Tool (https://developers.facebook.com/tools/debug) and that everything looks good (no errors).
- Register the Achievement for Critical Mass (docs: https://developers.facebook.com/docs/achievements/)
  - POST https://graph.facebook.com/APP_ID/achievements
    achievement=ACHIEVEMENT_OBJECT_URL
    display_order=1
    access_token=APP_ACCESS_TOKEN
  - Note, this step only needs to be done once. Use curl or the Graph API Explorer: https://developers.facebook.com/tools/explorer
- Copy three new methods in client/game.js (see criticalmasscomplete/client/game.js at line 199 - 239)
  - checkIfAchievement()  // this will check the ingame logic to see if the user has meet the criteria for the achievement
  - getAchievements()     // this will get the list of achievements a user has already earned from the Graph API
  - saveAchievement()     // this will save the achievement for the user, similar to Scores in step 4
- Create a new global var in client/game.js
  - var gIsPlayerEligibleForAchievement = true; at line 39.  We will use this to check/set if the user is eligible to earn the achievement (users can only earn an achievement once).
- In core.js add a call to getAchievements() at line 47.  We will use this to check if the user has the achievement or not on game load.
- Finally add checkIfAchievement() in client/game.js at line 308.  This will start the process to award an achievement if the user meets the criteria for it.
Done!