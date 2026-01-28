library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_buffer_io is port(
    clk, rst_n, rx: in std_logic;
    x, y: in unsigned(11 downto 0);
    ascii: out unsigned(7 downto 0)
);
end entity;

architecture rtl of frame_buffer_io is
    constant H_CHARS: integer := 100;
    constant V_CHARS: integer := 60;

    signal char_x, char_y: unsigned(6 downto 0);
    signal data: std_logic_vector(7 downto 0);
    signal ready: std_logic;
    signal wr, clear_rq, clearing: std_logic;

    type state_t is (CLEAR, AWAIT, CONSUME, IDLE);
    signal state: state_t := CLEAR;
    signal cursor_x, cursor_y: unsigned(6 downto 0) := (others => '0');

    begin
        char_x <= x(9 downto 3);
        char_y <= y(9 downto 3);

        u_uart_rx: entity work.uart_rx(rtl)
            port map (clk => clk, rst_n => rst_n, rx => rx,
                    data => data, ready => ready);

        u_frame_buffer: entity work.frame_buffer
            port map (
                clk => clk, rst_n => rst_n, wr => wr, clear => clear_rq, clearing => clearing,
                rd_x => char_x, rd_y => char_y, wr_x => cursor_x, wr_y => cursor_y,
                data_in => data,
                unsigned(data_out) => ascii);

        process(clk, rst_n) begin
            if rst_n = '0' then    
                wr <= '0';
                clear_rq <= '1';
                state <= CLEAR;         
                cursor_x <= (others => '0');
                cursor_y <= (others => '0');   
            elsif rising_edge(clk) then
                case state is
                    when CLEAR =>
                        if clear_rq = '1' and clearing = '0' then
                            clear_rq <= '0';
                            state <= AWAIT;
                        elsif clear_rq = '0' then
                            state <= AWAIT;
                        end if;
                    when AWAIT =>
                        if ready = '1' then
                            state <= CONSUME;
                        end if;
                    when CONSUME =>
                        state <= IDLE;
                        case data is
                            when x"00" =>
                                cursor_x <= (others => '0');
                                cursor_y <= (others => '0');
                                clear_rq <= '1';
                            when x"08" =>
                                if cursor_x > 0 then
                                    cursor_x <= cursor_x - 1;
                                else
                                    if cursor_y > 0 then
                                        cursor_y <= cursor_y - 1;
                                    else
                                        cursor_y <= to_unsigned(V_CHARS - 1, 7);
                                    end if;
                                end if;

                            when x"0A" =>
                                if cursor_y < V_CHARS - 1 then
                                    cursor_y <= cursor_y + 1;
                                else
                                    cursor_y <= (others => '0');
                                end if;

                            when x"0D" => cursor_x <= (others => '0');

                            when others =>
                                wr <= '1';
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
                    when IDLE =>
                        wr <= '0';
                        if ready = '0' then
                            state <= CLEAR;
                        end if;
                end case;
            end if;
        end process;

    end architecture;