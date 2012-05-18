/**
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

  createButton('play', 'startGame');

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

  for(var i = 0; i < Math.min(data.length, 3); i++) {
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

function startGame() {
  initGame();
  displayMenu(false);
}

