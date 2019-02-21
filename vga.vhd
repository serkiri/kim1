library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga is
	port(
		vga_clock		: in std_logic;
		vga_hsync		: out std_logic := '1';
		vga_vsync		: out std_logic := '1';
		vga_hpos			: out integer range 0 to 1000;
		vga_vpos			: out integer range 0 to 1000
	);
end vga;

architecture behavior of vga is

	signal hPos : integer := 0;
	signal vPos : integer := 0;
	
	constant HD : integer := 639;  --  639   Horizontal Display (640)
	constant HFP : integer := 16;         --   16   Right border (front porch)
	constant HSP : integer := 96;       --   96   Sync pulse (Retrace)
	constant HBP : integer := 48;        --   48   Left boarder (back porch)
	
	constant VD : integer := 479;   --  479   Vertical Display (480)
	constant VFP : integer := 10;       	 --   10   Right border (front porch)
	constant VSP : integer := 2;				 --    2   Sync pulse (Retrace)
	constant VBP : integer := 33;       --   33   Left boarder (back porch)

begin
	Horizontal_position_counter:process(vga_clock)
	begin
		if(vga_clock'event and vga_clock = '1')then
			if (hPos = (HD + HFP + HSP + HBP)) then
				hPos <= 0;
			else
				hPos <= hPos + 1;
			end if;
		end if;
	end process;

	Vertical_position_counter:process(vga_clock, hPos)
	begin
		if(vga_clock'event and vga_clock = '1')then
			if(hPos = (HD + HFP + HSP + HBP))then
				if (vPos = (VD + VFP + VSP + VBP)) then
					vPos <= 0;
				else
					vPos <= vPos + 1;
				end if;
			end if;
		end if;
	end process;

	Horizontal_Synchronisation:process(vga_clock, hPos)
	begin
		if(vga_clock'event and vga_clock = '1')then
			if((hPos <= (HD + HFP)) OR (hPos > HD + HFP + HSP))then
				vga_hsync <= '1';
			else
				vga_hsync <= '0';
			end if;
		end if;
	end process;

	Vertical_Synchronisation:process(vga_clock, vPos)
	begin
		if(vga_clock'event and vga_clock = '1')then
			if((vPos <= (VD + VFP)) OR (vPos > VD + VFP + VSP))then
				vga_vsync <= '1';
			else
				vga_vsync <= '0';
			end if;
		end if;
	end process;

	vga_hpos <= hPos;
	vga_vpos <= vPos;


end behavior;