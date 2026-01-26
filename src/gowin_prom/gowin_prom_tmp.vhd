--Copyright (C)2014-2025 Gowin Semiconductor Corporation.
--All rights reserved.
--File Title: Template file for instantiation
--Tool Version: V1.9.11.03 Education
--Part Number: GW2AR-LV18QN88C8/I7
--Device: GW2AR-18
--Device Version: C
--Created Time: Mon Jan 26 19:52:01 2026

--Change the instance name and port connections to the signal names
----------Copy here to design--------

component Gowin_pROM
    port (
        dout: out std_logic_vector(7 downto 0);
        clk: in std_logic;
        oce: in std_logic;
        ce: in std_logic;
        reset: in std_logic;
        ad: in std_logic_vector(10 downto 0)
    );
end component;

your_instance_name: Gowin_pROM
    port map (
        dout => dout,
        clk => clk,
        oce => oce,
        ce => ce,
        reset => reset,
        ad => ad
    );

----------Copy end-------------------
