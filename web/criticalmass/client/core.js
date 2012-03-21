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
}

function BlockMove(event) {
  // Tell Safari not to move the window.
  event.preventDefault() ;
}
