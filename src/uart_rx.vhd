library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is port(
    clk, rst_n, rx: in std_logic;
    data: out std_logic_vector(7 downto 0);
    ready: out std_logic
);
end entity;

architecture rtl of uart_rx is
    constant CLKS_PER_BIT: integer := 2083;
    signal clk_count: integer := 0;

    type state_t is (IDLE, START, RECV, STOP);
    signal state: state_t:= IDLE;
    signal bit_cnt: integer := 0;
    signal data_r: std_logic_vector(7 downto 0) := (others => '0');
    signal ready_r: std_logic := '0';
    begin
        data <= data_r;
        ready <= ready_r;

        process(clk, rst_n) begin
            if rst_n = '0' then
                clk_count <= 0;
                state <= IDLE;
                bit_cnt <= 0;
                data_r <= (others => '0');
                ready_r <= '0';
            elsif rising_edge(clk) then
                case state is
                    when IDLE =>
                        if rx = '0' then
                            clk_count <= 0;
                            state <= START;
                        end if;
                    when START =>
                        if clk_count < CLKS_PER_BIT/2 then
                            clk_count <= clk_count + 1;
                        else
                            clk_count <= 0;
                            state <= RECV;
                            bit_cnt <= 0;
                            data_r <= (others => '0');
                            ready_r <= '0';
                        end if;
                    when RECV =>
                        if clk_count < CLKS_PER_BIT then
                            clk_count <= clk_count + 1;
                        else
                            clk_count <= 0;
                            data_r(bit_cnt) <= rx;
                            if bit_cnt < 7 then
                                bit_cnt <= bit_cnt + 1;
                            else
                                state <= STOP;
                            end if;
                        end if;
                    when STOP =>
                        if clk_count < CLKS_PER_BIT then
                            clk_count <= clk_count + 1;
                        else
                            clk_count <= 0;
                            state <= IDLE;
                            ready_r <= '1';
                        end if;
                    when others => null;
                end case;
            end if;
        end process;
    end architecture;