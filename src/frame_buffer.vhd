library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity frame_buffer is port(
    clk, rst_n, wr, clear: in std_logic;
    rd_x, rd_y, wr_x, wr_y: in unsigned(6 downto 0);
    data_in: in std_logic_vector(7 downto 0);
    clearing: out std_logic;
    data_out: out std_logic_vector(7 downto 0)
);
end entity;

architecture rtl of frame_buffer is
    constant H_CHARS: integer := 100;
    constant V_CHARS: integer := 60;

    signal rd_data, wr_data: std_logic_vector(7 downto 0);
    signal rd_addr, wr_addr: unsigned(12 downto 0);
    signal wr_en: std_logic;

    signal cl_idx: unsigned(12 downto 0);

    begin
        clearing <= '1' when clear = '1' and cl_idx < H_CHARS*V_CHARS-1 else '0';
        rd_addr <= resize(rd_y * H_CHARS + rd_x + 1, 13) when rd_x < H_CHARS - 1 and rd_y < V_CHARS-1 else (others => '0');

        data_out <= rd_data;

        u_SDPB: entity work.Gowin_SDPB
            port map (
                ada => std_logic_vector(wr_addr),
                din => wr_data,
                clka => clk,
                cea => wr_en,
                reseta => '0',

                adb => std_logic_vector(rd_addr), -- Next one
                dout => rd_data,
                clkb => clk,
                ceb => '1',
                oce => '1',
                resetb => '0'
        );

        process(clk, rst_n) begin
            if rst_n = '0' then
                wr_en <= '0';
                cl_idx <= (others => '0');
            elsif rising_edge(clk) then
                if clear = '1' then
                    if cl_idx < H_CHARS*V_CHARS then
                        wr_data <= (others => '0');
                        wr_addr <= cl_idx;
                        wr_en <= '1';
                        cl_idx <= cl_idx + 1;
                    end if;
                else
                    wr_data <= data_in;
                    wr_addr <= resize(wr_y * H_CHARS + wr_x, 13);
                    wr_en <= wr;
                end if;
            end if;
        end process;
    end architecture;