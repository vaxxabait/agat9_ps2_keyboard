//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++//
// (C) COPYRIGHT 2012 Michael Tulupov (vaxxabait@gmail.com)

// File:            lib74xx.v
// Author:          Michael Tulupov

// Description:     Library of the 74xx device models
// Language:        Verilog (1364-2001)

// Repository:      https://github.com/vaxxabait/agat9_ps2_keyboard/

// Dependencies:

// Parameters:

// Constraints:

// Keywords:

// Notes:

// TODO:
//		Add check of VDD/GND levels before vork
//		Add timings
//--------------------------------------------------------------------------------------------//

`timescale 1ns/1ns


///////////////////////////////////////////////
//
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



///////////////////////////////////////////////
//
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



///////////////////////////////////////////////
//
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



///////////////////////////////////////////////
//
// 7495 К155ИР1 4-х разрядный универсальный сдвигающий регистр
// _ir1 (.C1(), .C2(), .V1(), .V2(), .D(), .Q());

module _ir1(
	input C1, C2, V1, V2,
	input [3:0] D,
	output [3:0] Q
	);
endmodule



///////////////////////////////////////////////
//
// 74155 К155ИД4 сдвоенный дешифратор "2 входа- 4 выхода"

module _id4(
	input S1, D, A, B, E, S2,
	output [7:0] Qn
	);
endmodule



///////////////////////////////////////////////
//
// 74LS253 К555КП12

module _kp12(
	input S1, A, B, S2,
	input [3:0] D, E,
	output D_, E_
	);
endmodule



///////////////////////////////////////////////
//
// 74LS251 К555КП15

module _kp15(
	input X1,
	input [7:0] X2_9,
	input [2:0] X10_12,
	output Qn
	);
endmodule
