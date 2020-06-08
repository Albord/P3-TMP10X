/*
	Autor: Albert Espiña Rojas
	Modulo: I2C_SLAVE_ALERT

*/

module I2C_SLAVE_ALERT(Clk, Rst, Alert, Temperature_In, OS, R10, F10, POL, TM, SD, Data, alertcounter);
	
	input wire Clk;//Reloj del dispositivo
	input wire Rst;//Estado para activar el dispositivo

	input wire OS, POL, TM, SD;
	input wire [1:0] F10, R10;
	/*El OS si está en 1, solo se obtendrá un dato de temperatura, si no
	habrá nuevos datos de temperatura continuamente
	El pol es unregistro para indicar cual es el valor por defecto de la alerta
	El TM 0 si estamos en el modo comprar, 1 en la interrupción de la alerta
	Si es 1, este modulo queda inactivo
	El F10 es un registro de 2 bits para indicar cuantos excesos de temperatura consecutivos necesitamos 
	Y el R10 modifica la resolución del dato, si está a 11 el dato es de 12 bits, si esta a 00 de 9
	*/
	

	input wire [11:0]Temperature_In;//Dato de la temperatura que nos está llegando
	output integer alertcounter = 0;//Contador para registrar cuantas alertas seguidas tenemos
	output wire Alert;//Bit para indicar al master que hay una alerta de temperatura
	reg HaveAlert = 1'b0;//Valor de la alerta previo a las configuraciónes con TM y POL
	output wire [15:0]Data;
	wire [15:0] continuedata;
	reg [15:0] oneshotdata;
	//el continuedata y el oneshot son para guardar los datos 
	//y escoger si queremos datos continuamente o solo uno

//assignamos continuamente el valor de la temperatura al continuedata
//dependiendo de la resolución y si está el sd, el dato es 0

//realizamos una and con el R10 para así eliminar los bits de menos peso y quitar resolución al dato
assign continuedata[15:0] = (SD) ? 0 : {4'b0000, Temperature_In[11:0] & {9'b111111111,  R10}};

always @(posedge OS) begin//si se produce un flanco de subida en el OS, cargamos un dato del one shot nuevo
	oneshotdata <= {4'b0000, Temperature_In[11:0] && {9'b111111111,  R10}};
end

assign Data = (OS) ? oneshotdata : continuedata;//con el os seleccionamos el dato que queremos
//Con el Pol conectado a una xor, podemos decidir si invertir el dato o no
//Si no hay alerta, y el pol está desactivado, el valor que tendrá alert será el estado alto
assign Alert = ( !SD &&(HaveAlert ^^ POL) ) ? 1'b0 : 1'bz;

always @(posedge OS) begin//si se produce un flanco de subida en el OS, cargamos un dato del one shot nuevo
	oneshotdata[11:0] = Temperature_In[11:0];
end

always @(posedge Clk or negedge Rst) begin//flanco de subida para el sistema de la alerta
	if (!Rst || SD ) begin //Si se produce un reset reiniciamos el sistema
		HaveAlert <= 0;
		alertcounter <= 0;
	end //si está puesto el modo persistente, aunque la temperatura vuelva normal
	else if (TM && !Alert) alertcounter <= alertcounter;//se sigue manteniendo el valor de la alerta
	else begin
		//Si la temperatura es más alta que 80º o más baja que -80º aprox
		//Incrementamos el alertcounter
		if (Temperature_In[10:8] == 3'b111) alertcounter <= alertcounter+1;
		else alertcounter <= 0;
	end
end
always @(alertcounter) begin
	case (F10)//En caso de que el incremento del contador de alertas aumente
	2'b00://dependiendo del valor de f1 o f0 se dará el aviso 
		if (alertcounter) HaveAlert = 1'b1;
	2'b01: 
		if (alertcounter >= 2) HaveAlert = 1'b1;
	2'b10: 
		if (alertcounter >= 4) HaveAlert = 1'b1;
	2'b11: 
		if (alertcounter >= 6) HaveAlert = 1'b1;
	endcase
end
		
endmodule