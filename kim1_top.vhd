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

	signal vga_clock 		: std_logic := '0';
	signal vga_hpos		: integer range 0 to 1000;
	signal vga_vpos		: integer range 0 to 1000;
	
	signal segment_draw 	: std_logic_vector(5 downto 0);

	signal oneSecCount 	: integer := 0;
	signal oneSecond		: std_logic := '0';
	
	constant ZEROS			: std_logic_vector(5 downto 0) := "000000";
		
	constant SEG_XOFFSET	: integer := 20;
	constant SEG_YOFFSET	: integer := 100;
	constant SEG_WIDTH	: integer := 80;
	constant SEG_LENGTH	: integer := 160;
	constant SEG_THICK	: integer := 10;
	constant SEG_GAP		: integer := 20;

begin
	pllInst : entity work.pll
		port map (
			inclk0 => CLK_20,
			c0 => vga_clock
		);

	vgaInst : entity work.vga
		port map (
			vga_clock => vga_clock,
			vga_hpos => vga_hpos,
			vga_vpos => vga_vpos,
			vga_hsync => VIDEO_HSYNC,
			vga_vsync => VIDEO_VSYNC
		);

	segments : for i in 0 to 5 generate	
	begin
		segmentInst : entity work.segment
			port map (
				xoffset 	=> SEG_XOFFSET + i*(SEG_WIDTH + SEG_GAP),
				yoffset 	=> SEG_YOFFSET,
				width		=> SEG_WIDTH,
				length	=>	SEG_LENGTH,
				thick		=> SEG_THICK,
				hpos => vga_hpos,
				vpos => vga_vpos,
				draw => segment_draw(i)
			);
	end generate;
	
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
		if(segment_draw /= ZEROS)then
			VIDEO_R <= "01111111";
			VIDEO_G <= "00000000";
			VIDEO_B <= "00000000";
		else
			VIDEO_R <= "00000000";
			VIDEO_G <= "00000000";
			VIDEO_B <= "00000000";
		end if;
	end process;
		
end behavior;
	
