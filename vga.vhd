library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga is
	port(
		vga_clock				: in std_logic;
		vga_video_r			: out std_logic_vector(7 downto 0);
		vga_video_g			: out std_logic_vector(7 downto 0);
		vga_video_b			: out std_logic_vector(7 downto 0);
		vga_hsync		: out std_logic := '1';
		vga_vsync		: out std_logic := '1'
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


	draw:process(vga_clock, hPos, vPos)
	begin
		if(vga_clock'event and vga_clock = '1')then
				if(hPos < 80)then
					vga_video_r <= "01111111";
					vga_video_g <= "01111111";
					vga_video_b <= "01111111";
				elsif(hPos < 160)then
					vga_video_r <= "00000000";
					vga_video_g <= "00000000";
					vga_video_b <= "01111111";
				elsif(hPos < 240)then
					vga_video_r <= "01111111";
					vga_video_g <= "00000000";
					vga_video_b <= "00000000";
				elsif(hPos < 320)then
					vga_video_r <= "01111111";
					vga_video_g <= "00000000";
					vga_video_b <= "01111111";
				elsif(hPos < 400)then
					vga_video_r <= "00000000";
					vga_video_g <= "01111111";
					vga_video_b <= "00000000";
				elsif(hPos < 480)then
					vga_video_r <= "00000000";
					vga_video_g <= "01111111";
					vga_video_b <= "01111111";
				elsif(hPos < 560)then
					vga_video_r <= "01111111";
					vga_video_g <= "01111111";
					vga_video_b <= "00000000";
				elsif(hPos < 640)then
					vga_video_r <= "00000000";
					vga_video_g <= "00000000";
					vga_video_b <= "00000000";
				else
					vga_video_r <= "00000000";
					vga_video_g <= "00000000";
					vga_video_b <= "00000000";
				end if;
		end if;
	end process;

end behavior;