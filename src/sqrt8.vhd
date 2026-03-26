library ieee;
use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

entity sqrt8 is
    generic (
        WIDTH_DATA_IN  : integer := 8;
        WIDTH_DATA_OUT : integer := 4;
        NUM_STAGES     : integer := 4
    );
    port (
        CLK         : in  std_logic;
        RST         : in  std_logic;
        INPUT_DATA  : in  std_logic_vector(WIDTH_DATA_IN-1 downto 0);
        INPUT_VLD   : in  std_logic;
        OUTPUT_DATA : out std_logic_vector(WIDTH_DATA_OUT-1 downto 0);
        OUTPUT_VLD  : out std_logic
    );
end entity sqrt8;

architecture structural of sqrt8 is
    -- Data Arrays for the 4-stage pipeline
    type r_array is array (NUM_STAGES downto 0) of std_logic_vector(WIDTH_DATA_IN downto 0);
    type q_array is array (NUM_STAGES downto 0) of std_logic_vector(WIDTH_DATA_OUT-1 downto 0);
    
    -- Internal signals. Will synthesize as Registers for saving intermediate results.
    signal r_pipe : r_array;
    signal q_pipe : q_array;

    -- Valid signal shift register (4 stages of latency)
    signal vld_pipe : std_logic_vector(NUM_STAGES downto 0);
begin

    -- Stage 4 Input Initialization
    q_pipe(NUM_STAGES) <= (others => '0');  -- Initial Quotient is "0000" if using true value, "1111" otherwise.

    -- Generate the 4 Pipeline Stages (4 down to 1)
    GEN_PIPE: for k in NUM_STAGES downto 1 generate
        STAGE_INST: entity work.sqrt8_stage
            generic map (
                STAGE_ID => k,
                WIDTH_R  => WIDTH_DATA_IN+1,
                WIDTH_Q  => WIDTH_DATA_OUT
            )
            port map (
                CLK      => CLK,
                RST      => RST,
                R_in_s   => r_pipe(k),
                Q_in_s   => q_pipe(k),
                R_out_s  => r_pipe(k-1),
                Q_out_s  => q_pipe(k-1)
            );
    end generate;
    
    -- Registers Pipeline (R, Q, VLD)
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                r_pipe (NUM_STAGES) <= (others => '0'); -- only reset the input register, the rest is handled by the bottom unit
                vld_pipe(NUM_STAGES downto 0) <= (others => '0');
            else
                r_pipe(NUM_STAGES) <= '0' & INPUT_DATA; -- update the input register
                vld_pipe(NUM_STAGES downto 0) <= INPUT_VLD & vld_pipe(NUM_STAGES downto 1); -- shift the valid bit through the stages
            end if;
        end if;
    end process;

    -- Final Output Mapping
    OUTPUT_DATA <= q_pipe(0);
    OUTPUT_VLD  <= vld_pipe(0);

end architecture structural;