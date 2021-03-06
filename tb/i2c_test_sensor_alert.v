`timescale 1 ns / 1 ns


module testbench_sensor();


reg Start = 1'b0;//Variable para iniciar la solicitud de una nueva transferencia
reg Clk = 1'b0;//Reloj externo, con este reloj se generar� el Scl
wire SDA;//Pin de datos entre el maestro y los esclavos
wire SCL;//Pin de reloj entre el maestro y el esclavo
reg RST = 1'b1;

wire slave_state;//Estado del esclavo
wire start;//Registro para activar la comunicaci�n etre la memoria y la unidad de control

pullup (SDA); //COLOCAMOS EL PULLUP AL SDA Y AL SCL PARA QUE EN CASO DE QUE NADIE UTILICE EL PIN, EST� POR DEFECTO EN 1
pullup (SCL); 


wire [11:0]Temperature_In = 12'b1111111111; //Dato de la temperatura generado
wire [7:0] AlertCounter; //Contador de clks que ha habido exceso de temperatura
wire Alert; //Se�al de alerta para estado bajo
reg [7:0] Configurator_Register;
pullup (Alert);
wire [15:0]Data; //dato a enviar al master
//Modulo de temperatura
I2C_SLAVE_ALERT sensor(Clk, RST, Alert, Temperature_In, Configurator_Register[7], Configurator_Register[6:5], Configurator_Register[4:3], Configurator_Register[2], Configurator_Register[1], Configurator_Register[0], Data, AlertCounter);

initial begin
#20;
RST = 1'b0;//Hacemos un reset inicial

Configurator_Register = 8'b00001011;

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

