library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WriteBack_tb is
end entity;

architecture tb of WriteBack_tb is

    signal clk            : STD_LOGIC;
    signal rst            : STD_LOGIC;
    signal datamem_result : STD_LOGIC_VECTOR(31 downto 0); -- данные из памяти данных
    signal ALU_result     : STD_LOGIC_VECTOR(31 downto 0); -- данные из АЛУ
    signal CSR_result     : STD_LOGIC_VECTOR(31 downto 0); -- данные из CSR
    signal result_src     : STD_LOGIC_VECTOR(1 downto 0);  -- выбор источника результата
    signal result         : STD_LOGIC_VECTOR(31 downto 0); -- результат, который принимает LSU

    component WriteBack 
        port (
            i_clk            : in  STD_LOGIC;
            i_rst            : in  STD_LOGIC;
            i_ALU_result     : in  STD_LOGIC_VECTOR(31 downto 0); 
            i_datamem_result : in  STD_LOGIC_VECTOR(31 downto 0); 
            i_CSR_result     : in  STD_LOGIC_VECTOR(31 downto 0);
            i_result_src     : in  STD_LOGIC_VECTOR(1 downto 0);  -- "00" - ALU; "01" - datamem; "10" - CSR
            o_result         : out STD_LOGIC_VECTOR(31 downto 0)  
        );
    end component;  

    component WriteBack_tester  
        port (  
            i_clk            : out STD_LOGIC;
            i_rst            : out STD_LOGIC;
            i_datamem_result : out STD_LOGIC_VECTOR(31 downto 0); 
            i_ALU_result     : out STD_LOGIC_VECTOR(31 downto 0); 
            i_CSR_result     : out STD_LOGIC_VECTOR(31 downto 0);
            i_result_src     : out STD_LOGIC_VECTOR(1 downto 0)  
        );
    end component; 

begin
    uut : WriteBack 
    port map (
        i_clk            => clk,
        i_rst            => rst,
        i_ALU_result     => ALU_result,
        i_datamem_result => datamem_result,
        i_CSR_result     => CSR_result,
        i_result_src     => result_src,
        o_result         => result
    );

    tester : WriteBack_tester 
    port map (
        i_clk            => clk,
        i_rst            => rst,
        i_datamem_result => datamem_result,
        i_ALU_result     => ALU_result,
        i_CSR_result     => CSR_result,
        i_result_src     => result_src
    );

end architecture tb;
