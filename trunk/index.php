<?php

error_reporting(E_ALL);
echo "<pre>";

$imdb_url = "http://imdb.com/title/tt0352376/";
//$imdb_url = "http://imdb.com/title/tt0272152/";

if(!$handle = fopen($imdb_url, "r"))
  die("ERROR: Konnte keine Verbindung zu " . $imdb_url . " herstellen!");


while(!feof($handle))
{
  $buffer = fgets($handle, 1024);

  // Titel und Jahr
  if(preg_match('/(class="title">)(.*)<.*">(\d+)<\/a.*$/Ui', $buffer, $matches))
  {
    $title = $matches[2];
    $year  = $matches[3];
  }

  // Genres
	global $arr_genres;
  if(preg_match('/(.*Sections\/Genres\/.*>(.*)<\/a>)+.*$/Ui', $buffer, $matches))
  {
    $arr_genres_match =  explode(' / ', $matches[0]);
		foreach ($arr_genres_match as $row)
		{
			if(preg_match('/>(\w+)<.*$/Ui', $row, $matches))
				$arr_genres[] = $matches[1];
		}
  }


}

echo "<h2>$title</h2><strong>Jahr: </strong>$year<br><br>";
echo "<strong>Genres: </strong>";
foreach ($arr_genres as $i => $genre)
{
	echo $genre . ($i != (count($arr_genres) - 1)  ? ', ' : '.<br><br>');
}


fclose($handle);

?>
