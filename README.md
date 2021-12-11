# ECE385_Final_Project


## How To Run the Code

### Setup

* Connect DE-10 Lite Shield to FPGA
* Connect keyboard to Shield


### Compilation Steps

* Use Quartus to compile the program and program the FPGA ("nios.qpf")
* Run the NIOS II CPU from Eclipse ("\finalproject")

### Playing

* Press F to start the game, and then press the D, F, Space, J, and K key for each respective column when a tile reaches the bottom of the screen.
* The game ends if you hit the wrong key or don't hit the key before it fully disappears.
* You have to wait until the tile reaches the bottom of the screen to press the key.
* If you get a tile with a gift box on it, that tile is worth 5 points.
* Reset on the FPGA will restart the game.