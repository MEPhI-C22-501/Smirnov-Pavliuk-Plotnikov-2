library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity WriteBack is
    port (
        i_clk          : in  STD_LOGIC;
        i_rst          : in  STD_LOGIC;
        i_read_data    : in  STD_LOGIC_VECTOR(31 downto 0); --данные из регистров
        i_ALUResult    : in  STD_LOGIC_VECTOR(31 downto 0); --данные из АЛУ
        i_resultSrc    : in  STD_LOGIC;  -- выбор места, откуда брать результат ("0" - регистры, "1" - АЛУ)
        i_regWrite     : in  STD_LOGIC;  -- разрешение на запись
        
        o_result       : out STD_LOGIC_VECTOR(31 downto 0) -- результат, который принимает LSU
    );
end entity WriteBack;

architecture Behavioral of WriteBack is
begin
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                o_result <= (others => '0');
            elsif i_regWrite = '1' then
                if i_resultSrc = '1' then
                    o_result <= i_read_data;
                else
                    o_result <= i_ALUResult;
                end if;
            end if;
        end if;
    end process;
end Behavioral;