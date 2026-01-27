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
    signal pixel_x_in_char, pixel_y_in_char: unsigned(2 downto 0);
    signal pix_bit: std_logic;
    signal color: std_logic_vector(23 downto 0);

    signal p_dout: std_logic_vector(7 downto 0);
    signal p_ad: std_logic_vector(10 downto 0);
    signal p_ce: std_logic := '1';
    signal p_oce: std_logic := '1';
    signal p_reset: std_logic := '0';

    begin
        pixel_x_in_char <= x(2 downto 0);
        pixel_y_in_char <= y(2 downto 0);
        data <= color;

        p_ad <= std_logic_vector(unsigned(ascii & pixel_y_in_char));

        u_pROM: entity work.Gowin_pROM
            port map (
                dout => p_dout, clk => clk,
                oce => p_oce, ce => p_ce, reset => p_reset, ad => p_ad);

        pix_bit <= p_dout(to_integer(pixel_x_in_char - 1)); -- Previous X

        process(clk, rst_n) begin
            if rst_n = '0' then
                color <= (others => '0');
                p_reset <= '1';
            elsif rising_edge(clk) then    
                p_reset <= '0';
                if pix_bit = '1' then
                    color <= fgc;
                else
                    color <= bgc;
                end if;
            end if;
        end process;
    end architecture;