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

	signal vga_clk : std_logic := '0';

	component pll is
        port (
            inclk0       : in std_logic := '0'; 
            c0 : out std_logic
			);
	end component pll;

	component vga is
	 	port(
			vga_clock		: in std_logic;
			vga_video_r		: out std_logic_vector(7 downto 0);
			vga_video_g		: out std_logic_vector(7 downto 0);
			vga_video_b		: out std_logic_vector(7 downto 0);
			vga_hsync		: out std_logic := '1';
			vga_vsync		: out std_logic := '1'
		);
	end component vga;


begin
	pllInst : component pll
		port map (
			inclk0 => CLK_20,
			c0 => vga_clk
		);

	vgaInst : component vga
		port map (
			vga_clock => vga_clk,
			vga_video_r => VIDEO_R,
			vga_video_g => VIDEO_G,
			vga_video_b => VIDEO_B,
			vga_hsync => VIDEO_HSYNC,
			vga_vsync => VIDEO_VSYNC
		);

		
end behavior;
	
