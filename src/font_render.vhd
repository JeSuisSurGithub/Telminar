library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity font_render is port(
    clk, rst_n: in std_logic;
    x, y: in unsigned(11 downto 0);
    ascii: in unsigned(7 downto 0);
    fgc, bgc: in std_logic_vector(23 downto 0);
    data: out std_logic_vector(23 downto 0)
);
end entity;

architecture rtl of font_render is
    signal bmp_x, bmp_y: unsigned(2 downto 0);

    signal p_addr: std_logic_vector(10 downto 0);
    signal p_dout: std_logic_vector(7 downto 0);

    signal pix_bit: std_logic;

    begin
        data <= fgc when pix_bit='1' else bgc;

        bmp_x <= resize(x - 2, 3); -- weird FIX
        bmp_y <= resize(y, 3);

        p_addr <= std_logic_vector((unsigned(ascii & bmp_y)) mod 2048);
        pix_bit <= p_dout(to_integer(bmp_x));

        u_pROM: entity work.Gowin_pROM
            port map (
                dout => p_dout, clk => clk,
                oce => '1', ce => '1', reset => '0', ad => p_addr);

        process(clk, rst_n) begin
            if rst_n = '0' then
            elsif rising_edge(clk) then
            end if;
        end process;
    end architecture;