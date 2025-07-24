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

control_unit.v
Decodifica o opcode e gera sinais de controle para o datapath.
*/


module control_unit(
    input [5:0] opcode,
    // Sinais de saída
    output reg reg_dst,
    output reg branch,
    output reg bne,
    output reg mem_read,
    output reg mem_to_reg,
    output reg [1:0] alu_op,
    output reg mem_write,
    output reg alu_src,
    output reg reg_write,
    output reg jump,
    output reg ext_zero
);
    // Parâmetros para Opcodes (para legibilidade)
    parameter OP_R_TYPE = 6'b000000;
    parameter OP_J      = 6'b000010;
    parameter OP_JAL    = 6'b000011;
    parameter OP_BEQ    = 6'b000100;
    parameter OP_BNE    = 6'b000101;
    parameter OP_ADDI   = 6'b001000;
    parameter OP_SLTI   = 6'b001010;
    parameter OP_SLTIU  = 6'b001011;
    parameter OP_ANDI   = 6'b001100;
    parameter OP_ORI    = 6'b001101;
    parameter OP_XORI   = 6'b001110;
    parameter OP_LUI    = 6'b001111;
    parameter OP_LW     = 6'b100011;
    parameter OP_SW     = 6'b101011;
    
    always @(*) begin
        // Valores padrão (para instrução NOP ou desconhecida)
        reg_dst        = 1'b0;
        branch         = 1'b0;
        bne            = 1'b0;
        mem_read       = 1'b0;
        mem_to_reg     = 1'b0;
        alu_op         = 2'b00;
        mem_write      = 1'b0;
        alu_src        = 1'b0;
        reg_write      = 1'b0;
        jump           = 1'b0;
        ext_zero       = 1'b0;

        case(opcode)
            OP_R_TYPE: begin
                reg_dst        = 1'b1;
                reg_write      = 1'b1;
                alu_op         = 2'b10;
            end
                
            OP_LW: begin
                alu_src        = 1'b1;
                mem_to_reg     = 1'b1;
                reg_write      = 1'b1;
                mem_read       = 1'b1;
                alu_op         = 2'b00;
            end

            OP_SW: begin
                alu_src        = 1'b1;
                mem_write      = 1'b1;
                alu_op         = 2'b00;
            end
        
            OP_BEQ: begin
                branch         = 1'b1;
                alu_op         = 2'b01;
            end

            OP_BNE: begin
                bne            = 1'b1;
                alu_op         = 2'b01;
            end

            OP_ADDI: begin
                alu_src        = 1'b1;
                reg_write      = 1'b1;
                alu_op         = 2'b00;
            end

            OP_SLTI: begin
                alu_src        = 1'b1;
                reg_write      = 1'b1;
                alu_op         = 2'b11;
            end
            
            OP_SLTIU: begin
                alu_src        = 1'b1;
                reg_write      = 1'b1;
                ext_zero       = 1'b1;
                alu_op         = 2'b11;
            end

            OP_ANDI: begin
                alu_src        = 1'b1;
                reg_write      = 1'b1;
                ext_zero       = 1'b1;
                alu_op         = 2'b11;
            end                

            OP_ORI: begin
                alu_src        = 1'b1;
                reg_write      = 1'b1;
                ext_zero       = 1'b1;
                alu_op         = 2'b11;
            end

            OP_XORI: begin
                alu_src        = 1'b1;
                reg_write      = 1'b1;
                ext_zero       = 1'b1;
                alu_op         = 2'b11;
            end

            OP_LUI: begin
                alu_src        = 1'b1;
                reg_write      = 1'b1;
                alu_op         = 2'b11;
            end

            OP_J: begin
                jump           = 1'b1;
            end

            OP_JAL: begin
                reg_write      = 1'b1;
                jump           = 1'b1;
            end          
        endcase
    end
endmodule
