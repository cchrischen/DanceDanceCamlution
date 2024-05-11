# Dance Dance Camlution
Dance Dance Camlution (DDC) is a rhythm game written in OCaml. Given a song, a random sequence of notes are generated, aligning to the beat of the song. The notes fall down and your goal is to hit them in time. 

## Gameplay
Clone this repo and download the dependencies. A more detailed guide can be found [here](https://github.com/cchrischen/DanceDanceCamlution/blob/main/INSTALL.md). 

There are four columns from which the notes, designated as orange blocks, can fall from. When a note is on the light part of the column, such that the top of the note aligns with the white line, hit the corresponding keybind. By default, D, F, J, and K are the keybinds for the four columns, in left to right order. These bindings can be changed in the settings menu.

A combo, representing your streak of notes hit, is indicated on the bottom right corner. This affects how many points you get per note hit. The total points you have is displayed on the top right.

At the end of a song, your accuracy of notes hit is displayed.

## Adjustments
* If you find the difficulty too hard, navigate to `lib/constants/ml`, change `diff` to your liking. `diff` is inversely proportional to how many notes will fall.
* The four keybinds for the columns and the pause button can be changed to any alphanumeric keyboard key. Do not bind two buttons to the same key.
* If you want to play this with any audio file, place the file in `data/music`.

## Contributors

* Chris Chen (cc2785)
* Daniel Xie (dyx2)
* Nam Anh Dang (nd433)
* Shubham Mohole (sam588)
* Rishi Yennu (rry9)
