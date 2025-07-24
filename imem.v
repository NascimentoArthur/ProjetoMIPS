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

imem.v
Função: Memória de Instruções (ROM). Carrega o programa a partir
de um arquivo externo 'instructions.list'.
*/

module imem(
    input [31:0] address,
    output [31:0] instruction
);
    // Memória com 256 palavras de 32 bits (1KB)
    // Aumentei o tamanho para garantir que o programa de teste caiba.
    reg [31:0] mem [0:255];
    
    initial begin
        // Carrega o programa a partir do arquivo 'instructions.list'
        // O arquivo deve estar no diretório de simulação.
        $readmemb("instructions.list", mem);
    end
    
    // Acesso à memória. O endereço do PC é em bytes.
    // Dividimos por 4 para obter o índice da palavra (word).
    // Ex: Endereço 0x00 -> índice 0. Endereço 0x04 -> índice 1.
    assign instruction = mem[address[9:2]];
endmodule
