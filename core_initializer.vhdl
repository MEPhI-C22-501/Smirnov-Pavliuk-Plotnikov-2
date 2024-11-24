library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
    port (
        clk     : in std_logic;
        address : in unsigned(31 downto 0);
        data_out: out std_logic_vector(31 downto 0)
    );
end entity memory;

architecture Behavioral of memory is
    type memory_array is array (0 to 1023) of std_logic_vector(31 downto 0);
    signal memory : memory_array;
begin
    process
    begin
        file hex_file : text open read_mode is "program.hex";
        variable hex_line : line;
        variable hex_value : std_logic_vector(31 downto 0);
        for i in 0 to 1023 loop
            readline(hex_file, hex_line);
            hread(hex_line, hex_value);
            memory(i) <= hex_value;
        end loop;
    end process;

    data_out <= memory(to_integer(address(11 downto 2)));
end Behavioral;

