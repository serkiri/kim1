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
	
	signal led_output 	: std_logic_vector(5 downto 0);
	
	type LedArray is array (0 to 5) of std_logic_vector(6 downto 0);
	signal ledSegments	: LedArray;
	signal ledValue		: std_logic_vector (23 downto 0) := x"000000";

	type LedArrayDebug is array (0 to 8) of std_logic_vector(6 downto 0);
	signal ledSegmentsDebug	: LedArrayDebug;
	signal ledOutputDebug 	: std_logic_vector(8 downto 0);
	signal ledValueDebug		: std_logic_vector (31 downto 0);

	
	signal oneSecCount	 	: integer := 0;
	signal oneSecond			: std_logic := '0';
	signal signalCount		: integer := 0;

	
	
	constant ZEROS			: std_logic_vector(5 downto 0) := "000000";
		
	constant SEG_XOFFSET	: integer := 20;
	constant SEG_YOFFSET	: integer := 100;
	constant SEG_WIDTH	: integer := 80;
	constant SEG_LENGTH	: integer := 160;
	constant SEG_THICK	: integer := 10;
	constant SEG_GAP		: integer := 20;
	
	signal we				: std_logic;
	signal rst				: std_logic := '1';
	signal nmi				: std_logic := '1';
	signal irq				: std_logic := '1';
	
	signal data_in       : std_logic_vector(7 downto 0);
   signal data_out      : std_logic_vector(7 downto 0);
	signal address_out	: std_logic_vector(15 downto 0);


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

	generateLeds : for i in 0 to 5 generate	
	begin
		segmentInst : entity work.segment
			port map (
				xoffset 	=> SEG_XOFFSET + i*(SEG_WIDTH + SEG_GAP),
				yoffset 	=> SEG_YOFFSET,
				width		=> SEG_WIDTH,
				length	=>	SEG_LENGTH,
				thick		=> SEG_THICK,
				segments => ledSegments(i),
				hpos => vga_hpos,
				vpos => vga_vpos,
				draw => led_output(i)
			);
	end generate;

    P6502: entity work.P6502 
        generic map (
            PC_INIT => x"0000"
        )
        port map (
            clk         => oneSecond,
            rst         => rst,
            we          => we,
            data_in     => data_in,
            data_out    => data_out,
            address_out => address_out,
            nmi         => nmi,
            irq         => irq,
            ready       => '1',
            nres        => '0'     
        );
	
	provideOneSecond:process(CLK_20)
	begin
		if(CLK_20'event and CLK_20 = '1')then
			if (oneSecCount >= 40000000) then
					oneSecCount <= 0;
					oneSecond <= not(oneSecond);
					--if (rst = '0') then
						ledValue <= std_logic_vector( unsigned(ledValue) + 1 );
					--end if;
			else
				oneSecCount <= oneSecCount + 1;
			end if;
		end if;
	end process;

	signalCountProcess:process(oneSecond)
	begin
		if(oneSecond'event and oneSecond = '1')then
			if (signalCount >= 5) then
					rst <= '0';
			end if;
			if (signalCount >= 50) then
					irq <= '0';
			end if;
			signalCount <= signalCount + 1;
		end if;
	end process;

	draw_segment : process(led_output, ledOutputDebug)
	begin
		if(led_output /= ZEROS) then
			VIDEO_R <= "01111111";
			VIDEO_G <= "00000000";
			VIDEO_B <= "00000000";
		elsif (ledOutputDebug /= "000000000") then
			VIDEO_R <= "01111111";
			VIDEO_G <= "01111111";
			VIDEO_B <= "01111111";
		else
			VIDEO_R <= "00000000";
			VIDEO_G <= "00000000";
			VIDEO_B <= "00000000";
		end if;
	end process;
		

	generateLedValues : for i in 0 to 5 generate	
	begin
		with ledValue((5-i)*4 + 3 downto (5-i)*4) select ledSegments(i) <=
			"0111111" when x"0",
			"0000110" when x"1",
			"1011011" when x"2",
			"1001111" when x"3",
			"1100110" when x"4",
			"1101101" when x"5",
			"1111101" when x"6",
			"0000111" when x"7",
			"1111111" when x"8",
			"1101111" when x"9",
			"1110111" when x"a",
			"1111100" when x"b",
			"0111001" when x"c",
			"1011110" when x"d",
			"1111001" when x"e",
			"1110001" when x"f";
	end generate;
	
	generateDebugAddr : for i in 0 to 3 generate	
	begin
		segmentInst : entity work.segment
			port map (
				xoffset 	=> 0 + i*50,
				yoffset 	=> 300,
				width		=> 40,
				length	=>	80,
				thick		=> 4,
				segments => ledSegmentsDebug(i),
				hpos => vga_hpos,
				vpos => vga_vpos,
				draw => ledOutputDebug(i)
			);
	end generate;

	generateDebugDataIn : for i in 0 to 1 generate	
	begin
		segmentInst : entity work.segment
			port map (
				xoffset 	=> 220 + i*50,
				yoffset 	=> 300,
				width		=> 40,
				length	=>	80,
				thick		=> 4,
				segments => ledSegmentsDebug(i+4),
				hpos => vga_hpos,
				vpos => vga_vpos,
				draw => ledOutputDebug(i+4)
			);
	end generate;

	generateDebugDataOut : for i in 0 to 1 generate	
	begin
		segmentInst : entity work.segment
			port map (
				xoffset 	=> 340 + i*50,
				yoffset 	=> 300,
				width		=> 40,
				length	=>	80,
				thick		=> 4,
				segments => ledSegmentsDebug(i+6),
				hpos => vga_hpos,
				vpos => vga_vpos,
				draw => ledOutputDebug(i+6)
			);
	end generate;

	segmentInstDebugStatus : entity work.segment
			port map (
				xoffset 	=> 460,
				yoffset 	=> 300,
				width		=> 40,
				length	=>	80,
				thick		=> 4,
				segments => ledSegmentsDebug(8),
				hpos => vga_hpos,
				vpos => vga_vpos,
				draw => ledOutputDebug(8)
			);


	generateLedValuesDebug : for i in 0 to 7 generate	
	begin
		with ledValueDebug((7-i)*4 + 3 downto (7-i)*4) select ledSegmentsDebug(i) <=
			"0111111" when x"0",
			"0000110" when x"1",
			"1011011" when x"2",
			"1001111" when x"3",
			"1100110" when x"4",
			"1101101" when x"5",
			"1111101" when x"6",
			"0000111" when x"7",
			"1111111" when x"8",
			"1101111" when x"9",
			"1110111" when x"a",
			"1111100" when x"b",
			"0111001" when x"c",
			"1011110" when x"d",
			"1111001" when x"e",
			"1110001" when x"f";
	end generate;

	rom : process(address_out)
	begin
		case address_out is
			when x"FFFC" => data_in <= x"34";
			when x"FFFD" => data_in <= x"12";
			when x"FFFE" => data_in <= x"78";
			when x"FFFF" => data_in <= x"56";
--			78 sei (1) - disable
--			58 cli (0) - enable
--			40 rti
			
			when x"1234" => data_in <= x"78";
			when x"1240" => data_in <= x"4C";
			when x"1241" => data_in <= x"34";
			when x"1242" => data_in <= x"12";
			
			when x"567B" => data_in <= x"40";
			
			when others  => data_in <= x"EA";
		end case;
	end process;

	ledValueDebug(31 downto 16) <= address_out(15 downto 0);
	ledValueDebug(15 downto 8) <= data_in(7 downto 0);
	ledValueDebug(7 downto 0) <= data_out(7 downto 0);
	
	ledSegmentsDebug(8)(0) <= oneSecond;
	ledSegmentsDebug(8)(1) <= rst;
	ledSegmentsDebug(8)(2) <= nmi;
	ledSegmentsDebug(8)(3) <= irq;

	ledSegmentsDebug(8)(6) <= we;
	
end behavior;
	
