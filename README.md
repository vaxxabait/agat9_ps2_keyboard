agat9_ps2_keyboard
==================

Adapter for connecting PS2 keyboard to AGAT-9 computer (Soviet Apple-II clone)

Planned features:

    1. Should be powered from AGAT-9 keyboard port - no external power
    2. Special combinations for special keys like CTRL-ALT-DEL or POWER -> reset, user selectable
    3. Two layouts for latin - QWERTY and JCUKEN, selectable
    4. Rus/Lat switch by selectable combination, indication by selectable LED
    5. NUMLOCK handling with appropriate keymap changes
    6. Tab to spaces (user select.)
    7. Programmable keystrokes for non-AGAT keys
    8. Save current settings in MSP430 EEPROM. Use LED as indicators.
    9. AGAt9/AGAT7 compatibility
    10. Show tape output on AGAT9 as LED bargraph or toggle
    11. LED flash after turn on as a greeting.


TODO:

    1. Create a Verilog model of keyboard using original schematic
	to better understand the protocol and to make experiments

    2. Create TI MSP430 LaunchPad sketch with reduced functions for test
	a. PS2 to UART
	b. UART to AGAT9

    3. Create a PCB for an adapter in KiCAD
	a. create schematic symbols and PCB patterns
	b. create schematic
	c. create board layout

    4. Create MSP firmware in C


FUTURE:

    1. USB host for HID keyboards ?
