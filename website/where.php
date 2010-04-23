<?php

// If you log into SimpleGeo and click on Account you'll see 
// your OAuth token and secret.
define("APIKEY", "");
define("APISECRET", "");

// set the path to where you installed the Services/SimpleGeo PEAR package
$path = '/home/andren/php'; 
set_include_path(get_include_path() . PATH_SEPARATOR . $path);

// Require the PEAR client library. No other requires are needed.
require_once 'Services/SimpleGeo.php';

function getHistoryFor($layer, $user) {
	$client = new Services_SimpleGeo(constant("APIKEY"), constant("APISECRET"));
	try {
		$result = $client->getHistory($layer, $user);
		$points = array();
		foreach ($result->geometries as $point) {
			array_push($points, array($point->coordinates[1], $point->coordinates[0]));	
		}
		
		$lastLocation = $points[0][0].', '.$points[0][1];
		$history->lastLocation = $lastLocation;
		$lastPoint = end($points);
		$history->firstLocation = $lastPoint[0].', '.$lastPoint[1];
		$history->firstTime = end($result->geometries)->created;
		$history->lastTime = $result->geometries[0]->created;
		$history->points = $points;
		
	} catch (Services_SimpleGeo_Exception $e) {
	    echo "ERROR: " . $e->getMessage() . " (#" . $e->getCode() . ")\n";
	}
	//twitter
	$format = 'json';
	$tweet=json_decode(file_get_contents("http://api.twitter.com/1/statuses/user_timeline/{$user}.{$format}")); 
	$history->lastTweet = $tweet[0]->text;

	//foursquare (sucky http basic auth)
	// $username = ""; // 
	// $password = ""; // remove this
	// $context = stream_context_create(array(
	//     'http' => array(
	//         'header'  => "Authorization: Basic " . base64_encode("$username:$password")
	//     )
	// ));
	// $url = "http://api.foursquare.com/v1/user.json";
	// $foursquare = json_decode(file_get_contents($url, false, $context));
	// $history->lastCheckin = $foursquare->user->checkin;
	// $history->lastCheckinLocation = $foursquare->user->checkin->venue->geolat.', '.$foursquare->user->checkin->venue->geolong;

	return $history;
}

function getHistoryDebugFor($layer, $user) {
	$client = new Services_SimpleGeo(constant("APIKEY"), constant("APISECRET"));
	try {
	//	$result = $client->deleteRecord($layer, $user);
		$result = $client->getRecord($layer, $user);
		echo "<pre>";
		print_r($result);

	} catch (Services_SimpleGeo_Exception $e) {
	    echo "ERROR: " . $e->getMessage() . " (#" . $e->getCode() . ")\n";
	}
}

?>
