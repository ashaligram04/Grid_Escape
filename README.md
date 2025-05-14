# CPE 487 Final Project - Grid Escape
**By: Atharva Shaligram and Sean Anderson**

A 2D platformer game designed in VHDL and displayed on a screen using an FPGA board and VGA connector

## Project Overview

The goal of this project was to create a 2D platformer game using a Nexys A7 board and VGA display. The project replicated common game mechanics from platformer games such as movement, collision detection, and attacking.

### Gameplay Win

### Gameplay Lose

### Main Aspects of Grid Escape:

#### Map Creation:

- The start of the game generates and displays the map, player, and enemies (purple ghosts) on the screen.

- Brick wall boundaries are created with staircases, mushrooms, and a flag at the end.

#### Player Movement:

- Four buttons are the inputs for the player movement, which are BTNL to move left, BTNR to move right, BTNU to jump, and BTNC to attack.

- Gravity is always factored in for the player, so player can fall off platforms if there are open areas.

#### Collision Detection:

- Collision detection dictates player movement.

## Expected Behavior

- When the game loads in, a map and player is generated and displayed on the screen.

  - Brick wall boundaries are created, with staircases, mushrooms, and a flag at end.

  - Purple ghosts are hovering over platforms.

- Player moves around the map

## Required Hardware
For the game to work, you will need the following:
- Nexys A7-100T FPGA Board
  
  <img src="Images/nexys_a7_100t.png" alt="Nexys A7-100T Board" width="300"/>
  
- Micro USB cable
  
  <img src="Images/micro_usb_cable.png" alt="Micro USB Cable" width="300"/>
  
- VGA Cable
  
  <img src="Images/vga_cable.jpg" alt="VGA Cable" width="300"/>
  
- Monitor with VGA Port
  
  <img src="Images/monitor.png" alt="Monitor" width="300"/>
  
- AMD Vivado™ Design Suite

## Setup
Download the following files from the repository to your computer:

Once you have downloaded the files, follow these steps:
1. Open **AMD Vivado™ Design Suite** and create a new RTL project called _Grid Escape_ in Vivado Quick Start
2. In the "Add Sources" section, click on "Add Files" and add all of the `.vhd` files from this repository
3. In the "Add Constraints" section, click on "Add Files" and add the `.xdc` file from this repository
4. In the "Default Part" section, click on "Boards" and find and choose the Neyxs A7-100T board
5. Click "Finish" in the New Project Summary page
6. Run Synthesis
7. Run Implementation
8. Generate Bitstream
9. Connect the Nexys A7-100T board to the computer using the Micro USB cable and switch the power ON
10. Connect the VGA cable from the Nexys A7-100T board to the VGA monitor
11. Open Hardware Manager
     - "Open Target"
     - "Auto Connect"
     - "Program Device"
12. Program should appear on the screen

## Module Hierarchy

![module](/Images/module.jpg)

## Inputs and Outputs

### `Game_Main.vhd`
```
ENTITY Game_Main IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA outputs
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        btnl : IN STD_LOGIC;
        btnr : IN STD_LOGIC;
        btnc : IN STD_LOGIC;
        btnd : IN STD_LOGIC;
        btnu : IN STD_LOGIC;
        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of four 7-seg displays
        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    ); 
END Game_Main;
```

#### Inputs
 - clk_in: System clock
 - btnl: Left Button, used to move left
 - btnr: Right Button, used to move right
 - btnc: Center Button, used to attack/unalive enemies
 - btnd: Down Button, used to reset the game
 - btnu: Up Button, used to jump
#### Outputs
 - VGA_red: Controls red output to VGA screen
 - VGA_green: Controls green output to VGA screen
 - VGA_blue: Controls blue output to VGA screen
 - VGA_hsync: Horizontal sync signal for VGA display
 - VGA_vsync: Vertical sync signal for VGA display
 - SEG7_anode: Controls the anodes of the 7-segment display
 - SEG7_seg: Controls the segments of the 7-segment display


## Modifications

## Conclusion

### Responsibilities

### Timeline of Work Completed

### Difficulties 

