library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WriteBack_tester is
    Port ( i_clk          : out  STD_LOGIC;
           i_rst          : out  STD_LOGIC;
           i_read_data    : out  STD_LOGIC_VECTOR(31 downto 0) := x"00000000"; 
           i_ALUResult    : out  STD_LOGIC_VECTOR(31 downto 0) := x"00000000"; 
           i_resultSrc    : out  STD_LOGIC;  
           i_regWrite     : out  STD_LOGIC;  
           o_result       : in STD_LOGIC_VECTOR(31 downto 0)
			  );
end entity WriteBack_tester;

architecture tester of WriteBack_tester is
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  constant clk_period : time := 10 ns;
begin
	clk_process : process 
   begin
        i_clk <= '0';
        wait for clk_period / 2;
        i_clk <= '1';
        wait for clk_period / 2;
   end process;
	test_process : process
   begin
		
			i_rst <='0';
         i_regWrite <= '0'; 
			i_resultSrc <= '0'; 
			wait for clk_period * 2;
			i_regWrite <= '1';	
			wait for clk_period;
	
			i_ALUResult <= x"0000000A"; 
			i_read_data <= x"FFFFFFFF";
			wait for clk_period * 2;
			i_resultSrc <= '1'; 
			wait for clk_period * 2;
							 
			i_resultSrc <= '0';
			wait for clk_period * 2; 
			i_ALUResult <= x"12345678"; 
			i_read_data <= x"87654321";
			wait for clk_period * 2;
					 
			i_resultSrc <= '1';
			wait for clk_period * 2;  
			i_rst <= '1';
		   wait for clk_period * 2;  
			wait for clk_period * 2; 
			i_regWrite <= '1';

  end process;

end architecture tester;
