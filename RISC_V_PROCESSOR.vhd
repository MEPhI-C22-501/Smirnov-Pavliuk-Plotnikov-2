library ieee;
use ieee.std_logic_1164.all;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL; 
library work;
use work.my_vector_pkg.all;

entity RISC_V_PROCESSOR is
  port (
    i_clk : in std_logic;
    i_rst : in std_logic
  );
end entity RISC_V_PROCESSOR;

architecture behavioral of RISC_V_PROCESSOR is

  component COMMAND_DECODER 
    port ( 
			i_clk         	: in std_logic;
			i_rst         	: in std_logic;
			i_instr       	: in std_logic_vector(31 downto 0);
			
			o_r_type      	: out std_logic;
			o_s_type      	: out std_logic;
			o_i_type      	: out std_logic;
			
			o_rs1         	: out std_logic_vector(4 downto 0);
			o_rs2         	: out std_logic_vector(4 downto 0);
			
			o_imm		    	: out std_logic_vector(11 downto 0);
			o_rd          	: out std_logic_vector(4 downto 0);
			
			o_read_to_LSU 	: out std_logic;
			o_write_to_LSU : out std_logic;
			o_LSU_code		: out std_logic_vector(16 downto 0)
	 
	 ); 
  end component;
  
  component ALU
    port ( 
         i_first_operand	: in std_logic_vector(31 downto 0);
			i_second_operand 	: in std_logic_vector(31 downto 0);
         i_manage 			: in std_logic_vector(16 downto 0);
         i_clk 				: in std_logic;
         i_rst 				: in std_logic;
		  
         o_result 			: out std_logic_vector(31 downto 0)
	 ); 
  end component;
  
  
  component LSU
    port ( 
			i_clk         			: in std_logic;
			i_rst         			: in std_logic;
			i_regWrite_decoder	: in std_logic;
			i_opcode_decoder 		: in std_logic_vector (16 downto 0);
			i_rs1_decoder			: in std_logic_vector (4 downto 0); 
			i_rs2_decoder			: in std_logic_vector (4 downto 0);
			i_rd_decoder 			: in std_logic_vector (4 downto 0);
			i_imm_decoder			: in std_logic_vector (11 downto 0);
			i_rs_csr 				: in my_vector;

			o_opcode_alu 			: out std_logic_vector (16 downto 0);
			o_rs_csr 				: out my_vector;
			o_rs1_alu				: out std_logic_vector (31 downto 0); 
			o_rs2_alu				: out std_logic_vector (31 downto 0)
	 ); 
  end component;
 
  
  component CSR
    port ( 
			i_clk        							: in std_logic;
			i_rst                  				: in std_logic;
			i_program_counter_write_enable 	: in std_logic;
			i_program_counter 					: in std_logic_vector(15 downto 0);
	--		i_rs1_write_enable 					: in std_logic;
	--		i_rs1        							: in std_logic_vector(31 downto 0);
	--		i_rs2_write_enable 					: in std_logic;
	--		i_rs2        							: in std_logic_vector(31 downto 0);
	--		i_rd_write_enable 					: in std_logic;
	--		i_rd         							: in std_logic_vector(31 downto 0);
			i_csr_array_write_enable 			: in std_logic_vector(31 downto 0);
			i_csr_array 							: in my_vector;
			
	--		o_rs1        							: out std_logic_vector(31 downto 0);
	--		o_rs2        							: out std_logic_vector(31 downto 0);
	--		o_rd         							: out std_logic_vector(31 downto 0);
			o_program_counter   					: out std_logic_vector(15 downto 0);
			o_csr_array 							: out my_vector
	 ); 
  end component;
  
  component INSTRUCTION_MEMORY
		port (
			i_clk       							: in  std_logic;
         i_read_addr 							: in  std_logic_vector(15 downto 0);
         o_read_data 							: out std_logic_vector(31 downto 0)		
		);
	end component;
  
   component DATA_MEMORY
		port (
         i_clk        							: in  std_logic;
         i_rst        							: in  std_logic;
         i_write_enable 						: in  std_logic;
         i_write_addr 							: in  std_logic_vector(15 downto 0);
         i_read_addr 							: in  std_logic_vector(15 downto 0);
         i_write_data 							: in  std_logic_vector(31 downto 0);
		  
         o_read_data 							: out std_logic_vector(31 downto 0)
			
		);
	end component;
  
	component WRITEBACK
		port (
		  i_clk          							: in  STD_LOGIC;
        i_rst          							: in  STD_LOGIC;
        i_read_data    							: in  STD_LOGIC_VECTOR(31 downto 0); 
        i_ALUResult    							: in  STD_LOGIC_VECTOR(31 downto 0); 
        i_resultSrc    							: in  STD_LOGIC;                
        i_regWrite     							: in  STD_LOGIC;

		  
        o_result       							: out STD_LOGIC_VECTOR(31 downto 0);   
        o_regWrite     							: out STD_LOGIC
  );
  end component;
  
  signal core_clock 				: std_logic :='0';
  signal core_reset 				: std_logic :='0';
  
  
  signal instruction_command 	: std_logic_vector(31 downto 0);
   
  signal instruction_rs1      : std_logic_vector(4 downto 0);
  signal instruction_rs2      : std_logic_vector(4 downto 0);
  signal instruction_imm      : std_logic_vector(11 downto 0);
  signal instruction_rd     	: std_logic_vector(4 downto 0);
  
  signal decoder_write_to_lsu : std_logic;
  signal lsu_code     			: std_logic_vector(16 downto 0);
  
  signal alu_rs1 					: std_logic_vector(31 downto 0);
  signal alu_rs2 					: std_logic_vector(31 downto 0);
  signal alu_opcode				: std_logic_vector (16 downto 0);
  signal alu_result    			: std_logic_vector(31 downto 0);

  signal datamem_result 		: std_logic_vector(31 downto 0);
  signal reg_file_input			: my_vector;
  signal reg_file_output		: my_vector;
  
  signal PCinput					: std_logic_vector(15 downto 0);
  signal PCoutput					: std_logic_vector(15 downto 0);
  signal PC_write_enable		: std_logic;

  signal wb_result				: std_logic_vector(31 downto 0);
  signal wb_regWrite				: std_logic;
  
  signal read_to_LSU   : std_logic;

  signal csr_write    : std_logic_vector(31 downto 0);  

  
