library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cas_unit is
    generic (
        WIDTH : integer := 9
    );
    port (
        a   : in  std_logic_vector(WIDTH-1 downto 0); -- 9-bit signed input (Remainder)
        b   : in  std_logic_vector(WIDTH-1 downto 0); -- 9-bit signed input (supposed to be positive)
        sub : in  std_logic;                          -- Sub control bit (active low). Equivalent to the sign bit. If sign bit is 0, then subtract, else add.
        res : out std_logic_vector(WIDTH-1 downto 0)  -- 9-bit signed ouput
    );
end entity cas_unit;

architecture behavioral of cas_unit is
begin
    process(a, b, sub)
        variable a_signed : signed(WIDTH-1 downto 0);
        variable b_signed : signed(WIDTH-1 downto 0);
    begin
        a_signed := signed(a);
        b_signed := signed(b);
        
        if sub = '0' then
            res <= std_logic_vector(a_signed - b_signed);
        else
            res <= std_logic_vector(a_signed + b_signed);
        end if;
    end process;
end architecture behavioral;