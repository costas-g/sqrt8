library ieee;
use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

entity sqrt8_logic is
    generic (
        -- Stage index (4 to 1) to control positional logic
        STAGE_ID : integer := 4; 
        WIDTH_R  : integer := 9;
        WIDTH_Q  : integer := 4
    );
    port (
        R_in  : in  std_logic_vector(WIDTH_R-1 downto 0); -- 9-bit signed input Remainder
        Q_in  : in  std_logic_vector(WIDTH_Q-1 downto 0); -- 4-bit unsigned Quotient
        R_out : out std_logic_vector(WIDTH_R-1 downto 0)  -- 9-bit signed output Remainder
    );
end entity sqrt8_logic;

architecture behavioral of sqrt8_logic is
    signal T_s : std_logic_vector(WIDTH_R-1 downto 0);
    signal Q_s : std_logic_vector(WIDTH_Q downto 0);
    signal sub_control : std_logic;
begin

    -- Zero-extend Q_in to avoid null-range in the first stage
    Q_s <= '0' & Q_in;

    process(Q_s, R_in)
        -- Indices calculated 
        constant UP_LIM : integer := STAGE_ID + WIDTH_Q;
        constant LO_LIM : integer := 2 * STAGE_ID;
        constant Q_HI   : integer := WIDTH_Q;
        constant Q_LO   : integer := STAGE_ID;
    begin
        -- Default value: all zeros
        T_s <= (others => '0');

        -- Overwrite specific bits
        T_s(UP_LIM downto LO_LIM) <= Q_s(Q_HI downto Q_LO);
        T_s(LO_LIM-1) <= R_in(WIDTH_R-1);
        T_s(LO_LIM-2) <= '1';
    end process;

    -- Arithmetic Core
    sub_control <= not R_in(WIDTH_R-1); -- the sign bit controls the CAS unit
    
    CAS_INST : entity work.cas_unit
        generic map (WIDTH => WIDTH_R)
        port map (
            a   => R_in,
            b   => T_s,
            sub => sub_control,
            res => R_out
        );

end architecture behavioral;