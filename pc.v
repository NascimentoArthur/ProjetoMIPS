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


pc.v
Armazena o endereço da próxima instrução a ser executada (PC = Program Counter). Atualizado a cada ciclo de clock ou reset.
*/


module pc(
    input clk,
    input reset,
    input [31:0] next_pc,
    output reg [31:0] current_pc
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_pc <= 32'h00000000;
        else
            current_pc <= next_pc;
    end
endmodule