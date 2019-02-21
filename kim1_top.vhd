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

	draw:process(vga_clk, current_vga_hpos, current_vga_vpos)
	begin
		if(vga_clk'event and vga_clk = '1')then
				if(current_vga_hpos > 100 and current_vga_hpos < 200 and current_vga_vpos > 100 and current_vga_vpos < 200)then
					VIDEO_R <= "01111111";
					VIDEO_G <= "01111111";
					VIDEO_B <= "01111111";
				else
					VIDEO_R <= "00000000";
					VIDEO_G <= "00000000";
					VIDEO_B <= "00000000";
				end if;
		end if;
	end process;

		
end behavior;
	
