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

tb_mips.v (Testbench)
Função: Simula o MIPS e verifica seu comportamento.
*/



`timescale 1ns / 1ps

module tb_mips();
    reg clk, reset;
    wire [31:0] pc_out, alu_out, mem_out;
    
    // Instância do MIPS (DUT - Device Under Test)
    Projeto2 uut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .alu_result_out(alu_out),
        .mem_read_data_out(mem_out)
    );

    // Geração de clock (período de 10ns -> 100 MHz)
    always #5 clk = ~clk;

    // Variáveis de controle da simulação
    integer i;
    reg [31:0] last_pc = 32'hFFFFFFFF;
    integer timeout_cycles = 0;
    parameter TIMEOUT_LIMIT = 100;
    parameter SIMULATION_TIME_LIMIT = 5000; // 5us

    initial begin
        // Inicialização dos sinais
        clk = 0;
        reset = 1;
        
        // Configuração do dump de formas de onda (VCD)
        $dumpfile("mips_simulation.vcd");
        $dumpvars(0, tb_mips);
        
        // Aplica o reset por 20ns
        #20;
        reset = 0;
        
        $display("\n=====================================");
        $display("   INICIANDO SIMULACAO DO MIPS   ");
        $display("=====================================\n");
    end

    // Processo de monitoramento e finalização
    always @(posedge clk) begin
        if (!reset) begin
            // Mostra o estado a cada ciclo
            // $display("[Ciclo %0t] PC: %h | ALU: %h | MemData: %h", $time, pc_out, alu_out, mem_out);

            // Detecção de loop infinito (PC não muda)
            if (pc_out == last_pc) begin
                timeout_cycles = timeout_cycles + 1;
            end else begin
                timeout_cycles = 0; // Reseta o contador se o PC mudou
                last_pc = pc_out;
            end
            
            // Finaliza a simulação por timeout do PC
            if (timeout_cycles > TIMEOUT_LIMIT) begin
                $display("\n[ERRO] Timeout: PC (%h) nao mudou por %0d ciclos.", pc_out, TIMEOUT_LIMIT);
                stop_simulation();
            end
            
            // Finaliza a simulação por tempo máximo
            if ($time > SIMULATION_TIME_LIMIT) begin
                $display("\n[ERRO] Timeout: Tempo maximo de simulacao (%0d ns) atingido.", SIMULATION_TIME_LIMIT);
                stop_simulation();
            end

            // Condição de parada normal (ex: PC chega no final do código)
            if (pc_out >= 32'h00000100) begin
                $display("\n[INFO] Fim do programa de teste alcancado (PC=%h).", pc_out);
                stop_simulation();
            end
        end
    end

    // Tarefa para finalizar a simulação e mostrar resultados
    task stop_simulation;
        begin
            $display("\n=====================================");
            $display("      RESULTADOS FINAIS      ");
            $display("=====================================\n");
            $display("PC final: %h", pc_out);
            $display("Ultimo resultado da ULA: %h", alu_out);
            $display("Ultimo dado lido da memoria: %h\n", mem_out);
            
            $display("ESTADO FINAL DOS REGISTRADORES (nao-zero):");
            for (i = 1; i < 32; i = i + 1) begin
                if (uut.register_file.registers[i] !== 32'b0) begin
                    $display("  R%0d ($%s): %h", i, reg_name(i), uut.register_file.registers[i]);
                end
            end
            
            $display("\n=====================================");
            $display("      SIMULACAO FINALIZADA     ");
            $display("=====================================\n");
            $finish;
        end
    endtask

    // Função para converter número de registrador em nome (para debug)
    function [23:0] reg_name;
        input [4:0] idx;
        case(idx)
            2:  reg_name = "v0";
            3:  reg_name = "v1";
            4:  reg_name = "a0";
            8:  reg_name = "t0";
            9:  reg_name = "t1";
            10: reg_name = "t2";
            11: reg_name = "t3";
            12: reg_name = "t4";
            13: reg_name = "t5";
            14: reg_name = "t6";
            15: reg_name = "t7";
            16: reg_name = "s0";
            17: reg_name = "s1";
            18: reg_name = "s2";
            19: reg_name = "s3";
            22: reg_name = "s6";
            23: reg_name = "s7";
            25: reg_name = "t9";
            31: reg_name = "ra";
            default: reg_name = "??";
        endcase
    endfunction

endmodule
