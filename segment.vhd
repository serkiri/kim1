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
		hpos	: in integer range 0 to 1000;
		vpos	: in integer range 0 to 1000;
		draw	: out std_logic := '0'
	);
end segment;

architecture behavior of segment is

begin
	drawOut:process(hpos, vpos, width, length, thick, xoffset, yoffset)
	begin
		if(hpos >= xoffset and hpos < xoffset + width and vpos >= yoffset and vpos < yoffset + thick) or --a
		(hpos >= xoffset + width - thick and hpos < xoffset + width and vpos >= yoffset and vpos < yoffset + (length + thick)/2) or--b
		(hpos >= xoffset + width - thick and hpos < xoffset + width and vpos >= yoffset + (length - thick)/2 and vpos < yoffset + length) or  --c
		(hpos >= xoffset and hpos < xoffset + width and vpos >= yoffset + length - thick and vpos < yoffset + length) or --d
		(hpos >= xoffset and hpos < xoffset + thick and vpos >= yoffset + (length - thick)/2 and vpos < yoffset + length) or--e
		(hpos >= xoffset and hpos < xoffset + thick and vpos >= yoffset and vpos < yoffset + (length + thick)/2) or  --f
		(hpos >= xoffset and hpos < xoffset + width and vpos >= yoffset + (length - thick)/2 and vpos < yoffset + (length + thick)/2) then  --g
			draw <= '1';
		else
			draw <= '0';
		end if;
	end process;

end behavior;