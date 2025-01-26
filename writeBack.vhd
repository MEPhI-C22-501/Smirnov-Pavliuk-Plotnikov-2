library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity WriteBack is
    port (
        i_clk           	: in  STD_LOGIC;
        i_rst           	: in  STD_LOGIC;
        
		  i_ALU_result     	: in  STD_LOGIC_VECTOR(31 downto 0); 
		  i_datamem_result   : in  STD_LOGIC_VECTOR(31 downto 0); 
		  i_CSR_result 		: in STD_LOGIC_VECTOR (31 downto 0);
		  
        i_result_src       : in  STD_LOGIC_VECTOR(1 downto 0);  -- "00" - ALU; "01" - datamem; "10" - CSR                            
		  
        o_result        : out STD_LOGIC_VECTOR(31 downto 0)  
    );
end entity WriteBack;

architecture Behavioral of WriteBack is
begin
   process(i_clk, i_rst)
   begin
   if i_rst = '1' then  
        o_result <= (others => '0');
   elsif rising_edge(i_clk) then 
		if i_result_src = "00" then
           o_result <= i_ALU_result;
		elsif i_result_src = "01" then
           o_result <= i_datamem_result;
		elsif i_result_src = "10" then
           o_result <= i_CSR_result;
		else
			  o_result <= (others => '0');
		end if;
	end if;
	end process;
end Behavioral;



