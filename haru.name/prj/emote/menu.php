<div id="banner">
<?php
	srand(time());
	$random = (rand() % 4);
	switch($random){
		case 0:	
			print("<div id=\"logo\"><center><img class=\"logo\" src=\"images/sadness_banner.jpg\" /></center></div>");
			break;
		case 1:	
			print("<div id=\"logo\"><center><img class=\"logo\" src=\"images/anger_banner.jpg\" /></center></div>");
			break;
		case 2:	
			print("<div id=\"logo\"><center><img class=\"logo\" src=\"images/joy_banner.jpg\" /></center></div>");
			break;
		case 3:	
			print("<div id=\"logo\"><center><img class=\"logo\" src=\"images/basic_banner.jpg\" /></center></div>");
			break;
	}
 ?>
    <div id="navigation">
	 		<center>
           <ul id="navlist">
              <li><a href="./index.php">Home</a></li>
              <li><a href="./concept.php">Concept</a></li>
              <li><a href="./description.php">Description</a></li>
              <li><a href="./inspiration.php">Inspiration</a></li>
              <li><a href="./budget.php">Budget/Schedule</a></li>
              <li><a href="./credits.php">Credits</a></li>
          </ul>
			</center>
    </div>
</div>
