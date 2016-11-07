<?php

$i = imagecreatefrompng('smlurlm.png');

for ($char_y_offset=0; $char_y_offset<=6; $char_y_offset++) {
  for ($char_x_offset=0; $char_x_offset<=9; $char_x_offset++) {
    for ($char_y=0; $char_y<=7; $char_y++) {
      echo '  byte #%';
      for ($char_x=0; $char_x<=7; $char_x++) {
        echo imagecolorat($i,$char_x_offset*8+$char_x,$char_y_offset*8+$char_y);
      }
      echo "\r\n";
    }
    echo "\r\n";
  }
}
