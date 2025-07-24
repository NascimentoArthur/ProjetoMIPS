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

sign_extend.v
Função: Estende um valor imediato de 16 bits para 32 bits, com ou sem sinal.
*/


module sign_extend(
    input [15:0] imm,
    input ext_zero, // 1 = extensão zero, 0 = extensão de sinal
    output [31:0] extended
);
    assign extended = ext_zero ? {16'b0, imm} : {{16{imm[15]}}, imm};
endmodule