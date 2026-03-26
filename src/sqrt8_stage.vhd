library ieee;
use ieee.std_logic_1164.all;
-- use ieee.numeric_std.all;

entity sqrt8_stage is
    generic (
        STAGE_ID : integer := 4; 
        WIDTH_R  : integer := 9;
        WIDTH_Q  : integer := 4
    );
    port (
        CLK      : in  std_logic;
        RST      : in  std_logic;
        R_in_s   : in  std_logic_vector(WIDTH_R-1 downto 0);
        Q_in_s   : in  std_logic_vector(WIDTH_Q-1 downto 0);
        R_out_s  : out std_logic_vector(WIDTH_R-1 downto 0);
        Q_out_s  : out std_logic_vector(WIDTH_Q-1 downto 0)
    );
end entity sqrt8_stage;

architecture structural of sqrt8_stage is
    signal r_comb : std_logic_vector(WIDTH_R-1 downto 0);
    signal q_next : std_logic_vector(WIDTH_Q-1 downto 0);
begin

    -- Combinational Logic Instance
    LOGIC_CORE : entity work.sqrt8_logic
        generic map (
            STAGE_ID => STAGE_ID,
            WIDTH_R  => WIDTH_R,
            WIDTH_Q  => WIDTH_Q
        )
        port map (
            R_in  => R_in_s,
            Q_in  => Q_in_s,
            R_out => r_comb
        );

    -- Quotient Bit Update Logic
    -- The new quotient bit is the inverse of the R_out sign
    process(Q_in_s, r_comb)
    begin
        q_next <= Q_in_s; -- Default: keep old bits
        -- Update the specific bit corresponding to this stage
        -- The correct bit value should be the inverse, i.e. `not r_comb(WIDTH_R-1)` 
        -- If we pass it as is, we need to correct it in the logic before the CAS unit.
        q_next(STAGE_ID - 1) <= not r_comb(WIDTH_R-1); -- Note: Possible critical path impact
    end process;

    -- Output Registers
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                R_out_s <= (others => '0');
                Q_out_s <= (others => '0'); -- '0' if storing true value, '1' if storing complementary value
            else
                R_out_s <= r_comb;
                Q_out_s <= q_next;
            end if;
        end if;
    end process;

end architecture structural;