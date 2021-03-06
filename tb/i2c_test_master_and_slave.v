`timescale 1 ns / 1 ns


module testbench();


parameter ADDRESSLENGTH = 8;//ADDRESSLENGTH ES EL TAMA�O DE LA DIRECCI�N DEL ESCLAV
parameter ADDRESSNUM = 1;//ADDRESSNUM, EL N�MERO DE DIRECCI�NES QUE POSEE EL ESCLAVO, EST� FIJADA A
parameter NBYTES = 2;//NBYTES ES EL N�MERO DE BYTES QUE CONTIENE LA MEMORIA DEL ESCLAVO POR DIRECCI�
	
reg Start = 1'b0;//Variable para iniciar la solicitud de una nueva transferencia
reg Clk = 1'b0;//Reloj externo, con este reloj se generar� el Scl
reg RST = 1'b1;//Reset activo con estado bajo
wire SDA;//Pin de datos entre el maestro y los esclavos
wire SCL;//Pin de reloj entre el maestro y el esclavo
reg RorW = 1'b0;//En estado 1 estamos indicando que vamos a enviar datos al esclavo, en estado 0 que esperamos recibir


wire [3:0] NBytes = 4'b0010; //n�mero de bytes que va haber en cada transferencia
wire [7:0]DataToSlave = 8'b00110011;//Datos que van a ser enviados al slave
wire [7:0]DataFromSlave;//Datos que han sido enviados por el slave

wire slave_state;//Estado del esclavo
wire start;//Registro para activar la comunicaci�n etre la memoria y la unidad de control

pullup (SDA); //COLOCAMOS EL PULLUP AL SDA Y AL SCL PARA QUE EN CASO DE QUE NADIE UTILICE EL PIN, EST� POR DEFECTO EN 1
pullup (SCL); 

wire [7:0] Configurator_Register; //Registro con las configuraciones del sensor
wire [11:0]Temperature_In = 12'b110011001100; //Dato de la temperatura generado
integer AlertCounter; //Contador de clks que ha habido exceso de temperatura
wire Alert; //Senyal de alerta para estado bajo

pullup (Alert);

//Modulo de temperatura
I2C_TMP10X slave(SDA, SCL, Alert, Temperature_In, AlertCounter, Configurator_Register);

I2C_MASTER#( ADDRESSLENGTH) master(Clk, RST, Start, SDA, SCL, RorW, Slave_Address, NBytes, DataToSlave, DataFromSlave, state);

initial begin
#20;
RST = 1'b0;//Hacemos un reset inicial
RorW = 1'b1;//Ponemos la transferencia en modo env�o de datos al esclavo
#20;
RST = 1'b1;//Desactivamos el reset puede operar con normalidad
#10;
Start = 1'b1;//Indicamos al maestro que puead empezar con la transferencia de datos
#1000;//Esperamos un tiempo para ver como se desarrolla 
//Hacemos un test de lectura
#20;
RST = 1'b0;//Hacemos el mismo procedimiento anterior
#20
RorW = 1'b0;
#20;
RST = 1'b1;
#1000;
$stop;

end
initial begin //Generamos el reloj
	Clk = 0;
end
always #10 Clk = ~Clk;


endmodule

