--Copyright (C)2014-2025 Gowin Semiconductor Corporation.
--All rights reserved.
--File Title: Template file for instantiation
--Tool Version: V1.9.11.03 Education
--Part Number: GW2AR-LV18QN88C8/I7
--Device: GW2AR-18
--Device Version: C
--Created Time: Tue Jan 27 08:13:55 2026

--Change the instance name and port connections to the signal names
----------Copy here to design--------

component Gowin_rPLL
    port (
        clkout: out std_logic;
        clkoutd: out std_logic;
        clkin: in std_logic
    );
end component;

your_instance_name: Gowin_rPLL
    port map (
        clkout => clkout,
        clkoutd => clkoutd,
        clkin => clkin
    );

----------Copy end-------------------
