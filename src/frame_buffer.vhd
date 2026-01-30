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

    signal cl_idx: unsigned(12 downto 0) := (others => '0');

    begin
        clearing <= '1' when clear = '1' and cl_idx < H_CHARS*V_CHARS else '0';
        data_out <= rd_data;

        rd_addr <= resize(rd_y * H_CHARS + rd_x mod (H_CHARS*V_CHARS), 13);

        wr_data <= data_in when (clear = '0' or clearing = '0') else x"20";
        wr_addr <= resize(wr_y * H_CHARS + wr_x mod (H_CHARS*V_CHARS), 13) when (clear = '0' or clearing = '0') else cl_idx; -- Last cycles address
        wr_en <= wr when (clear = '0' or clearing = '0') else '1';

        u_SDPB: entity work.Gowin_SDPB
            port map (
                ada => std_logic_vector(wr_addr),
                din => wr_data,
                clka => clk,
                cea => wr_en,
                reseta => '0',

                adb => std_logic_vector(rd_addr),
                dout => rd_data,
                clkb => clk,
                ceb => '1',
                oce => '1',
                resetb => '0'
        );

        process(clk, rst_n, clear) begin
            if rst_n = '0' then
                cl_idx <= (others => '0');
            elsif rising_edge(clk) then
                if clear = '1' and clearing = '0' then
                    cl_idx <= (others => '0');
                elsif clear = '1' and clearing = '1' then
                    if cl_idx < H_CHARS*V_CHARS then
                        cl_idx <= cl_idx + 1;
                    end if;
                end if;
            end if;
        end process;
    end architecture;