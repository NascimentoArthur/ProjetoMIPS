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

ula.v
Executa operações aritméticas/lógicas.
*/


module ula(
    input [31:0] a,
    input [31:0] b,
    input [3:0] op,
    output reg [31:0] result,
    output zero
);
    // Definição dos códigos de operação
    parameter ADD  = 4'b0000;
    parameter SUB  = 4'b0001;
    parameter AND  = 4'b0010;
    parameter OR   = 4'b0011;
    parameter XOR  = 4'b0100;
    parameter NOR  = 4'b0101;
    parameter SLT  = 4'b0110;
    parameter SLTU = 4'b0111;
    parameter SLL  = 4'b1000;
    parameter SRL  = 4'b1001;
    parameter SRA  = 4'b1010;
    parameter LUI  = 4'b1011;
    
    // A flag 'zero' é acionada se o resultado da operação for 0.
    // Essencial para instruções de branch (BEQ, BNE).
    assign zero = (result == 32'b0);
    
    always @(*) begin
        case(op)
            ADD:  result = a + b;
            SUB:  result = a - b;
            AND:  result = a & b;
            OR:   result = a | b;
            XOR:  result = a ^ b;
            NOR:  result = ~(a | b);
            SLT:  result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            SLTU: result = (a < b) ? 32'd1 : 32'd0;
            // Para shifts, 'a' é a quantidade de shift (pode ser shamt ou reg[rs]) e 'b' é o dado (reg[rt])
            SLL:  result = b << a[4:0];
            SRL:  result = b >> a[4:0];
            SRA:  result = $signed(b) >>> a[4:0];
            LUI:  result = {b[15:0], 16'b0}; // b é o imediato
            default: result = 32'hxxxxxxxx; // Propaga X se a operação for desconhecida
        endcase
    end
endmodule
