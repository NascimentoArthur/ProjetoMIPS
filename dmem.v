/*UFRPE - Universidade Federal Rural de Pernambuco
Licenciatura em Computação - Noite
Disciplina: Arquitetura e Organização de Computadores
Professor: Vitor Coutinho

2ª VERIFICAÇÃO DE APRENDIZAGEM (2 VA)

Nome do grupo:
Arthur Henrique Nascimento
Jeniffer Cavalcanti de Oliveira
Luciana Gonçalves
Maria Luiza Cavalcanti

dmem.v
Função: Armazena dados em uma RAM (leituras assíncronas, escritas síncronas).
*/



module dmem(
    input clk,
    input mem_read,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output [31:0] read_data
);
    reg [31:0] mem [0:63];
    integer i;
    
    initial begin
        for (i = 0; i < 64; i = i + 1)
            mem[i] = 32'b0;
    end
    
    assign read_data = mem_read ? mem[address[7:2]] : 32'bz;
    
    always @(posedge clk) begin
        if (mem_write) begin
            mem[address[7:2]] <= write_data;
            $display("[MEM WRITE] @%h = %h", address, write_data);
        end
    end
endmodule