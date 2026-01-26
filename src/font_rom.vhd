library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity font_rom is port(
    clk: in std_logic;
    char_code: in unsigned(7 downto 0);
    x, y: in  unsigned(2 downto 0);
    pixel: out std_logic
);
end entity;

architecture rtl of font_rom is
    signal p_dout: std_logic_vector(7 downto 0);
    signal p_ad: std_logic_vector(10 downto 0);
    signal p_ce: std_logic := '1';
    signal p_oce: std_logic := '1';
    signal p_reset: std_logic := '0';

    begin
        p_ad <= std_logic_vector(unsigned(char_code & y));

        u_pROM: entity work.Gowin_pROM
            port map (
                dout => p_dout, clk => clk,
                oce => p_oce, ce => p_ce, reset => p_reset, ad => p_ad);

        pixel <= p_dout(to_integer(x - 1)); -- Bad fix
    end architecture;