/*
 Copyright 2011 Facebook, Inc.

 Licensed under the Apache License, Version 2.0 (the "License"); you may
 not use this file except in compliance with the License. You may obtain
 a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 License for the specific language governing permissions and limitations
 under the License.
*/

function createMenu() {
  var menuShim = document.createElement('div'); 
  menuShim.id = 'menu_shim';
  
  menuShim.style.width = gCanvasWidth + "px";
  menuShim.style.height = gCanvasHeight + "px";
  stage.appendChild(menuShim);
  
  var menuContainer = document.createElement('div'); 
  menuContainer.id = 'menu_container';
  stage.appendChild(menuContainer);
  menuContainer.style.width = stage.style.width;
  menuContainer.style.height = stage.style.height;

  //creat the score display
  var finalScore = document.createElement('div');
  finalScore.id = 'final_score';
  menuContainer.appendChild(finalScore);
  hideScore();

  createButton('play', 'playInit');
  createButton('invite', 'inviteInit');
  createButton('brag', 'bragInit');
  // Step #1: Create UI elements.
  createButton('buy', 'buy_coins');
  createButton('earn', 'earn_coins');

  var welcomeMsgContainer = document.createElement('div'); 
  welcomeMsgContainer.id = 'welcome_msg_container';
  stage.appendChild(welcomeMsgContainer);
  
  var welcomeMsg = document.createElement('div');
  var welcomeMsgStr = 'Welcome to Critical Mass';  
  welcomeMsg.innerHTML = welcomeMsgStr;
  welcomeMsg.id = 'welcome_msg';
  welcomeMsgContainer.appendChild(welcomeMsg);
  
  function createButton(name, handler) {
    var button = document.createElement('div'); 
    button.className = 'menu_item';
    button.id = name;
    button.setAttribute('onclick', 'javascript:' + handler + '()');
    menuContainer.appendChild(button);
    
    var buttonText = document.createElement('span'); 
    buttonText.innerHTML = name;
    button.appendChild(buttonText);
    buttonText.className = 'title';
  } 
}

function displayMenu(display) {
  if (display == true) {
    document.getElementById('play').style.display = 'block';
    document.getElementById('menu_container').style.display = 'block';
    document.getElementById('menu_shim').style.display = 'block';
    
    clearInterval(gDrameGameInterval);
  }
  else {
    document.getElementById('play').style.display = 'none';
    document.getElementById('menu_container').style.display = 'none';
    document.getElementById('welcome_msg_container').style.display = 'none';
    document.getElementById('menu_shim').style.display = 'none';
  }
}

function createLeaderboard(data) {
  var menuContainer = document.getElementById('menu_container');
  var leaderboardContainer = document.createElement('div');
  leaderboardContainer.id = 'leaderboard_container';
  menuContainer.appendChild(leaderboardContainer);
  
  for(var i = 0; i < data.length, i < 3; i++) {
    var leaderboardItem = createLeaderboardItem(
      data[i].user.name.split(' ')[0],
      '//graph.facebook.com/' + data[i].user.id + '/picture',
      data[i].score
    );
    leaderboardItem.id = 'item' + i;
    leaderboardItem.style.left = 0 + (80 * i) + 'px';
  }
   
   function createLeaderboardItem(name, profileImgURL, score) {
     var leaderboardItem = document.createElement('div');
     leaderboardItem.className = 'leaderboard_item';
     var profileImage = document.createElement('img');
     profileImage.src = profileImgURL;
     profileImage.className = 'profile_image';
     var nameText = document.createElement('div');
     nameText.className = 'item_text';
     nameText.innerHTML = name;
     var scoreText = document.createElement('div');
     scoreText.className = 'item_text';
     scoreText.innerHTML = score;
     
     leaderboardItem.appendChild(profileImage);
     leaderboardItem.appendChild(nameText);
     leaderboardItem.appendChild(scoreText);
     leaderboardContainer.appendChild(leaderboardItem);
     
     return leaderboardItem;
   }
}

function displayScore(score) {
  var scoreDisplay = document.getElementById('final_score');
  scoreDisplay.innerHTML = "Score: " + score;
}

function hideScore() {
  document.getElementById('final_score').innerHTML = "";
}

function playInit() {
  // If the user has connected to Facebook, let them play the game
  if(uid) {
    initGame();
    displayMenu(false);
  }
  else {
    authUser();
  }
}

function inviteInit() {
 // Use the Facebook JS SDK to open a Request MFS Dialog
  FB.ui({method: 'apprequests',
    title: 'My Great Invite',
    message: 'Check out Critical Mass!',
  }, fbCallback);
}

function leaderboardInit() {
  FB.api('/' + appId + '/scores', function(response) {
    createLeaderboard(response.data)
  });
}

function bragInit() {
  var messageStr = 'I just reached ' + gFinalScore + ' in Critical Mass!';

  FB.ui({ method: 'feed',
    caption: messageStr,
    name: 'Play Critical Mass Now',
    picture: 'http://www.bitdecay.net/labs/criticalmasscomplete/criticalmass.png',
    link: 'http://app.facebook.com/criticalmasscomplete'
  }, fbCallback);
}

function fbCallback(response) {
  console.log(response);
  document.getElementById('fb-ui-return-data').innerHTML=
    "<font color=white>" + response['order_id'] + " has been fulfilled." + "</font>";
}

// Step #2: Invoke Pay Dialog for buy item and earn currency.
// https://developers.facebook.com/docs/reference/dialogs/pay/#buy_item_localcurrency
function buy_coins() {
  var obj = {
    method: 'pay',
    action: 'buy_item',
    order_info: {'item_id': '1a'},
    dev_purchase_params: {'oscif': true}
  };
  FB.ui(obj, fbCallback);
}

// https://developers.facebook.com/docs/credits/offers/#app_currency_offers
function earn_coins() {
  var obj = {
    method: 'pay',
    action: 'earn_currency',
    product: 'http://SOME_URL/criticalmasscoin.html'
  };
  FB.ui(obj, fbCallback);
}
