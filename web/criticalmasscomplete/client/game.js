/* Game control variables */
var gLevel = 6; //The starting level
var gCircleSize = 5; //The size of the user initiated explosion
var gCircleExplosionTime = 75; //The max time that the circle should explode
var gCircleExplosionSize = 40; //The maxium explosion size of circles, in width
var gCircleExplosionGrowthRate = 2; //How quick the circle's explosion grows in size
var gCircleMaxDX = 5; //The maxium explosion size of circles, in width
var gCircleMaxDY = 5; //The maxium explosion size of circles, in height
var gCircleMinDX = 2; //The size of the initial circles that are bouncing around, in width
var gCircleMinDY = 2; //The size of the initial circles that are bouncing around, in height
var gExplosionTimeRate = 1; //How quickly the circle's explosion grows over time
var gCircleTransparency = 0.6; //Transparency of the circles
var gGameClockSetting = 30; //How much time the player has for each gameplay session (in seconds)
var gGameComplete = .30; //The percentage of circles does the user need to explode before advancing to the next level

/* Debug */
var gDbgShowFPS = 0;
var gDbgShowBorder = 0;

/* Game play tracking globals, do not edit */
var gDrameGameInterval = 0;
var gFinalScore = 0;
var gInitGame = false;
var gContext;
var gCanvasElement;
var gFrameTimes = [];
var gHasAttacked = 0;

var gGameClock = gGameClockSetting;
var gGameClockIntervalID = 0;

var gCircles = Array();
var gCirclesDestroyed = 0;
var gCirclesDead = 0;

var gCanvasWidth;
var gCanvasHeight;

var gIsPlayerEligibleForAchievement = true;

//Determine the size of the viewport
window.addEventListener('load', function () {
  setTimeout(function () {
    gCanvasWidth = parseInt(stage.style.width);
    gCanvasHeight = parseInt(stage.style.height);

    var gameboard = document.getElementById('gameboard');
    gameboard.style.width = gCanvasWidth + 'px';
    gameboard.style.height = gCanvasHeight + 'px';

  }, 10)
}, true);

//Starts the game so the user can start playing
function initGame() {
  //Make sure that the game is reset, in case the game clock has expired
  if (gGameClock <= 0) {
    resetGame();
  }

  //Start the loop to draw the game to the screen
  gDrameGameInterval = setInterval(draw, 15);

  levelCheck();

  gCanvasElement = document.getElementById('myCanvas');
  gCanvasElement.ontouchstart = function (e){
    var cell = getCursorPosition(e);
  }
  gCanvasElement.onclick = function (e){
    var cell = getCursorPosition(e);
  }

  startGameClock();
}

//Resets the user's game
function resetGame() {
  gInitGame = false;

  gGameClock = gGameClockSetting;

  hideScore();
}

//Main game loop, which is executed on a fast loop so we can animate
function draw() {
  //First, clear the canvas in preparation for the next draw
  gContext = gCanvasElement.getContext('2d');
  gContext.canvas.width = gCanvasWidth;
  gContext.canvas.height = gCanvasHeight;
  gContext.clearRect(0, 0, gCanvasWidth, gCanvasHeight);

  //The game has ended, so remove all of the circles from the screen
  if (gInitGame == false) {
    delete gCircles;
    gCircles = Array();

    while (gCircles.length <= gLevel - 1) {
      x = gCircles.length;
      gCircles[x] = new circle();

      gCircles[x].init(Math.random()*gCircleMaxDX-Math.random()*gCircleMinDX,
                      Math.random()*gCircleMaxDY-Math.random()*gCircleMinDY,
                      Math.floor(Math.random()*gCanvasWidth),
                      Math.floor(Math.random()*gCanvasHeight));
    }

    gInitGame = true;
  }

  for (x in gCircles) {
    gCircles[x].draw();
  }
}

function startGameClock() {
  gameClock();

  gGameClockIntervalID = setInterval(function () {
    gameClock();
  }, 1000);
}

