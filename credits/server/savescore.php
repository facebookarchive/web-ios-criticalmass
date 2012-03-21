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

<?php
    require '../fb-php-sdk/facebook.php';
    
    $app_id = '343598042347842';
    $app_secret = '88300f2ad82f10bf1232f5c1958a2780';
    $score = $_REQUEST['score'];

    $facebook = new Facebook(array(
      'appId'  => $app_id,
      'secret' => $app_secret,
    ));

    $user = $facebook->getUser();
    
    // Special condition to support iOS clients
    if(!$user && (isset($_REQUEST['uid']))) {
      $user = $_REQUEST['uid'];
    }
    
    $app_access_token = get_app_access_token($app_id, $app_secret);
    $facebook->setAccessToken($app_access_token);
    $response = $facebook->api('/' . $user . '/scores', 'post', array(
      'score' => $score,
    ));
    print($response);

    // Helper function to get an APP ACCESS TOKEN
    function get_app_access_token($app_id, $app_secret) {
      $token_url = 'https://graph.facebook.com/oauth/access_token?'
        . 'client_id=' . $app_id
        . '&client_secret=' . $app_secret
        . '&grant_type=client_credentials';

      $token_response =file_get_contents($token_url);
      $params = null;
      parse_str($token_response, $params);
      return  $params['access_token'];
    }
?>
