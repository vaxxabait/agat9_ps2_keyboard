//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
// (C) COPYRIGHT 2012 Michael Tulupov

// File:            agat9_keyboard.sv
// Author:          Michael Tulupov

// Description:     Model of the Agat-9 keyboard
// Language:        SystemVerilog (1800-2009)

// Path:            $HeadURL: $
// Date:            $Date: $
// Revision:        $Revision: $
// Last changes by: $Author: $
// ID:              $Id: $

// Dependencies:

// Parameters:

// Constraints:

// Keywords:

// Notes:
//			This model was ripped off from the schematic in the original documentation.
//			The copy of the documentation was obtained from http://deka18.tsk.ru/er/agat/Reading/docs/Keyboard-adj-LO.djvu

// TODO:
//		Add check of VDD/GND levels before vork
//		Add timings
//--------------------------------------------------------------------------------------------//

`timescale 1ns/1ns


///////////////////////////////////////////////
// IC models


// 7474 series, "xxxxТМ2" RU - two D flip-flops with set and reset
// _tm2 (.Sn(), .C(), .D(), .Rn(), Q(), .Qn());

module _tm2(
		input Sn, // set (active low)
		input Rn, // reset (active low)
		input C, // clock
		input D, // data

		output reg Q, // direct output
		output reg Qn // inverted output
	);
	
	always@(posedge C, negedge Sn, negedge Rn)
		if (~Sn) begin
			Q <= 1'b1;
			Qn <= 1'b0;
		end
		else if (~Rn) begin
			Q <= 1'b0;
			Qn <= 1'b1;
		end
		else begin
			Q <= D;
			Qn <= ~D;
		end
endmodule


// 7493  К155ИЕ5 4-х разрядный двоичный счетчик 
// _ie5 (.C1(), .C2(), ._and(), .RO(), .Q());
module _ie5(
		input C1, // clock for fastest flop
		input C2, // clock for other flops
		input _and, RO, // resets (must be used both in parallel)
		output reg [3:0] Q
	);

	// fast flop (C1)
	always@(posedge C1, posedge _and, posedge RO)
		if (_and&RO) Q[0] <= 1'b0;
		else Q[0] <= ~Q[0];

	// slow flops (C2)
	always@(posedge C2, posedge _and, posedge RO)
		if (_and&RO) Q[3:1] <= 3'b0;
		else Q[3:1] <= Q[3:1] + 1'b1;

endmodule


// 7497 К155ИЕ8 6-и разрядный двоичный сч. с перем. коэф. делен
// _ie8 (.V(), .R(), .C(), .T(), .Vnum(), .C1(), .Q(), .Qn());
module _ie8(
		input V, // enable (active low)
		input R, // reset
		input C, // clock
		input T, // strobe
		input C1, // cascade
input [5:0] Vnum, // division rate
		output P, // count enable output
		output /*6, Y*/ Q, // cascaded output
		output /*5, Z*/ Qn // main output
	);

endmodule


// 7495 К155ИР1 4-х разрядный универсальный сдвигающий регистр
// _ir1 (.C1(), .C2(), .V1(), .V2(), .D(), .Q());
module _ir1(
	input C1, C2, V1, V2,
	input [3:0] D,
	output [3:0] Q
	);
endmodule

// 74155 К155ИД4 сдвоенный дешифратор "2 входа- 4 выхода" 
module _id4(
	input S1, D, A, B, E, S2,
	output [7:0] Qn
	);
endmodule

// 74LS253 К555КП12 
module _kp12(
	input S1, A, B, S2,
	input [3:0] D, E,
	output D_, E_
	);
endmodule

// 74LS251 К555КП15
module _kp15(
	input X1,
	input [7:0] X2_9,
	input [2:0] X10_12,
	output Qn
	);
endmodule



///////////////////////////////////////////////
// Single key model

module _key(
	input pressed, // 1 - key pressed, 0 - key open
	input I,
	output Q
	);

	assign Q = pressed ? I : 1'b1;		// with pull-up
	//assign Q = pressed ? I : 1'bx;	// just key
endmodule



///////////////////////////////////////////////
// Keyboard model

module agat9_keyboard(

		// Connector "X1"

		// Pad name		// Pin number	// Original name (RU)	// Function
		inout DVDD5,		// 1		// "+5B"		// +5V power supply input
		inout DGND,		// 2		// "Общий"		// ground
		input reply_tape,	// 3		// "Ответ"		// transfer enable (AGAT-7) / TTL-level output to tape for manufacturing control, not used for keyboard (AGAT-9)
		
		output key_data,	// 4		// "Данные"		// data
		output reset,		// 5		// "Сброс"		// reset
		input clock,		// 6		// "Гкл"		// clock
		output rus_lat,		// 7		// "Р/Л"		// Russian or Latin

		// LEDs
		
	);
	

	///////////////////////////////////////////////
	// Common definitions
	
	wire gndi = scb[2]; // internal ground
	wire [67:1] scb; 	// Bus on the schematic
	
	// Keys
	wire [77:1] kb_keys;
	// Key codes from 1 to 77 (inderscore is special symbol):
	// ПЯРСТУЖВЬЫЗШЭЩЧЪ_ЮАБЦДЕФГХИЙКЛМНО__123456789:;<=>?__________123456789_.=_____
	// PQRSTUVWXYZ[\]^ _DABCDEFGHIJKLMNO__!"#_%&'()*+,-./___________________________



	///////////////////////////////////////////////
	// X1 connection to schematic bus

	assign scb[1] = 1'b1; // DVDD5
	assign scb[2] = 1'b0; // DGND
	assign scb[3] = reply_tape;
	assign key_data = scb[4]; 
	assign reset = scb[5];
	assign scb[65] = clock;
	assign rus_lat = scb[66];



	///////////////////////////////////////////////
	// Logic

	assign /*D1_1*/scb[67] = ~(scb[1]|gndi);
	assign /*D3_1,D3_4*/scb[5] = ~(scb[67]&scb[34]);


	wire D2_3;
	wire D2_2 = ~(scb[65]&scb[34]);
	wire D4_2_Qn;
	_tm2 D4_2(.Sn(scb[34]), .C(D2_2), .D(D4_2_Qn), .Rn(D2_3), Q(), .Qn(D4_2_Qn));
	wire D20_2_Qn;
	_tm2 D20_2(.Sn(scb[34]), .C(D4_2_Qn), .D(D20_2_Qn), .Rn(D2_3), Q(), .Qn(D20_2_Qn));
	wire D2_4;
	wire D11_Q12;
	_ie5 D11(.C1(D20_2_Qn), .C2(D2_4), ._and(gndi), .RO(gndi), .Q({scb[8:6],D11_Q12}));
	

	wire D7_Q;
	assign D2_3 = ~(scb[29]&D7_Q);
	assign /*D1_4*/scb[80] = ~(D2_2|D2_3);
	assign D2_4 = ~(scb[80]&scb[64]);
	_ie5 D12(.C1(scb[11]), .C2(scb[8]), ._and(gndi), .RO(gndi), .Q({scb[11:9],scb[12]}));
	

	wire D4_1_Qn;
	_tm2 D4_1(.Sn(scb[34]), .C(D11_Q12), .D(D4_1_Qn), .Rn(scb[34]), Q(), .Qn(D4_1_Qn));
	wire D7_Qn;
	wire D10_1;
	_ie8 D7(.V(gndi), .R(D10_1), .C(D4_1_Qn), .T(gndi), .Vnum({gndi,scb[34],{4{gndi}}}), .C1(scb[34]), .Q(D7_Q), .Qn(D7_Qn));
	wire D1_2;
	wire D9_1_Q, D9_1_Qn;
	_tm2 D9_1(.Sn(D1_2), .C(D7_Qn), .D(gndi), .Rn(scb[34]), Q(D9_1_Q), .Qn(D9_1_Qn));


	wire D1_3 = ~(D2_2|scb[3]);
	assign D1_2 = ~(D1_3|gndi);
	wire D2_1 = ~(D9_1_Q&D9_1_Q);
	wire D16_6 = ~D2_1;


	_ir1 D5(.C1(D1_3), .C2(D16_6), .V1(scb[34]), .V2(D9_1_Qn), .D(scb[9:12]), .Q(scb[57:60]));
	_ir1 D6(.C1(D1_3), .C2(D16_6), .V1(scb[60]), .V2(D9_1_Qn), .D({scb[56],scb[7:8],gndi}), .Q(scb[57:60]));
	
	
	
	///////////////////////////////////////////////
	// Button matrix
	// 	Includes buttons:
	// 		S1-S16, S18-S33, S35-S50, S56, S53, S55, S52, S57-S59, S61-S65, S70-S75
	// 	Matrix inputs (left to right): {scb[55:53],scb[49:51]}
	// 	Matrix outputs (top to bottom): {scb[21:28], scb[13:20]}
	// 	Matrix outputs have pull-up thru resistor line (open key means 1'b1 on output)


	_key matrix[69:0](
		.pressed({
			kb_keys[1:16],
			kb_keys[18:33],
			kb_keys[35:50],
			kb_keys[52:53],
			kb_keys[55:59],
			kb_keys[61:75]
		}),
		.I(),
		.Q({
			scb[21:28],scb[13:20],
			scb[21:28],scb[13:20],
			scb[21:28],scb[13:20],
			scb[26],scb[18],
			scb[21],scb[13:16],
			scb[21:25],scb[17:20],scb[22:27]
		})
	);


	///////////////////////////////////////////////
	// Special function buttons
	// 	Includes buttons:
	// 		S17, S34, S51, S54, S60
	
	_key S17(.pressed(kb_keys[17]), .I(), .Q());
	_key S31(.pressed(kb_keys[31]), .I(), .Q());
	_key S51(.pressed(kb_keys[51]), .I(), .Q());
	_key S54(.pressed(kb_keys[54]), .I(), .Q());
	_key S60(.pressed(kb_keys[60]), .I(), .Q());



	///////////////////////////////////////////////
	// Russian/Latin switch buttons
	// 	Includes buttons:
	// 		S76, S77


endmodule agat9_keyboard