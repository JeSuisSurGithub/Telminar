library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity font_render is port(
    clk: in std_logic;
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

    begin
        pixel_x_in_char <= x(2 downto 0);
        pixel_y_in_char <= y(2 downto 0);
        data <= color;

        u_font_rom: entity work.font_rom
            port map(
                clk => clk,
                char_code => ascii,
                x => pixel_x_in_char,
                y => pixel_y_in_char,
                pixel => pix_bit
            );

        process(clk) begin
            if rising_edge(clk) then
                if pix_bit = '1' then
                    color <= fgc;
                else
                    color <= bgc;
                end if;
            end if;
        end process;
    end architecture;