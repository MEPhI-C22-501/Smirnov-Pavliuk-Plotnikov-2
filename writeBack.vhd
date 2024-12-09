library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL; 


entity WriteBack is
    port (
        i_clk          : in  STD_LOGIC;
        i_rst          : in  STD_LOGIC;
        i_read_data    : in  STD_LOGIC_VECTOR(31 downto 0); 
        i_ALUResult    : in  STD_LOGIC_VECTOR(31 downto 0); 
        i_resultSrc    : in  STD_LOGIC;                
        i_regWrite     : in  STD_LOGIC;               
        o_result       : out STD_LOGIC_VECTOR(31 downto 0);   
        o_regWrite     : out STD_LOGIC
    );
end entity WriteBack;

architecture Behavioral of WriteBack is
begin
   process(i_rst, i_clk)
   begin
    if i_rst = '1' then  
        o_result <= (others => '0');
        o_regWrite <= '0';
    elsif rising_edge(i_clk) then  
	if i_resultSrc = '1' then
           o_result <= i_ALUResult;
        else
           o_result <= i_read_data;
        end if;
	o_regWrite <= i_regWrite;
    end if;
  end process;
end Behavioral;

