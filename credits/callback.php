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

// TODO: Replace APP_SECRET.
$app_secret = 'APP_SECRET';

// Validate request is from Facebook.
$request = parse_signed_request($_POST['signed_request'], $app_secret);

// Get request type.
$request_type = $_POST['method'];

if ($request_type == 'payments_get_items') {
  // Step #3: Implement response to Facebook's payments_get_items
  // request to the app's Credits Callback URL.
  // https://developers.facebook.com/docs/credits/callback/#payments_get_items

  // Get order info from Pay Dialog's order_info and log.
  $order_info = json_decode($request['credits']['order_info'], true);

  // Get item id.
  $item_id = $order_info['item_id'];

  // Simlutates item lookup based on Pay Dialog's order_info.
  if ($item_id == '1a') {
    $item = array(
      'title' => '50 Critical Mass Coins',
      'description' => 'Spend coins in Critical Mass.',
      // Price must be denominated in credits.
      'price' => 1,
      'image_url' => 'http://SOME_URL/og/currency/coin.jpg',
    );

    // Construct response.
    $response = array(
                  'content' => array(
                                 0 => $item,
                               ),
                  'method' => $request_type,
                );
    // Resonse must be JSON encoded.
    $response = json_encode($response);
  }

} else if ($request_type == "payments_status_update") {
  // Step #4: Implement response to Facebook's payments_status_update
  // request to the app's Credits Callback URL.
  // https://developers.facebook.com/docs/credits/callback/#payments_status_update

  // Get order details and log.
  $order_details = json_decode($request['credits']['order_details'], true);

  // Determine if this is an earned currency order
  $item_data = json_decode($order_details['items'][0]['data'], true);
  $earned_currency_order = (isset($item_data['modified'])) ?
                             $item_data['modified'] : null;

  // Get order status
  $current_order_status = $order_details['status'];

  if ($current_order_status == 'placed') {
    // Fulfill order based on $order_details unless...

    if ($earned_currency_order) {
      // Fulfill order based on the information below...
      // URL to the application's currency webpage.
      $product = $earned_currency_order['product'];
      // Title of the application currency webpage.
      $product_title = $earned_currency_order['product_title'];
      // Amount of application currency to deposit.
      $product_amount = $earned_currency_order['product_amount'];
      // If the order is settled, the developer will receive this
      // amount of credits as payment.
      $credits_amount = $earned_currency_order['credits_amount'];
    }

    $next_order_status = 'settled';

    // Construct response.
    $response = array(
                  'content' => array(
                                 'status' => $next_order_status,
                                 'order_id' => $order_details['order_id'],
                               ),
                  'method' => $request_type,
                );
    // Response must be JSON encoded.
    $response = json_encode($response);
  }
}

// Send response and log.
echo $response;

// These methods are documented here:
// https://developers.facebook.com/docs/authentication/signed_request/
function parse_signed_request($signed_request, $secret) {
  list($encoded_sig, $payload) = explode('.', $signed_request, 2);

  // decode the data
  $sig = base64_url_decode($encoded_sig);
  $data = json_decode(base64_url_decode($payload), true);

  if (strtoupper($data['algorithm']) !== 'HMAC-SHA256') {
    error_log('Unknown algorithm. Expected HMAC-SHA256');
    return null;
  }

  // check sig
  $expected_sig = hash_hmac('sha256', $payload, $secret, $raw = true);
  if ($sig !== $expected_sig) {
    error_log('Bad Signed JSON signature!');
    return null;
  }

  return $data;
}

function base64_url_decode($input) {
  return base64_decode(strtr($input, '-_', '+/'));
}