function stopGameClock() {
  clearInterval(gGameClockIntervalID);
}

//Used in a loop to update the game clock
function gameClock() {
  //decrement game clock
  gGameClock -= 1;

  if (!document.getElementById('game_clock')) {
    var gameClock = document.createElement('div');
  }
  else {
    var gameClock = document.getElementById('game_clock');
  }

  if (gGameClock >= 60) {
    gGameClockSecs = gGameClock - 60;

    if (gGameClockSecs < 10) {
      gGameClockSecs = "0" + gGameClockSecs;
    }

    gGameClockText = "1:" + gGameClockSecs;
  }
  else {
    gGameClockText = gGameClock;
  }

  gameClock.innerHTML = gGameClockText + ' seconds';
  gameClock.id = 'game_clock';
  stage.appendChild(gameClock);

  //check to see if game is over
  if (gGameClock <= 0) {
    gameOver();
  }
}

function pauseGame() {
  stopGameClock();
}

function gameOver() {
  stopGameClock();

  //set the score
  saveScore();

  //show score
  displayScore(gFinalScore);

  //show menu
  displayMenu(true);
}

function saveScore() {
  gFinalScore = gLevel * 15;

  var params = {
    score: gFinalScore
  };

  FB.api('/me/scores', 'post', params, function(response) {
    console.log(response);
    if (!response || response.error) {
      alert('Error saving score!');
    } else {
      console.log('Saved Score');
    }
  });
}

function checkIfAchievement() {
  // if gCirclesDestroyed > 2 then attempt to award the Achievement
  if(gCirclesDestroyed > 2 && gIsPlayerEligibleForAchievement) {

    // Attempt to award the acheivement to the player
    saveAchievement();
  }
}

// This method will get the users achievements from Facebook and determine
// if they are eligible to earn the '3 Ball Combo' achievements.
// Achievements can only be achieved *once*.
function getAchievements() {
  FB.api('/me/achievements', function(response) {
    for(var i = 0; i < response.data.length; i++) {
      if(response.data[i].achievement.title == '3 Ball Combo') {
        gIsPlayerEligibleForAchievement = false;
        break;
      }
    }

    console.log('Player Eligible for 3 Ball Combo: ' + gIsPlayerEligibleForAchievement);
  });
}

function saveAchievement() {
  var params = {
    achievement: 'http://DOMAIN_NAME/criticalmasscomplete/server/goldmedal.php'
  };

  FB.api('/me/achievements', 'post', params, function(response) {
    console.log(response);
    if (!response || response.error) {
      alert('Error saving achievement!');
    } else {
      console.log('Saved Achievement');
      gIsPlayerEligibleForAchievement = false;
    }
  });
}

