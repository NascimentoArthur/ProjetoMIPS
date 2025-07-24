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


regfile.v
Armazena 32 registradores de 32 bits. Suporta:
- Leitura assíncrona de 2 registradores (rs e rt).
- Escrita síncrona em 1 registrador (rd ou rt).
*/



module regfile(
    input clk,
    input reset,
    input reg_write,
    input [4:0] read_reg1,
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [31:0] write_data,
    output [31:0] read_data1,
    output [31:0] read_data2
);
    reg [31:0] registers [0:31];
    integer i;  // Declaração fora do bloco
    
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end
    
    assign read_data1 = (read_reg1 == 0) ? 32'b0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 32'b0 : registers[read_reg2];
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end
        else if (reg_write && write_reg != 0) begin
            registers[write_reg] <= write_data;
            $display("[REG WRITE] $%d = %h", write_reg, write_data);
        end
    end
endmodule