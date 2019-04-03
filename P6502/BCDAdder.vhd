library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BCDAdder is
	port(
		a		: in unsigned (3 downto 0);
		b		: in unsigned (3 downto 0);
		c_in	: in std_logic;
		s		: out unsigned (3 downto 0);
		c_out	: out std_logic
	);
end BCDAdder;

architecture behavior of BCDAdder is

begin
	prc:process(a, b, c_in)
		variable sum_temp : unsigned(4 downto 0);
	begin
			 sum_temp := ('0' & a) + ('0' & b) + ("0000" & c_in); 
			 if(sum_temp > 9) then
				  c_out <= '1';
				  s <= resize((sum_temp + "00110"),4);
			 else
				  c_out <= '0';
				  s <= sum_temp(3 downto 0);
			 end if; 
	end process;

end behavior;