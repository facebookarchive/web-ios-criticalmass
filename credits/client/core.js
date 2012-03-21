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

var g_init = false;
var stage;

window.onload = function () {
  setTimeout(function () {
    window.scrollTo(0, 1);
  }, 500);
}

// GO!
window.addEventListener('load', function () {
  stage = document.getElementById('stage');

  // Set the dimensions to the match the client
  // This throws off game balance, but it's just a demo ;)
  stage.style.width = (window.innerWidth - 5) + 'px';
  stage.style.height = (window.innerHeight - 5) + 'px';

}, true);

// GO in 2000ms!
window.addEventListener('load', function () {
  setTimeout(function () {
    init();
  }, 2000)
}, true);

function init() {
  createMenu();
  leaderboardInit();
}

function BlockMove(event) {
  // Tell Safari not to move the window.
  event.preventDefault() ;
}
