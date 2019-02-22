library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity kim1_top is
	port(
		CLK_20			: in std_logic;
		VIDEO_R			: out std_logic_vector(7 downto 0);
		VIDEO_G			: out std_logic_vector(7 downto 0);
		VIDEO_B			: out std_logic_vector(7 downto 0);
		VIDEO_HSYNC		: out std_logic := '1';
		VIDEO_VSYNC		: out std_logic := '1'
	);
end kim1_top;

architecture behavior of kim1_top is

	signal vga_clk 				: std_logic := '0';
	signal current_vga_hpos		: integer range 0 to 1000;
	signal current_vga_vpos		: integer range 0 to 1000;
	
	signal segment_draw 			: std_logic := '0';

	signal oneSecCount 			: integer := 0;
	signal oneSecond				: std_logic := '0';
	
	component pll is
        port (
            inclk0       : in std_logic := '0'; 
            c0 : out std_logic
			);
	end component pll;

	component vga is
	 	port(
			vga_clock		: in std_logic;
			vga_hpos			: out integer range 0 to 1000;
			vga_vpos			: out integer range 0 to 1000;
			vga_hsync		: out std_logic := '1';
			vga_vsync		: out std_logic := '1'
		);
	end component vga;

	component segment is
	 	port(
			segment_hpos	: in integer range 0 to 1000;
			segment_vpos	: in integer range 0 to 1000;
			segment_draw	: out std_logic := '0'
		);
	end component segment;

begin
	pllInst : component pll
		port map (
			inclk0 => CLK_20,
			c0 => vga_clk
		);

	vgaInst : component vga
		port map (
			vga_clock => vga_clk,
			vga_hpos => current_vga_hpos,
			vga_vpos => current_vga_vpos,
			vga_hsync => VIDEO_HSYNC,
			vga_vsync => VIDEO_VSYNC
		);

	segmentInst : component segment
		port map (
			segment_hpos => current_vga_hpos,
			segment_vpos => current_vga_vpos,
			segment_draw => segment_draw
		);

	
	provideOneSecond:process(CLK_20)
	begin
		if(CLK_20'event and CLK_20 = '1')then
			if (oneSecCount >= 20000000) then
					oneSecCount <= 0;
					oneSecond <= not(oneSecond);
			else
				oneSecCount <= oneSecCount + 1;
			end if;
		end if;
	end process;

	draw_segment : process(segment_draw)
	begin
		if(segment_draw = '1')then
			VIDEO_R <= "01111111";
			VIDEO_G <= "01111111";
			VIDEO_B <= "00000000";
		else
			VIDEO_R <= "00000000";
			VIDEO_G <= "00000000";
			VIDEO_B <= "00000000";
		end if;
	end process;
		
end behavior;
	
