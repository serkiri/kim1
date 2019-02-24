library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity segment is
	port(
		xoffset	: in integer;
		yoffset	: in integer;
		width		: in integer;
		length	: in integer;
		thick		: in integer;
		segments	: in std_logic_vector (6 downto 0);
		hpos		: in integer range 0 to 1000;
		vpos		: in integer range 0 to 1000;
		draw		: out std_logic := '0'
	);
end segment;

architecture behavior of segment is

begin
	drawOut:process(hpos, vpos, width, length, thick, xoffset, yoffset, segments)
	begin
		if(segments(0) = '1' and hpos >= xoffset and hpos < xoffset + width and vpos >= yoffset and vpos < yoffset + thick) or --a
		(segments(1) = '1' and hpos >= xoffset + width - thick and hpos < xoffset + width and vpos >= yoffset and vpos < yoffset + (length + thick)/2) or--b
		(segments(2) = '1' and hpos >= xoffset + width - thick and hpos < xoffset + width and vpos >= yoffset + (length - thick)/2 and vpos < yoffset + length) or  --c
		(segments(3) = '1' and hpos >= xoffset and hpos < xoffset + width and vpos >= yoffset + length - thick and vpos < yoffset + length) or --d
		(segments(4) = '1' and hpos >= xoffset and hpos < xoffset + thick and vpos >= yoffset + (length - thick)/2 and vpos < yoffset + length) or--e
		(segments(5) = '1' and hpos >= xoffset and hpos < xoffset + thick and vpos >= yoffset and vpos < yoffset + (length + thick)/2) or  --f
		(segments(6) = '1' and hpos >= xoffset and hpos < xoffset + width and vpos >= yoffset + (length - thick)/2 and vpos < yoffset + (length + thick)/2) then  --g
			draw <= '1';
		else
			draw <= '0';
		end if;
	end process;

end behavior;