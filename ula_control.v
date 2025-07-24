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

ula_control.v
Decodifica o campo funct (para instruções tipo-R) ou opcode (para tipo-I) e gera o código de operação da ULA.
*/

module ula_control(
    input [1:0] alu_op,
    input [5:0] funct,
    input [5:0] opcode, 
    output reg [3:0] alu_control,
    output reg jump_register,
    output reg alu_a_is_shamt
);
    // Parâmetros para as operações da ULA (deve ser idêntico a ula.v)
    parameter ULA_ADD  = 4'b0000;
    parameter ULA_SUB  = 4'b0001;
    parameter ULA_AND  = 4'b0010;
    parameter ULA_OR   = 4'b0011;
    parameter ULA_XOR  = 4'b0100;
    parameter ULA_NOR  = 4'b0101;
    parameter ULA_SLT  = 4'b0110;
    parameter ULA_SLTU = 4'b0111;
    parameter ULA_SLL  = 4'b1000;
    parameter ULA_SRL  = 4'b1001;
    parameter ULA_SRA  = 4'b1010;
    parameter ULA_LUI  = 4'b1011;

    // Funct codes para instruções Tipo-R
    parameter F_SLL  = 6'b000000;
    parameter F_SRL  = 6'b000010;
    parameter F_SRA  = 6'b000011;
    parameter F_SLLV = 6'b000100;
    parameter F_SRLV = 6'b000110;
    parameter F_SRAV = 6'b000111;
    parameter F_JR   = 6'b001000;
    parameter F_ADD  = 6'b100000;
    parameter F_SUB  = 6'b100010;
    parameter F_AND  = 6'b100100;
    parameter F_OR   = 6'b100101;
    parameter F_XOR  = 6'b100110;
    parameter F_NOR  = 6'b100111;
    parameter F_SLT  = 6'b101010;
    parameter F_SLTU = 6'b101011;

    // Opcodes para instruções Tipo-I
    parameter OP_ADDI  = 6'b001000;
    parameter OP_SLTI  = 6'b001010;
    parameter OP_SLTIU = 6'b001011;
    parameter OP_ANDI  = 6'b001100;
    parameter OP_ORI   = 6'b001101;
    parameter OP_XORI  = 6'b001110;
    parameter OP_LUI   = 6'b001111;

    always @(*) begin
        // Valores padrão para evitar a criação de latches
        alu_control = 4'bxxxx; // 'x' para ajudar a debugar
        jump_register = 1'b0;
        alu_a_is_shamt = 1'b0;

        case(alu_op)
            // ALUOp = 00: Usado por LW, SW, ADDI. Todos fazem uma soma.
            2'b00: begin
                alu_control = ULA_ADD;
            end
            
            // ALUOp = 01: Usado por BEQ, BNE. Ambos fazem uma subtração para comparar.
            2'b01: begin
                alu_control = ULA_SUB;
            end
            
            // ALUOp = 10: Instruções Tipo-R. Decodifica o campo 'funct'.
            2'b10: begin
                // O sinal 'alu_a_is_shamt' controla o MUX na entrada 'a' da ULA.
                // É 1 para sll, srl, sra (usa shamt) e 0 para sllv, srlv, srav (usa rs).
                alu_a_is_shamt = (funct == F_SLL || funct == F_SRL || funct == F_SRA);
                
                case(funct)
                    F_ADD:  alu_control = ULA_ADD;
                    F_SUB:  alu_control = ULA_SUB;
                    F_AND:  alu_control = ULA_AND;
                    F_OR:   alu_control = ULA_OR;
                    F_XOR:  alu_control = ULA_XOR;
                    F_NOR:  alu_control = ULA_NOR;
                    F_SLT:  alu_control = ULA_SLT;
                    F_SLTU: alu_control = ULA_SLTU;
                    F_SLL, F_SLLV:  alu_control = ULA_SLL;
                    F_SRL, F_SRLV:  alu_control = ULA_SRL;
                    F_SRA, F_SRAV:  alu_control = ULA_SRA;
                    F_JR:   begin
                        jump_register = 1'b1;
                        alu_control = 4'bxxxx; // ULA não é usada para o salto
                    end
                    default: alu_control = 4'bxxxx; // Função desconhecida
                endcase
            end
            
            // ALUOp = 11: Instruções Tipo-I (lógicas, slti, lui). Decodifica o 'opcode'.
            2'b11: begin
                 case(opcode)
                    OP_ANDI:  alu_control = ULA_AND;
                    OP_ORI:   alu_control = ULA_OR;
                    OP_XORI:  alu_control = ULA_XOR;
                    OP_SLTI:  alu_control = ULA_SLT;
                    OP_SLTIU: alu_control = ULA_SLTU;
                    OP_LUI:   alu_control = ULA_LUI;
                    default:  alu_control = 4'bxxxx; // Opcode desconhecido
                 endcase
            end
            
            default: alu_control = 4'bxxxx; // alu_op desconhecido
        endcase
    end
endmodule
