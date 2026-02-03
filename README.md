# FPGA Tetris

This repository contains a SystemVerilog implementation of a playable Tetris game for 1920 × 1080 VGA display on a Nexys A7 FPGA board. The game can be controlled by on-board buttons or an external keyboard, and also plays theme music and sound effects that are read from a SDXC card.

https://github.com/user-attachments/assets/6d8f334e-4b86-4b5f-a544-a0844a0d58a4


Below is the high-level block diagram for the system. Other than the SD controller, which requires a 25 MHz clock, all modules run on the 148.5 MHz pixel clock that’s needed for a 60 Hz refresh rate. 

<img width="950" height="442" alt="block diagram" src="https://github.com/user-attachments/assets/c49c8e8a-555c-472e-9678-c8ae0b2b3935" />

## Inputs 

The game takes in inputs from both the buttons on the board and a USB HID keyboard. The Nexys A7 board hides the keyboard’s USB HID protocol from the FPGA, instead emulating a PS/2 bus with the FPGA serving as the host. The PS/2 interface module thus synchronizes and debounces these PS/2 clock and data lines and waits to receive incoming key codes. When new data is received, it checks for the correct stop bit and data parity before signaling that new data is available.  

Decoded key signals and button signals are debounced before being passed to level-to-pulse converters that generate pulse signals for controlling the Tetris game. Variations on a basic level-to-pulse converter are used to create effects like auto-shifting and soft dropping, as well as allow some on-board buttons to be used for multiple controls based on the length of time they are pressed. 

## Game logic 

The Tetris game controller is implemented as an FSM, a simplified diagram of which is shown below.

<img width="533" height="527" alt="game state diagram" src="https://github.com/user-attachments/assets/3347f9c3-1959-459c-8967-e4777e93730b" />

The 20 × 10 playing grid is conceptualized as 200 squares, with each block occupying four squares within a moving 4 × 4 grid. The locations of a block's four squares are determined by its color, state of rotation, and the x and y position of the top-left corner of its 4 × 4 grid. 

Following modern Tetris games, the color of each newly spawned block is not generated randomly, but rather cycles through a permutation of all seven colors before starting another permutation. This effect is achieved by using a ROM with a list of 585 permutations of numbers from 1 to 7 to supply each new block color. During the START screen, the list is run through in the background so that the game starts at an effectively random point in the list each time. 

To avoid moving a block off the grid or where another block has already been placed, a "fill map" in RAM records whether a given square has been filled in by a placed block or not, with a border around the playing grid being marked as filled as well. Whenever a trigger to generate or move a block comes in, the square locations of the proposed move are determined and checked on the fill map; the move is executed only if all four squares are empty. In the case of a failed rotation, up to four more attempts at rotation are made with different x and y positions for the block, creating the [“wall kick”](https://harddrop.com/wiki/SRS) effect present in modern Tetris games. 

When a block cannot move down any further, the count starts for a 0.5 second lock delay, with the count restarting for any successful move up to a limit of 15 moves. Once a block is placed, the squares it occupies in its final position are filled in on the fill map, and the fill map is checked for full rows. A row is cleared from the grid by shifting all the squares above it down one row. 

Scoring is based on systems used in modern Tetris games, with the level increasing every 10 lines and points being awarded for line clears, combos, soft drops, and hard drops. As the level increases, the speed at which each new block falls also increases. The game is over when a new block cannot be spawned without overlapping an already placed block. 

## VGA display 

In addition to handling the game mechanics, the game FSM updates information needed for the display, including a “square map” that records the color of each square in the grid, as well as maps that record whether special effects like flashing have been activated for a given square in the grid. It also converts the score and other stats to BCD so that they can be displayed on the screen. 

These are passed to a display module that translates this information into the corresponding RGB values of the pixel output. The VGA signal generator, adapted from a version provided [here](https://web.mit.edu/6.111/volume2/www/f2019/index.html) to work for 1920 × 1080 display, provides the hcount and vcount signals that tell which pixel on the screen is being drawn. Sprite sheets of text, numbers, and other graphics stored as ROMs are read from and decoded to render the corresponding graphic. 

In some cases, multiple memories are read from to display an element, for instance with the grid, where the square map provides the color of a square and a separate pixel map provides the color of the pixel inside the square. To ensure that all elements display cleanly, the hcount signal is carefully pipelined and the signal paths for different graphics are balanced so that the number of cycles from the initial hcount signal to the pixel output is the same for all elements. 

## Audio pipeline 

During gameplay, the Tetris theme song plays on a loop in the background, and sound effects for placing blocks and clearing lines are added on top. These audios are stored as WAV files on an SDXC card that is inserted in the Nexys A7 board’s microSD slot. The SD controller module handles interfacing with the SD card and was adapted from [this implementation](https://web.mit.edu/6.111/volume2/www/f2019/tools/sd_controller.v) to be compatible with a SDXC card. Since data is read from the SD card in groups of 512 bytes at a speed that far exceeds the 44.1 kHz sampling rate of the audio files, data from the SD card is written into a FIFO so that it can be read out at the appropriate rate. 

The BGM and sound FX audio modules take in the relevant control signals from the game FSM and produce the desired audio output, loading and reloading their respective FIFOs as needed. The SD manager serves as an intermediary between these audio modules and the SD controller, making sure all requests to read from the SD card are handled and that signals passing to and from the slower clock domain of the SD controller are properly synchronized. 

The output from the two audio modules are then combined and passed to the PWM control module, which recreates the audio to be played from the board’s mono output. 