//Circle class
function circle() {
  //init a circle
  this.init = function (dx, dy, x, y, width, height) {
    this.dx = dx;
    this.dy = dy;
    this.x = x;
    this.y = y;
    this.shrink = false;
    this.explosion_time = 0;
    this.dead = false;
    this.rgb_r = Math.floor(Math.random()*216+40);
    this.rgb_g = Math.floor(Math.random()*216+40);
    this.rgb_b = Math.floor(Math.random()*216+40);

    if (width) {
      this.width = width;
    }
    else {
      this.width = gCircleSize;
    }

    if (height) {
      this.height = height;
    }
    else {
      this.height = gCircleSize;
    }

    this.destroyed = false;
  }

  //Explode the circle
  this.explode = function() {
  //Has reached max explosion, so stop it
    if (this.width >= gCircleExplosionSize && this.shrink == false) {
      this.explosion_time = this.explosion_time + gExplosionTimeRate;

      //Explosion has finished, now start to shrink it
      if (this.explosion_time >= gCircleExplosionTime) {
        this.width = this.width - gCircleExplosionGrowthRate;
        this.shrink = true;
      }
    }
    else {
      //Explosion over
      if (this.shrink == true && this.width > 0) {
        this.width = this.width - gCircleExplosionGrowthRate;

        if (this.width <= 1) {
          if (this.dead == false) {
            gCirclesDead += 1;
            this.dead = true;
          }

          if (gCirclesDead >= gCirclesDestroyed) {
            levelCheck();
          }
        }
      }
      else {
        this.width = this.width + gCircleExplosionGrowthRate;
      }
    }

    if (this.destroyed == false) {
      gCirclesDestroyed += 1;
      checkIfAchievement();
    }

    this.destroyed = true;

    if (this.dead == false) {
      //check to see if it makes impact with other circles
      for (x in gCircles) {
        //don't include user's circle or those that have already exploded
        if (gCircles[x].destroyed == false) {
          var does_overlap = overlap(this, gCircles[x]);
        }
        if (does_overlap == true) {
          gCircles[x].explode();
        }
      }
    }
  }

  //main function that is looped to draw the circles
  this.draw = function() {
    //if the circle hasn't exploded yet
    if (this.destroyed == false) {
      if (this.x < 0 || this.x > gCanvasWidth) {
        this.dx = -this.dx;
      }
      if (this.y < 0 || this.y > gCanvasHeight) {
        this.dy = -this.dy;
      }
      this.x += this.dx;
      this.y += this.dy;
    }
    else {
      this.explode();
    }

    //draw the circle
    if (this.width > 0 && this.dead == false) {
      gContext.beginPath();
      gContext.fillStyle = "rgba(" + this.rgb_r + ", " + this.rgb_g + ", " + this.rgb_b + ", " + gCircleTransparency + ")";
      gContext.arc(this.x, this.y, this.width, 0, Math.PI * 2, true);
      gContext.closePath();
      gContext.fill();
    }
  }
}

//Detects overlap between two circles
function overlap(circle_1, circle_2) {
  delta = (circle_1.width + 40) / 2;

  if (Math.abs(dx = circle_1.x - circle_2.x) > delta) return false
  if (Math.abs(dy = circle_1.y - circle_2.y) > delta) return false

  return true;
}

function getCursorPosition(e) {
  var x;
  var y;

  if (typeof(e.touches) !== 'undefined') {
    var touch = e.touches[0];

    if (touch.pageX != undefined && touch.pageY != undefined) {
      x = touch.pageX;
      y = touch.pageY;
    } else {
      x = touch.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
      y = touch.clientY + document.body.scrollTop + document.documentElement.scrollTop;
    }
  }
  else {
    if (e.pageX != undefined && e.pageY != undefined) {
      x = e.pageX;
      y = e.pageY;
    } else {
      x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
      y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
    }
  }

  x -= stage.offsetLeft;
  y -= stage.offsetTop;

  x = Math.min(x, gCanvasWidth * 500);
  y = Math.min(y, gCanvasHeight * 500);

  circles_count = gCircles.length + 1;

  if (gHasAttacked == false) {
    gCircles[circles_count] = new circle();
    gHasAttacked = true;
    gCircles[circles_count].init(1, 1, x, y, 5, 5);
    gCircles[circles_count].explode();
  }
}

//Checks to see if the level is complete
function levelCheck() {
  //If the correct amount of circles have exploded, advance the player
  if ((gCirclesDestroyed - 1) > (gLevel * gGameComplete)) {
    levelAdvance();
  }
  //otherwise, reset the level
  if (gCirclesDestroyed > 0) {
    levelReset();
  }

  levelTitle();
}

function levelAdvance() {
  gInitGame = false;
  gLevel = gLevel + 1;

  gHasAttacked = false;
  gCirclesDestroyed = 0;
  gCirclesDead = 0;
}

function levelTitle() {
  if (!document.getElementById('level_title')) {
    var level_text = document.createElement('div');
  }
  else {
    var level_text = document.getElementById('level_title');
  }

  level_text.innerHTML = gLevel + " Balls";
  level_text.id = 'level_title';
  stage.appendChild(level_text);
}

function levelReset() {
  gHasAttacked = false;
  gCirclesDestroyed = 0;
  gCirclesDead = 0;
  gInitGame = false;

}
