library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd_tx is port(
    clk, rst_n: in std_logic;
    data: in std_logic_vector(23 downto 0);
    hs, vs, de: out std_logic;
    rgb: out std_logic_vector(23 downto 0);
    x, y: out unsigned(11 downto 0)
);
end entity;

architecture rtl of lcd_tx is
    constant H_SYNC: integer := 10;
    constant H_BACK: integer := 46;
    constant H_DISP: integer := 800;
    constant H_FRONT: integer := 210;
    constant H_TOTAL: integer := 1066;

    constant V_SYNC: integer := 4;
    constant V_BACK: integer := 23;
    constant V_DISP: integer := 480;
    constant V_FRONT: integer := 13;
    constant V_TOTAL: integer := 520;

    signal de_r: std_logic;
    signal hcpt, vcpt: unsigned(11 downto 0) := (others => '0');

    begin
        hs <= '0' when (hcpt <= H_SYNC - 1) else '1';
        vs <= '0' when (vcpt <= V_SYNC - 1) else '1';

        de_r <= '1' when ((hcpt >= H_SYNC + H_BACK) and (hcpt < H_SYNC + H_BACK + H_DISP)
                    and (vcpt >= V_SYNC + V_BACK) and (vcpt < V_SYNC + V_BACK + V_DISP)) else '0';
        de <= de_r;

        rgb <= data when (de_r = '1') else (others => '0');

        x <= (hcpt - (H_SYNC + H_BACK)) when (de_r = '1') else (others => '0');
        y <= (vcpt - (V_SYNC + V_BACK)) when (de_r = '1') else (others => '0');

        
        process(clk, rst_n) begin
            if rst_n = '0' then
                hcpt <= (others => '0');
                vcpt <= (others => '0');
            elsif rising_edge(clk) then
                if hcpt < H_TOTAL - 1 then
                    hcpt <= hcpt + 1;
                else
                    hcpt <= (others => '0');
                    if vcpt < V_TOTAL - 1  then
                        vcpt <= vcpt + 1;
                    else
                        vcpt <= (others => '0');
                    end if;
                end if;
            end if;
        end process;
    end architecture;