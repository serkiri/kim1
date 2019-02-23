library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity segment is
	port(
		xoffset: in integer;
		yoffset: in integer;
		hpos	: in integer range 0 to 1000;
		vpos	: in integer range 0 to 1000;
		draw	: out std_logic := '0'
	);
end segment;

architecture behavior of segment is

begin
	drawOut:process(hpos, vpos)
	begin
		if(hpos > xoffset and hpos < xoffset + 50 and vpos > yoffset and vpos < yoffset + 50)then
			draw <= '1';
		else
			draw <= '0';
		end if;
	end process;

end behavior;