library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity segment is
	port(
		segment_xoffset: in integer;
		segment_yoffset: in integer;
		segment_hpos	: in integer range 0 to 1000;
		segment_vpos	: in integer range 0 to 1000;
		segment_draw	: out std_logic := '0'
	);
end segment;

architecture behavior of segment is

begin
	draw:process(segment_hpos, segment_vpos)
	begin
		if(segment_hpos > segment_xoffset and segment_hpos < segment_xoffset + 50 and segment_vpos > segment_yoffset and segment_vpos < segment_yoffset + 50)then
			segment_draw <= '1';
		else
			segment_draw <= '0';
		end if;
	end process;

end behavior;