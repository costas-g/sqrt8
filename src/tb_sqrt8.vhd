library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use std.env.all; -- Required for finish;

entity tb_sqrt8 is
end entity tb_sqrt8;

architecture sim of tb_sqrt8 is
    -- Constants
    constant CLK_PERIOD : time := 10 ns;
    constant W_DI        : integer := 8;
    constant W_DO        : integer := 4;
    
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal input_data  : std_logic_vector(W_DI-1 downto 0) := (others => '0');
    signal input_vld   : std_logic := '0';
    signal output_data : std_logic_vector(W_DO-1 downto 0);
    signal output_vld  : std_logic;

begin

    -- Clock Generation
    clock_process: process is
    begin
        clk <= '1';
        wait for CLK_PERIOD / 2;
        clk <= '0';
        wait for CLK_PERIOD / 2;
    end process clock_process;

    -- Device Under Test (DUT)
    dut: entity work.sqrt8
--        generic map (
--            WIDTH_DATA_IN  => W_DI,
--            WIDTH_DATA_OUT => W_DO,
--            NUM_STAGES     => W_DO
--        )
        port map (
            CLK         => clk,
            RST         => rst,
            INPUT_DATA  => input_data,
            INPUT_VLD   => input_vld,
            OUTPUT_DATA => output_data,
            OUTPUT_VLD  => output_vld
        );

    stim_proc: process
    begin
        report "Simulation started..." severity note;
        input_data <= (others => '0');
        input_vld  <= '0';

        -- Reset system
        rst <= '1';
        wait for CLK_PERIOD * 10;
        rst <= '0';
        wait until falling_edge(clk);

        -- Feed input data
        input_data <= std_logic_vector(to_unsigned(  0, W_DI)); input_vld  <= '1'; wait for CLK_PERIOD;
        input_data <= std_logic_vector(to_unsigned(  1, W_DI)); input_vld  <= '1'; wait for CLK_PERIOD;
        input_data <= std_logic_vector(to_unsigned(  2, W_DI)); input_vld  <= '1'; wait for CLK_PERIOD;
        input_data <= std_logic_vector(to_unsigned(  3, W_DI)); input_vld  <= '1'; wait for CLK_PERIOD;
        input_data <= std_logic_vector(to_unsigned(  4, W_DI)); input_vld  <= '1'; wait for CLK_PERIOD;
        input_data <= std_logic_vector(to_unsigned(  7, W_DI)); input_vld  <= '1'; wait for CLK_PERIOD;
        input_data <= std_logic_vector(to_unsigned( 15, W_DI)); input_vld  <= '1'; wait for CLK_PERIOD;
        input_data <= std_logic_vector(to_unsigned( 16, W_DI)); input_vld  <= '1'; wait for CLK_PERIOD;
        input_data <= std_logic_vector(to_unsigned(255, W_DI)); input_vld  <= '1'; wait for CLK_PERIOD;

        -- Stop valid data
        input_vld  <= '0';
        wait for CLK_PERIOD; 
        
        -- Monitor results (4-cycle latency)
        -- TODO: add a simple self-checking mechanism for each input (maybe with PROCEDURE)
        -- report "Starting result verification..." severity note;

        -- -- Check for 7 -> 2
        -- wait until rising_edge(clk);
        -- assert (output_vld = '1' and to_integer(unsigned(output_data)) = 2)
        --     report "Error: 7 should result in 2" severity error;

        -- -- Check for 80 -> 8
        -- wait until rising_edge(clk);
        -- assert (output_vld = '1' and to_integer(unsigned(output_data)) = 8)
        --     report "Error: 80 should result in 8" severity error;

        -- -- Check for 255 -> 15
        -- wait until rising_edge(clk);
        -- assert (output_vld = '1' and to_integer(unsigned(output_data)) = 15)
        --     report "Error: 255 should result in 15" severity error;

        -- -- Check that Valid goes low
        -- wait until rising_edge(clk);
        -- assert (output_vld = '0')
        --     report "Error: Output Valid should have gone low" severity error;

        -- report "All tests passed!" severity note;
        report "Simulation completed" severity note;
        wait;
        -- finish;
    end process;

end architecture sim;