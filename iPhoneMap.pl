#!/usr/bin/perl
#
# iPhoneMap, based on iPhoneTracker by Alasdair Allan and Pete Warden (http://petewarden.github.com/iPhoneTracker/)
#
# Written by Bojan Zdrnja (bojan.isc@gmail.com), 2011-04-22

use DBI;
use POSIX;

my $totalcount = 0;

my %hashstore;

my $outfile = "index.html";

if ( scalar(@ARGV) != 2 ) {
	print "iPhoneMap for Linux, written by Bojan Zdrnja (bojan.isc\@gmail.com).\n";
	print "Based on iPhoneTracker by Alasdair Allan and Pete Warden (http://petewarden.github.com/iPhoneTracker/)\n";
	print "Usage:\n\n";
	print "./iPhoneMap <device_name> <db_file_name>\n\n";
	print "device_name\t= your iPhone's name that will be shown on the map\n";
	print "db_file_name\t= SQLite DB name, use find_sqlite.py to find it\n\n";
	exit 1;
}

my $iphone = $ARGV[0];
my $db = $ARGV[1];

open(my $fh, '>', $outfile) or die $!;

$dbh = DBI->connect("dbi:SQLite:dbname=$db", "", "", { RaiseError => 1, AutoCommit => 0 });

my $select = $dbh->selectall_arrayref("SELECT Timestamp, Latitude, Longitude FROM CellLocation;");

print "iPhoneMap for Linux, written by Bojan Zdrnja (bojan.isc\@gmail.com).\n";
print "Based on iPhoneTracker by Alasdair Allan and Pete Warden (http://petewarden.github.com/iPhoneTracker/)\n\n";

foreach $row ( @$select ) {
	($timestamp, $latitude, $longitude) = @$row;

	if ( $latitude == 0.0 && $longitude == 0.0 ) {
		next;
	}

	$totalcount++;

	$unixTimestamp = 978285600 + $timestamp;
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($unixTimestamp);

	$real_year = $year + 1900;

	$mapDate = sprintf("%s-%02d-%02d", $real_year, $mon, $mday);

	$latitude = floor($latitude*250)/250;
	$longitude = floor($longitude*250)/250;

	$pos = "$latitude:$longitude:$mapDate";

	if ( not exists	$hashstore{$pos} ) {
		$hashstore{$pos} = 1;
	}
	else {
		$hashstore{$pos}++;
	}

	$pos_alltime = "$latitude:$longitude:All Time";

        if ( not exists $hashstore{$pos_alltime} ) {
                $hashstore{$pos_alltime} = 1;
        }
        else {
                $hashstore{$pos_alltime}++;
        }

}

if ( $totalcount == 0 ) {
	print "Could not read/parse any entries, exiting.\n";
	exit 1;
}

print $fh <<EOF;
<html>
<head>
<link rel="stylesheet" type="text/css" href="http://static.openheatmap.com/css/mainstyle.css"/>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js" type="text/javascript"></script>
<script type="text/javascript" src="http://static.openheatmap.com/scripts/jquery.openheatmap.js"></script>
<script type='text/javascript'>

g_mapSettings = {
  "zoom_slider_power":5,
  "zoomed_out_degrees_per_pixel":-180,
  "zoomed_in_degrees_per_pixel":-0.01,
  "is_gradient_value_range_set":"false",
  "gradient_value_min":"1",
  "gradient_value_max":"14",
  "point_blob_radius":8.32,
  "point_blob_value":1,
  "show_map_tiles":true,
  "map_server_root":"http:\/\/a.tile.openstreetmap.org\/",
  "information_alpha":0.92,
  "show_zoom":true,
  "allow_pan":true,
  "point_drawing_shape":"circle",
  "circle_line_color":0,
  "circle_line_alpha":1,
  "circle_line_thickness":1,
  "is_point_blob_radius_in_pixels":true,
  "credit_text": "OpenStreetMap/OpenHeatMap",
};

\$(document).ready(function() {

  \$('#openheatmap_container').insertOpenHeatMap({
    width: 1000,
    height: 720,
    prefer: 'canvas'
  });
});

function onMapCreated() {
  var openHeatMap = \$.getOpenHeatMap();

  for (var key in g_mapSettings) {
    var value = g_mapSettings[key];
    openHeatMap.setSetting(key, value);
  }

  openHeatMap.setColorGradient(["#eaf8b800","#eae40f16","#4f2d00dd"]);

  g_isMapCreated = true;

  if (g_csvString!=null) {
    loadLocationData();
  }
}
EOF

print $fh "\n";
print $fh "var g_deviceName = \"myIphone\";\n";
print $fh "var g_csvString = \"lat,lon,value,time";

foreach $key ( keys %hashstore ) {

	$count = $hashstore{$key};
	@result = split(/:/, $key);
	
	$finalstring = $result[0] . "," . $result[1] . "," . $count . "," . $result[2];

	print $fh "\\n";
	print $fh $finalstring;

}

print $fh "\";\n\n";

print $fh <<EOF;
function loadLocationData() {
  var openHeatMap = \$.getOpenHeatMap();

  openHeatMap.loadValuesFromCSVString(g_csvString);
  \$('#message').text(g_deviceName);

  openHeatMap.setAnimationTime('All Time');
}

</script>
</head>
<body style="margin:0px; padding:0px; position:relative;">
<div id="openheatmap_container" style="margin:0px; padding:0px;"></div>
<div id="message" style="position:absolute; top:20px; left:0px; width: 1000px; text-align:center; font-size:200%;">
Loading  <img src="http://static.openheatmap.com/images/loading.gif"/>
</div>
</body>
</html>
EOF

close($fh);

print "Done, processed $totalcount location entries.\n";
print "Now open index.html in your favourite browser and enjoy.\n";
exit 0;

