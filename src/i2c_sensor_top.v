module I2C_TMP10X(SCL, SDA, Alert, Temperature_In, AlertCounter, Configurator_Register, Data);

parameter ADDRESSLENGTH = 7;
parameter ADDRESSNUM = 1;
parameter NBYTES = 2;


input wire [11:0]Temperature_In;

input SDA;
input SCL;
wire [((ADDRESSLENGTH)*ADDRESSNUM) - 1: 0] AddressList = 1001000; //Buffer para guardar la direcci�n que solicita el master
wire HaveAddress;
wire [(ADDRESSLENGTH-1): 0] DirectionBuffer; 
wire [7:0]InputBuffer, OutputBuffer;
wire RorW;
wire MemoryEnable;
input wire [7:0]Configurator_Register;
output wire Alert;
output integer AlertCounter;
output wire [15:0]Data;
wire state;
wire start;


I2C_SLAVE_UC #( ADDRESSLENGTH) slave_uc(SDA, SCL, HaveAddress, DirectionBuffer, InputBuffer, OutputBuffer, RorW, MemoryEnable, start, state);
I2C_SLAVE_ALERT sensor(Clk, !start, Alert, Temperature_In, Configurator_Register[7], Configurator_Register[6:5], Configurator_Register[4:3], Configurator_Register[2], Configurator_Register[1], Configurator_Register[0], Data, AlertCounter);

I2C_SLAVE_MEMORY #( ADDRESSLENGTH, ADDRESSNUM, NBYTES) slave_memory(MemoryEnable, RorW, DirectionBuffer, InputBuffer, OutputBuffer, HaveAddress, AddressList, Configurator_Register, Data);


endmodule



