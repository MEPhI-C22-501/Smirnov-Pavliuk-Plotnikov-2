library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity WriteBack_tester is
    Port ( 
	i_clk          : out  STD_LOGIC;
	i_rst          : out  STD_LOGIC;
       
	i_datamem_result     : out  STD_LOGIC_VECTOR(31 downto 0) := x"00000000"; 
        i_ALU_result         : out  STD_LOGIC_VECTOR(31 downto 0) := x"00000000"; 
        i_CSR_result     : out  STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
           
        i_result_src        : out  STD_LOGIC_VECTOR(1 downto 0)  := "00"
  );
end entity WriteBack_tester;

architecture tester of WriteBack_tester is
  
  signal clk : std_logic := '0';
  constant clk_period : time := 10 ns;
  
  procedure wait_clk(constant j: in integer) is 
        variable ii: integer := 0;
        begin
        while ii < j loop
            if (rising_edge(clk)) then
                ii := ii + 1;
            end if;
            wait for 10 ps;
        end loop;
    end;
  
  begin

  clk <= not clk after clk_period / 2;
    i_clk <= clk;

process
begin
  
  i_rst <= '1'; -- Удерживаем сброс
  i_ALU_result <= (others => '0');
  i_datamem_result <= (others => '0');
  i_CSR_result <= (others => '0');
  --i_result_src <= "00";
  wait_clk(2); 

  
  i_rst <= '0';
  wait_clk(1);

  i_ALU_result <= x"0000000A"; 
  i_datamem_result <= x"FFFFFFFF";
  i_CSR_result <= x"55555555";

  -- Выбор результата из памяти данных
  i_result_src <= "01"; 
  wait_clk(2); 

  -- Выбор результата из АЛУ
  i_result_src <= "00";
  wait_clk(2);
  
  -- Выбор результата из CSR
  i_result_src <= "10";
  wait_clk(2);
  
  -- Выбор запрещённого значения
  i_result_src <= "11";
  wait_clk(2);
  
  -- Выбор памяти данных
  i_result_src <= "01"; 
  wait_clk(2);
  i_datamem_result <= x"87654321";
  wait_clk(2);
  
  -- Выбор результата из АЛУ
  i_result_src <= "00"; 
  wait_clk(2);
  i_ALU_result <= x"12345678"; 
  wait_clk(2);
  
  -- Выбор результата из CSR
  i_result_src <= "10";
  wait_clk(2);
  i_CSR_result <= x"10101010";
  wait_clk(2);
  
  wait_clk(2);
  -- Сброс
  i_rst <= '1';
  wait_clk(2);
  
  i_result_src <= "11";

  -- Завершение симуляции
  wait;
end process;


end architecture tester;
