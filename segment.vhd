library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity segment is
	port(
		segment_hpos	: in integer range 0 to 1000;
		segment_vpos	: in integer range 0 to 1000;
		segment_draw	: out std_logic := '0'
	);
end segment;

architecture behavior of segment is

begin
	draw:process(segment_hpos, segment_vpos)
	begin
		if(segment_hpos > 100 and segment_hpos < 200 and segment_vpos > 100 and segment_vpos < 200)then
			segment_draw <= '1';
		else
			segment_draw <= '0';
		end if;
	end process;

end behavior;