library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity color_ctrl is port(
    clk, rst_n, button: in std_logic;
    fgc, bgc: out std_logic_vector(23 downto 0)
);
end entity;

architecture rtl of color_ctrl is
    constant MAX_CPT: integer := 1600000;

    type state_t is (IDLE, TIMER);
    signal state: state_t := IDLE;

    signal cpt: integer := MAX_CPT;

    type palette is array(0 to 3) of std_logic_vector(23 downto 0);
    constant fg_table: palette :=(
        0 => x"FFFFFF",
        1 => x"000000",
        2 => x"FFD090",
        3 => x"FFB9F9"
    );

    constant bg_table: palette :=(
        0 => x"000000",
        1 => x"FFFFFF",
        2 => x"4B0082",
        3 => x"156E5F"
    );

    signal idx: unsigned(1 downto 0) := (others => '0');

    begin
        fgc <= fg_table(to_integer(idx));
        bgc <= bg_table(to_integer(idx));

        process(clk, rst_n) begin
            if rst_n = '0' then
                state <= IDLE;
                cpt <= MAX_CPT;
                idx <= (others => '0');
            elsif rising_edge(clk) then
                case state is
                    when IDLE =>
                        cpt <= MAX_CPT;
                        if button = '1' then
                            state <= TIMER;
                            idx <= idx + 1;
                        end if;
                    when TIMER =>
                        if (cpt = 0) and (button = '0') then
                            state <= IDLE;
                        elsif cpt > 0 then
                            cpt <= cpt - 1;
                        end if;
                end case;
            end if;
        end process;

    end architecture;