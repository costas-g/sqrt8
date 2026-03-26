library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sqrt8 is
end entity tb_sqrt8;

architecture sim of tb_sqrt8 is
    -- Constants
    constant CLK_PERIOD : time    := 4 ns;
    constant W_DI       : integer := 8;
    constant W_DO       : integer := 4;
    
    -- data signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal input_data  : std_logic_vector(W_DI-1 downto 0) := (others => '0');
    signal input_vld   : std_logic := '0';
    signal output_data : std_logic_vector(W_DO-1 downto 0);
    signal output_vld  : std_logic;
    
    -- Complement output data value signal
    signal output_data_bar : std_logic_vector(output_data'range);

    -- type declaration for the expected FIFO
    type data_array is array (0 to 255) of std_logic_vector(W_DO-1 downto 0);

    -- self-check signals
    signal expected_fifo : data_array;
    signal fifo_head, fifo_tail : integer := 0;
    signal error_count : integer := 0;
    signal hit_count   : integer := 0;

    -- Compute isqrt(i) for a non-negative integer input
    function compute_isqrt(i : integer) return std_logic_vector is
        variable result : integer := 0;
        variable tmp    : integer := 0;
    begin
        -- iterative approach
        for j in 0 to i loop
            if j*j <= i then
                tmp := j;
            else
                exit;
            end if;
        end loop;
        result := tmp;
        return std_logic_vector(to_unsigned(result, W_DO)); -- W_DO = output width
    end function;

begin
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

    -- Clock Process
    clock_process: process
    begin
        clk <= '1';
        wait for CLK_PERIOD / 2;
        clk <= '0';
        wait for CLK_PERIOD / 2;
    end process clock_process;    

    -- Stimulus process
    stim_proc: process
    begin
        report "Simulation started..." severity note;
        input_data <= (others => 'X');
        input_vld  <= '0';

        -- Reset system
        rst <= '1';
        wait for 100 ns; -- Wait for device Global Set/Reset signal to be deasserted
        rst <= '0';
        wait until falling_edge(clk);
        wait for CLK_PERIOD * 1; -- Wait a bit more before we start input

        report "Begin feeding input..." severity note;
        -- Feed input data
        for i in 0 to 255 loop
            -- drive input
            input_data <= std_logic_vector(to_unsigned(i, W_DI));
            input_vld  <= '1';

            -- push expected result
            expected_fifo(fifo_tail) <= compute_isqrt(i);
            fifo_tail <= fifo_tail + 1;
            wait for CLK_PERIOD;
        end loop;

        -- deassert valid after last input
        input_vld  <= '0';

        report "End feeding input." severity note;
        wait;
    end process;

    -- Self-check process
    check_proc : process(clk)
    begin
        if rising_edge(clk) then
            if output_vld = '1' then
                -- compare with the complement of the true computed value if we agree to store the complement of the true result
                if output_data /= expected_fifo(fifo_head) then
                    report "Mismatch at index " & integer'image(fifo_head)
                    severity error;
                    error_count <= error_count + 1;
                else
                    -- report "OK: index " & integer'image(fifo_head) &
                    --     " value=" & integer'image(to_integer(unsigned(output_data)))
                    -- severity note;
                    hit_count <= hit_count + 1;
                end if;

                fifo_head <= fifo_head + 1;
            end if;
        end if;
    end process;

    -- Final report
    final_report_proc : process(output_vld)
    begin
        -- output valid deasserted
        if falling_edge(output_vld) then
            report "OUTPUT VALID DEASSERTED" 
            & LF & "Inputs = " & integer'image(fifo_tail) 
            & LF & "Outputs = " & integer'image(fifo_head) 
            & LF & "Hits = " & integer'image(hit_count) 
            & LF & "Errors = " & integer'image(error_count)
            severity note;

            if error_count = 0 and hit_count = fifo_tail then
                report "TEST PASSED" severity note;
            else
                report "TEST FAILED" severity error;
            end if;
        end if;
    end process;
    
    -- Complement value of the output data signal
    output_data_bar <= not output_data;

end architecture sim;