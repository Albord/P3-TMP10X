//`timescale 1 ns / 1 ps


module testbench_slave();
reg sys_clk, rstn;

parameter ADDRESSLENGTH = 8;
parameter ADDRESSNUM = 2;
parameter NBYTES = 2;


reg Enable = 1'b0;
reg Mode = 1'b1;
reg RorW = 1'b1;
reg [ADDRESSLENGTH-1: 0] DirectionBuffer = 8'b00001111;
reg AddressFound = 1'b0;
reg [8*NBYTES*ADDRESSNUM: 0 ]Data;
reg [7:0]OutputBuffer;
wire [7:0]InputBuffer = 8'b0;
wire [((ADDRESSLENGTH)*ADDRESSNUM) - 1: 0]AddressList = 24'b000011110000111000011000;



 	

pullup (SDA); 
pullup (SCLK); 

I2C_SLAVE_MEMORY #( ADDRESSLENGTH, ADDRESSNUM, NBYTES) i2c_slave_memory(Enable, Mode, RorW, DirectionBuffer, InputBuffer, OutputBuffer, AddressFound, AddressList, Data);






initial begin
#10;
Enable = 1'b1;
#10;

#10;
end




endmodule

