library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_data is port(
    clk, rst_n, rx: in std_logic;
    x, y: in unsigned(11 downto 0);
    ascii: out unsigned(7 downto 0)
);
end entity;

architecture rtl of frame_data is
    constant H_CHARS: integer := 100;
    constant V_CHARS: integer := 60;

    signal char_x, char_y: unsigned(6 downto 0);

    type buf_t is array (0 to H_CHARS*V_CHARS-1) of std_logic_vector(7 downto 0);
    signal char_buf: buf_t;

    signal data: std_logic_vector(7 downto 0);
    signal ready: std_logic;

    type state_t is (AWAIT, CONSUME, IDLE);
    signal state: state_t := AWAIT;

    signal cursor_x, cursor_y: unsigned(6 downto 0) := (others => '0');

    begin       
        char_x <= x(9 downto 3);
        char_y <= y(9 downto 3);

        ascii <= unsigned(char_buf(to_integer(char_y)*H_CHARS + to_integer(char_x)));

        u_uart_rx: entity work.uart_rx(rtl)
            port map (clk => clk, rst_n => rst_n, rx => rx,
                    data => data, ready => ready);

        process(clk, rst_n) begin
            if rst_n = '0' then
                state <= AWAIT;
                cursor_x <= (others => '0');
                cursor_y <= (others => '0');
            elsif rising_edge(clk) then
                case state is
                    when AWAIT =>
                        if ready = '1' then
                            state <= CONSUME;
                        end if;
                    when CONSUME =>
                        case data is
                            when x"0A" =>
                                if cursor_y < V_CHARS - 1 then
                                    cursor_y <= cursor_y + 1;
                                else
                                    cursor_y <= (others => '0');
                                end if;

                            when x"0D" => cursor_x <= (others => '0');

                            when others =>
                                char_buf(to_integer(cursor_y)*H_CHARS + to_integer(cursor_x)) <= data;
                                if cursor_x < H_CHARS - 1 then
                                    cursor_x <= cursor_x + 1;
                                else
                                    cursor_x <= (others => '0');
                                    if cursor_y < V_CHARS - 1 then
                                        cursor_y <= cursor_y + 1;
                                    else
                                        cursor_y <= (others => '0');
                                    end if;
                                end if;
                        end case;
                        state <= IDLE;
                    when IDLE =>
                        if ready = '0' then
                            state <= AWAIT;
                        end if;
                end case;
            end if;
        end process;

    end architecture;