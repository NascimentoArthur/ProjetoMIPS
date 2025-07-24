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

mips_top.v (Top-Level)
Função: Integra todos os módulos e controla o fluxo de dados.
*/

module Projeto2(
    input clk,
    input reset,
    output [31:0] pc_out,
    output [31:0] alu_result_out,
    output [31:0] mem_read_data_out
);
    // =================================================================
    // Sinais e Wires Internos
    // =================================================================
    // -- Sinais do Caminho de Dados --
    wire [31:0] next_pc, pc_plus_4;
    wire [31:0] instruction;
    wire [31:0] read_data1, read_data2, write_data_to_reg;
    wire [31:0] final_imm;
    wire [4:0]  write_reg_addr;
    wire [3:0]  alu_control_op;
    wire        zero_flag;
    wire [31:0] ula_input_a, ula_input_b;
    wire [31:0] branch_target_addr;
    wire [31:0] jump_target_addr;
    wire        branch_condition_met;

    // =================================================================
    // Sinais de Controle
    // =================================================================
    // -- Sinais gerados pela Unidade de Controle Principal --
    wire reg_dst, branch, bne, mem_read, mem_to_reg;
    wire mem_write, alu_src, reg_write, jump, ext_zero;
    wire [1:0] alu_op;
    
    // -- Sinais gerados pela Unidade de Controle da ULA --
    wire jump_register, alu_a_is_shamt;
    
    // Opcodes para legibilidade
    parameter OP_JAL = 6'b000011;
    
    // Registrador $ra
    parameter JAL_REG = 5'b11111;

    // =================================================================
    // Instanciação dos Módulos (Datapath)
    // =================================================================

    // Estágio 1: Busca da Instrução (Instruction Fetch)
    // -------------------------------------------------
    // O PC armazena o endereço da instrução atual e é atualizado a cada ciclo.
    pc program_counter (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .current_pc(pc_out)
    );
    
    // A memória de instruções (ROM) fornece a instrução apontada pelo PC.
    imem instruction_memory (
        .address(pc_out),
        .instruction(instruction)
    );
    
    // Estágio 2: Decodificação e Leitura dos Registradores (Decode)
    // -------------------------------------------------------------
    // O banco de registradores lê os valores de rs e rt.
    regfile register_file (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .read_reg1(instruction[25:21]), // rs
        .read_reg2(instruction[20:16]), // rt
        .write_reg(write_reg_addr),
        .write_data(write_data_to_reg),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
    
    // A unidade de controle principal decodifica o opcode para gerar os sinais de controle.
    control_unit control (
        .opcode(instruction[31:26]),
        .reg_dst(reg_dst),
        .branch(branch),
        .bne(bne),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump),
        .ext_zero(ext_zero)
    );

    // O extensor de sinal converte o imediato de 16 bits para 32 bits.
    sign_extend sign_ext_inst (
        .imm(instruction[15:0]),
        .ext_zero(ext_zero),
        .extended(final_imm)
    );

    // Estágio 3: Execução (Execute)
    // -----------------------------
    // O controle da ULA decodifica o funct (para tipo-R) e gera a operação final da ULA.
    ula_control alu_control_unit (
        .alu_op(alu_op),
        .funct(instruction[5:0]),
        .opcode(instruction[31:26]),
        .alu_control(alu_control_op),
        .jump_register(jump_register),
        .alu_a_is_shamt(alu_a_is_shamt)
    );
    
    // A ULA realiza a operação aritmética ou lógica.
    ula alu (
        .a(ula_input_a),
        .b(ula_input_b),
        .op(alu_control_op),
        .result(alu_result_out),
        .zero(zero_flag)
    );
    
    // Estágio 4: Acesso à Memória (Memory)
    // ------------------------------------
    // A memória de dados é lida (lw) ou escrita (sw).
    dmem data_memory (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result_out),
        .write_data(read_data2),
        .read_data(mem_read_data_out)
    );

    // =================================================================
    // Lógica do Datapath (Muxes e Conexões)
    // =================================================================

    // MUX 1: Seleciona a primeira entrada da ULA.
    // Pode ser o valor do registrador 'rs' ou o campo 'shamt' para instruções de shift.
    assign ula_input_a = alu_a_is_shamt ? {27'b0, instruction[10:6]} : read_data1;

    // MUX 2: Seleciona a segunda entrada da ULA.
    // Pode ser o valor do registrador 'rt' ou o imediato estendido.
    assign ula_input_b = alu_src ? final_imm : read_data2;

    // MUX 3: Seleciona o registrador de destino para a escrita.
    // Para tipo-R é 'rd', para tipo-I é 'rt', e para JAL é sempre $ra (31).
    assign write_reg_addr = (instruction[31:26] == OP_JAL) ? JAL_REG :
                           reg_dst ? instruction[15:11] :
                           instruction[20:16];

    // MUX 4: Seleciona o dado a ser escrito de volta no banco de registradores.
    // Pode ser o resultado da ULA, um dado lido da memória (lw) ou o PC+4 (jal).
    assign write_data_to_reg = (instruction[31:26] == OP_JAL) ? pc_plus_4 :
                              mem_to_reg ? mem_read_data_out :
                              alu_result_out;

    // =================================================================
    // Lógica de Cálculo do Próximo PC
    // =================================================================
    // Cálculo dos possíveis próximos endereços.
    assign pc_plus_4 = pc_out + 4;
    assign branch_target_addr = pc_plus_4 + (final_imm << 2);
    assign jump_target_addr = {pc_plus_4[31:28], instruction[25:0], 2'b00};

    // Determina se a condição de desvio (BEQ ou BNE) foi satisfeita.
    assign branch_condition_met = (branch & zero_flag) | (bne & ~zero_flag);

    // MUX final para selecionar o próximo PC, com a seguinte prioridade:
    // 1. JR (salto para endereço em um registrador)
    // 2. J / JAL (salto incondicional)
    // 3. BEQ / BNE (desvio condicional, se a condição for satisfeita)
    // 4. PC + 4 (caso padrão, para execução sequencial)
    assign next_pc = jump_register ? read_data1 :
                     jump ? jump_target_addr :
                     branch_condition_met ? branch_target_addr :
                     pc_plus_4;

endmodule
