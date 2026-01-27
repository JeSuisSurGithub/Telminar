library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is port(
    clk, rst, rx, button: in std_logic;
    lcd_r: out std_logic_vector(4 downto 0);
    lcd_g: out std_logic_vector(5 downto 0);
    lcd_b: out std_logic_vector(4 downto 0);
    de, hs, vs, clk_lcd: out std_logic
);
end entity;

architecture rtl of top is
    signal clk80, clk40, rst_n: std_logic := '0';
    signal x, y: unsigned(11 downto 0);
    signal fgc, bgc: std_logic_vector(23 downto 0);
    signal ascii: unsigned(7 downto 0);
    signal data, rgb: std_logic_vector(23 downto 0);

    begin
        u_rPLL: entity work.Gowin_rPLL(Behavioral)
            port map(clkout => clk80, clkoutd => clk40, clkin => clk);

        rst_n <= not rst;

        lcd_r <= rgb(20 downto 16);
        lcd_g <= rgb(13 downto 8);
        lcd_b <= rgb(4 downto 0);

        u_lcd_tx: entity work.lcd_tx(rtl)
            port map(clk => clk40, rst_n => rst_n,
                    data => data, hs => hs, vs => vs, de => de,
                    rgb => rgb, x => x, y => y);

        u_color_ctrl: entity work.color_ctrl(rtl)
            port map(clk => clk80, rst_n => rst_n, button => button, fgc => fgc, bgc => bgc);

        u_frame_data: entity work.frame_data(rtl)
            port map(clk => clk80, rst_n => rst_n, rx => rx, x => x, y => y, ascii => ascii);
                    

        u_font_render: entity work.font_render(rtl)
            port map(clk => clk80, rst_n => rst_n, x => x, y => y, ascii => ascii, fgc => fgc, bgc => bgc, data => data);

        clk_lcd <= clk40;
    end architecture;