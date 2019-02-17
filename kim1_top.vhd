library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity kim1_top is
	port(
		CLK_20			: in std_logic;
		VIDEO_R			: out std_logic_vector(7 downto 0) := "01111111";
		VIDEO_G			: out std_logic_vector(7 downto 0) := "01111111";
		VIDEO_B			: out std_logic_vector(7 downto 0) := "01111111";
		VIDEO_HSYNC		: out std_logic := '1';
		VIDEO_VSYNC		: out std_logic := '1'
	);
end kim1_top;

architecture behavior of kim1_top is

	signal vga_clk : std_logic := '0';
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


	component pll is
        port (
            inclk0       : in std_logic := '0'; -- clk
            c0 : out std_logic
			);
    end component pll;


begin
	pllInst : component pll
		port map (
			inclk0 => CLK_20,
			c0 => vga_clk
		);

	Horizontal_position_counter:process(vga_clk)
	begin
		if(vga_clk'event and vga_clk = '1')then
			if (hPos = (HD + HFP + HSP + HBP)) then
				hPos <= 0;
			else
				hPos <= hPos + 1;
			end if;
		end if;
	end process;

	Vertical_position_counter:process(vga_clk, hPos)
	begin
		if(vga_clk'event and vga_clk = '1')then
			if(hPos = (HD + HFP + HSP + HBP))then
				if (vPos = (VD + VFP + VSP + VBP)) then
					vPos <= 0;
				else
					vPos <= vPos + 1;
				end if;
			end if;
		end if;
	end process;

	Horizontal_Synchronisation:process(vga_clk, hPos)
	begin
		if(vga_clk'event and vga_clk = '1')then
			if((hPos <= (HD + HFP)) OR (hPos > HD + HFP + HSP))then
				video_hsync <= '1';
			else
				video_hsync <= '0';
			end if;
		end if;
	end process;

	Vertical_Synchronisation:process(vga_clk, vPos)
	begin
		if(vga_clk'event and vga_clk = '1')then
			if((vPos <= (VD + VFP)) OR (vPos > VD + VFP + VSP))then
				video_vsync <= '1';
			else
				video_vsync <= '0';
			end if;
		end if;
	end process;


	draw:process(vga_clk, hPos, vPos)
	begin
		if(vga_clk'event and vga_clk = '1')then
				if(hPos < 80)then
					video_r <= "00000000";
					video_g <= "00000000";
					video_b <= "00000000";
				elsif(hPos < 160)then
					video_r <= "00000000";
					video_g <= "00000000";
					video_b <= "01111111";
				elsif(hPos < 240)then
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "00000000";
				elsif(hPos < 320)then
					video_r <= "01111111";
					video_g <= "00000000";
					video_b <= "01111111";
				elsif(hPos < 400)then
					video_r <= "00000000";
					video_g <= "01111111";
					video_b <= "00000000";
				elsif(hPos < 480)then
					video_r <= "00000000";
					video_g <= "01111111";
					video_b <= "01111111";
				elsif(hPos < 560)then
					video_r <= "01111111";
					video_g <= "01111111";
					video_b <= "00000000";
				elsif(hPos < 640)then
					video_r <= "01111111";
					video_g <= "01111111";
					video_b <= "01111111";
				else
					video_r <= "00000000";
					video_g <= "00000000";
					video_b <= "00000000";
				end if;
		end if;
	end process;

end behavior;
	
