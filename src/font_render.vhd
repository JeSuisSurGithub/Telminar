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
    signal color: std_logic_vector(23 downto 0);

    signal p_addr: std_logic_vector(10 downto 0);
    signal p_dout: std_logic_vector(7 downto 0);

    signal pix_bit: std_logic;

    begin
        bmp_x <= x(2 downto 0);
        bmp_y <= y(2 downto 0);
        data <= color;

        p_addr <= std_logic_vector(unsigned(ascii & bmp_y));

        u_pROM: entity work.Gowin_pROM
            port map (
                dout => p_dout, clk => clk,
                oce => '1', ce => '1', reset => '0', ad => p_addr);

        pix_bit <= p_dout(to_integer(bmp_x - 2)); -- Bad fix ????

        process(clk, rst_n) begin
            if rst_n = '0' then
                color <= (others => '0');
            elsif rising_edge(clk) then
                if pix_bit = '1' then
                    color <= fgc;
                else
                    color <= bgc;
                end if;
            end if;
        end process;
    end architecture;