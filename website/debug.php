<?php

require_once('polyline_encoder/class.polylineEncoder.php');
require_once('where.php');

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <title>Where am I? debug</title>
  </head>
  <body>
	<div id="title"><p><h1>ba . aa . am / there . i . am</h1></p>
	</div>
	<div id="body">
		<?= getHistoryDebugFor("uhguide", "ecito"); ?>
	</div>
  </body>
</html>
