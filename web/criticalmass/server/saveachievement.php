<?php
    require 'fb-php-sdk/facebook.php';

    $app_id = 'APP_ID';
    $app_secret = 'APP_SECRET';

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

    try {
      $response = $facebook->api('/' . $user . '/achievements', 'post', array(
        'achievement' => 'http://www.bitdecay.net/labs/criticalmasscomplete/server/goldmedal.php',
      ));
      print($response);
    } catch(FacebookAPIException $e) {
      error_log($e);
      print(0);
    }

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
