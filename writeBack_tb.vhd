library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WriteBack_tb is
end entity;

architecture tb of WriteBack_tb is

		 signal i_clk          :   STD_LOGIC := '0';
       signal i_rst          :   STD_LOGIC := '1';
       signal i_read_data    :   STD_LOGIC_VECTOR(31 downto 0); --данные из регистров
       signal i_ALUResult    :   STD_LOGIC_VECTOR(31 downto 0); --данные из АЛУ
       signal i_resultSrc    :   STD_LOGIC;  -- выбор места, откуда брать результат ("0" - регистры, "1" - АЛУ)
       signal i_regWrite     :   STD_LOGIC;  -- разрешение на запись
       signal o_result       :   STD_LOGIC_VECTOR(31 downto 0);

  component WriteBack 
	port (
        i_clk          : in  STD_LOGIC;
        i_rst          : in  STD_LOGIC;
        i_read_data    : in  STD_LOGIC_VECTOR(31 downto 0); --данные из регистров
        i_ALUResult    : in  STD_LOGIC_VECTOR(31 downto 0); --данные из АЛУ
        i_resultSrc    : in  STD_LOGIC;  -- выбор места, откуда брать результат ("0" - регистры, "1" - АЛУ)
        i_regWrite     : in  STD_LOGIC;  -- разрешение на запись
        
        o_result       : out STD_LOGIC_VECTOR(31 downto 0) -- результат, который принимает LSU
    );
  end component;  
  
  component WriteBack_tester  
   port (  
           i_clk          : out  STD_LOGIC;
           i_rst          : out  STD_LOGIC;
           i_read_data    : out  STD_LOGIC_VECTOR(31 downto 0); 
           i_ALUResult    : out  STD_LOGIC_VECTOR(31 downto 0); 
           i_resultSrc    : out  STD_LOGIC;  
           i_regWrite     : out  STD_LOGIC;  
           o_result       : in STD_LOGIC_VECTOR(31 downto 0));
   end component; 

begin
  uut : WriteBack 
  port map (
    i_clk => i_clk,
    i_rst => i_rst,
    i_read_data => i_read_data,
    i_ALUResult => i_ALUResult,
    i_resultSrc => i_resultSrc,
    i_regWrite => i_regWrite,
    o_result => o_result
  );

  tester : WriteBack_tester 
  port map (
    i_clk => i_clk,
    i_rst => i_rst,
    i_read_data => i_read_data,
    i_ALUResult => i_ALUResult,
    i_resultSrc => i_resultSrc,
    i_regWrite => i_regWrite,
    o_result => o_result
  );

end architecture tb;
