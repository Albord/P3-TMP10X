/*
	Autor: Albert Espi�a Rojas
	Modulo: I2C_SLAVE_UC

*/

module I2C_SLAVE_UC #( parameter ADDRESSLENGTH)(Sda, Scl, HaveAddress, DirectionBuffer, InputBuffer, OutputBuffer, RorW);
	inout Sda;//Pin de datos entre el maestro y los esclavos
	input wire Scl;//Pin de reloj entre el maestro y el esclavo
	input HaveAddress;//Input de la memoria para indicar que el dispositivo tiene la direcci�n de memoria solicitada
	output reg [(ADDRESSLENGTH-1): 0] DirectionBuffer; //Buffer para guardar la direcci�n que solicita el master
	output reg [7:0]InputBuffer; //Bufer donde ir�n todos los datos guardadosa a la memoria
	input wire [7:0]OutputBuffer;// Buffer donde ir�n todos los datos recibidos
	output reg RorW = 1'b0;//En estado 1 estamos indicando que vamos a enviar datos al esclavo, en estado 0 que esperamos recibir
	reg state = 1'b0;//Estado 0 cuando el master est� solicitando conexi�n. Estado 1, cuando hay transferencia
	reg MemoryEnable = 1'b0; //Registro para activar la comunicaci�n etre la memoria y la unidad de control
	reg start = 1'b0;//Estado para activar el dispositivo slave
	integer Counter = 1'b0;//Contador de los bits del Sda, 
	reg sda_intern = 1'b1;//para que no haya conflictos con el sda tenemos un sda interno

	

assign Sda = ( sda_intern ) ? 1'bz : 1'b0;//Si sda es 0 asignamos el valor, si no, no modifcamos el valor del sda

	
always @(negedge Sda) begin //Condici�n de start
	if (Scl) begin 
		Counter <= 0;//Colocamos todas las variables por defecto
		start <= 1'b1;//Activamos el slave
		state <= 1'b0;
		RorW <= 1'b0;
		MemoryEnable <= 1'b0;
	end
end
always @(posedge Sda) begin //Condici�n de stop
	if (Scl) start <= 1'b0;//Si se produce desactivamos el slave
end
always @(posedge Scl) begin
	if (start) begin
		if (state) begin //estado de transferencia de datos
			if (Counter < 8) begin//las transferencias son de byte a byte, por lo tanto hay que tener el contador tambi�n
				if (RorW) InputBuffer[Counter] <= Sda; //guardamos el dato en el buffer ya que estamos recibiendo
				Counter <= Counter + 1;	
				MemoryEnable <= 0;//Como guardamos los datos en el buffer de 8 en 8 bits no es necesaria tenerla activada
			end
			if (Counter == 8) begin //fin del byte de datos, hay que mirar si hemos recibido un ack
				if (!RorW) MemoryEnable <= !Sda; //Si tenemos un 0 es un ack y por lo tanto podemos pedir el siguiente dato
				else MemoryEnable <= 1;//cuando recibimos datos, siempre lo guardamos en la memoria, ya que confirma el slave
				Counter <= 0;	
			end
		
		end
		else begin//estado 0 estamos solicitando conexi�n
			if (Counter < ADDRESSLENGTH) begin //Recibiendo los datos de la direcci�n de memoria
				DirectionBuffer[Counter] <= Sda;//guardamos el dato del sda en el buffer con las direcciones
				Counter <= Counter + 1;
			end
			else if (Counter == ADDRESSLENGTH) begin //Al siguiente ciclo el master especificar� si la transferencia es read or write
				RorW <= Sda;
				Counter <= Counter + 1;
			end 
			else if ((Counter == ADDRESSLENGTH + 1) && HaveAddress) begin //si tenemos la direcci�n que solicita el master
				Counter <= 0;
				if (!RorW) MemoryEnable <= 1;//si se va a enviar los datos, cargamos la memoria de manera previa
				state <= 1'b1;
			end 
			else begin
				Counter <= 0;
				start <= 0; //En caso de que la transferencia no sea con este dispositivo, lo desactivamos
			end
		end
	end
end

always @(negedge Scl) begin
/*
	El flanco de bajada del clock est� destinado para que el slave env�e datos a trav�s del Sda, cuando sea necesario
*/
	sda_intern <= 1;//ponemos el sda a 1 por defecto
	if (state) begin
		//En este caso enviamos r�fagas de 8 bits y esperamos a recibir el ack si estamos escribiendo
		if (Counter < 8 && !RorW) sda_intern <= OutputBuffer[Counter];
		 //fin del byte de datos, hay enviar o recibir un ack y de paso guardamos el buffer en la memoria
		else if (Counter == 8 && RorW) sda_intern <= 1'b0;//modo lectura, enviamos nosotros un ack
	end
	else begin
		//ack para indicar que este eslavo tiene la direcci�n de memoria solicitada, esto se ejecuta antes que el pasar de estado
		if (Counter == ADDRESSLENGTH + 1 && HaveAddress) sda_intern <= 1'b0;
	end
end
endmodule