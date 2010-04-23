<?php

define("DEFAULTLAYER", "");
define("DEFAULTUSER", "");

require_once('polyline_encoder/class.polylineEncoder.php');
require_once('where.php');

if ($_GET['layer'] && $_GET['user']) {
	$layer = $_GET['layer']
	$user = $_GET['user'];
} else {
	$layer = constant("DEFAULTLAYER");
	$user = constant("DEFAULTUSER"));
}

$history = getHistoryFor($layer, $user);

$points = $history->points;
$lastLocation = $history->lastLocation;
$firstLocation = $history->firstLocation;
$lastTweet = $history->lastTweet;
$lastTime = date('l, M d, g:i:s T', $history->lastTime);
$firstTime = date('l, M d, g:i:s T', $history->firstTime);
$lastCheckin = " ";//$history->lastCheckin;
$lastCheckinLocation = " "; //$history->lastCheckinLocation;

$encoder = new PolylineEncoder();
$polyline = $encoder->encode($points);

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>Where am I?</title>
    <script src="http://maps.google.com/maps?file=api&amp;v=2&amp;key=ABQIAAAAGMe2HiHC2AaPasZfWHs54xSTWN0EGo_yOC-lzHNmxZ8SCh2BExQMu_eHz1yAXHBvXZC-62QI83E1Bw"></script>
    <script type="text/javascript">

    //<![CDATA[

    function load() {
      if (GBrowserIsCompatible()) {
        var map = new GMap2(document.getElementById("map"));
        map.addControl(new GLargeMapControl());
        map.addControl(new GMapTypeControl());
        map.addControl(new GScaleControl());

        map.setCenter(new GLatLng(<?= $lastLocation ?>), 11);
        var lastLocation = new GLatLng(<?= $lastLocation ?>);
		var firstLocation = new GLatLng(<?= $firstLocation ?>);
		var lastCheckinLocation = new GLatLng(<?= $lastCheckinLocation ?>);

        var encodedPolyline = new GPolyline.fromEncoded({
          color: "#FF0000",
          weight: 4,
          points: "<?= $polyline->points ?>",
          levels: "<?= $polyline->levels ?>",
          zoomFactor: <?= $polyline->zoomFactor ?>,
          numLevels: <?= $polyline->numLevels ?>
        });
	
		var lastLocationMarker = new GMarker(lastLocation);
		var firstLocationMarker = new GMarker(firstLocation);
		var lastCheckinMarker = new GMarker(lastCheckinLocation);

        GEvent.addListener(lastLocationMarker, "click", function() {
                lastLocationMarker.openInfoWindowHtml("<p><a href=\"http://twitter.com/ecito\">@ecito: <?= $lastTweet ?></a></p><p>Last updated location:<?= $lastTime ?></p> ");
        });

		GEvent.addListener(firstLocationMarker, "click", function() {    
            firstLocationMarker.openInfoWindowHtml("<p>First updated location:<?= $firstTime ?></p> ");
        });

		GEvent.addListener(lastCheckinMarker, "click", function() {    
            lastCheckinMarker.openInfoWindowHtml("<p>Venue: <?= addslashes($lastCheckin->venue->name) ?></p><p>Checked-in at: <?= $lastCheckin->created ?></p><p>Shoutout: <?= addslashes($lastCheckin->shout) ?></p>");
        });

		map.addOverlay(lastCheckinMarker);
		map.addOverlay(firstLocationMarker);
		map.addOverlay(lastLocationMarker);
        map.addOverlay(encodedPolyline);
      }
    }

    //]]>
    </script>
  </head>
  <body onload="load()" onunload="GUnload()" style="width:98%">
	<div id="title"><p><h1>baa . aa . am / there . i . am</h1><h5>and . there . ive . been</h5></p>
			<p><h5><a href="http://twitter.com/ecito">@ecito</a>
				 / 
				<a href="http://twitter.com/4Lou">@4Lou</a>
				</h5></p>
				
	</div>
    <div id="map" style="width:100%;height:600px;center"></div>
	<div id="footer">
			<p><ul>               
			 	<li><a href="http://simplegeo.com">SimpleGeo storage</a></li>
				<li><a href="http://github.com/simplegeo/SGClient">SimpleGeo SGClient iPhone SDK</a></li>
				<li><a href="http://help.simplegeo.com/faqs/getting-started/getting-started-with-php">PHP/PEAR SimpleGeo client tutorial</a></li>
				<li><a href="http://thenextweb.com/location/2010/04/08/iphone-40-os-includes-background-location/">iPhone OS 4.0 beta background location</a></li>
                <li><a href="http://facstaff.unca.edu/mcmcclur/GoogleMaps/EncodePolyline/">PolylineEncoder</a></li>
                <li><a href="http://code.google.com/apis/maps/">Google Maps API</a></li>
        	</ul></p>
	</div>
  </body>
</html>