begin
	
	core_clock <= i_clk;
	core_reset <= i_rst;


  decoder_inst : COMMAND_DECODER port map (
    i_clk           => core_clock,--
    i_rst           => core_reset,--
    i_instr         => instruction_command, --
--    o_r_type        => command_is_r_type,--
 --   o_s_type        => command_is_s_type,--
 --   o_i_type        => command_is_i_type,--
    o_rs1           => instruction_rs1, --
    o_rs2           => instruction_rs2, --
    o_imm           => instruction_imm, --
    o_rd            => instruction_rd, --
 --   o_read_to_LSU   => , ???
    o_write_to_LSU  => decoder_write_to_lsu, --
    o_LSU_code      => lsu_code --
  );

  alu_inst : ALU port map (
    i_clk            => core_clock, --
    i_rst            => core_reset, --
	 i_first_operand  => alu_rs1, --
    i_second_operand => alu_rs2, --
    i_manage         => alu_opcode, --
	 
    o_result         => alu_result --
  );

  lsu_inst : LSU port map (
	 i_clk            => core_clock, --
    i_rst            => core_reset, --
    i_regWrite_decoder => decoder_write_to_lsu,  --
    i_opcode_decoder => lsu_code,   --     
    i_rs1_decoder    => instruction_rs1, --          
    i_rs2_decoder    => instruction_rs2, --         
    i_rd_decoder     => instruction_rd,  --         
    i_imm_decoder    => instruction_imm, --                 
    i_rs_csr         => reg_file_output, --
	 
    o_opcode_alu     => alu_opcode, --
 --   o_rs_csr         => ???,
    o_rs1_alu        => alu_rs1, --
    o_rs2_alu        => alu_rs2 --
	 
  );			

  csr_inst : CSR port map (
    i_clk                    => core_clock,--
    i_rst                    => core_reset,--
    i_program_counter_write_enable => PC_write_enable, 
    i_program_counter        => PCinput,    
	 
    i_csr_array_write_enable => csr_write, 
    i_csr_array              => reg_file_input,
	 
    o_program_counter        => PCoutput,   
    o_csr_array              => reg_file_output
  );

--  datamem_inst : DATA_MEMORY port map (
--	 i_clk        			=> core_clk, --
 --   i_rst        			=> core_reset, --
 --   i_write_enable 		=>
  --  i_write_addr 			=>
   -- i_read_addr 			=>
  --  i_write_data 			=>
	  
  --  o_read_data 			=> datamem_result --
  --);
  
  instrmem_inst : INSTRUCTION_MEMORY port map (
    i_clk       	=> core_clock, --	
    i_read_addr 	=> PCoutput, --
    
	 o_read_data 	=>	instruction_command --

  );

  wb_inst : WRITEBACK port map (
    i_clk          => core_clock, --
    i_rst          => core_reset, --
    
	 i_read_data    => datamem_result,  --
    i_ALUResult    => alu_result, --
    i_resultSrc    => '1',     
	 
    i_regWrite     => '1',
    o_result       => wb_result,
    o_regWrite     => wb_regWrite
  );

end architecture behavioral;