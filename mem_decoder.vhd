library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_decoder is
	port(
		addr				: in std_logic_vector(15 downto 0);
		ram_1024_en		: out std_logic := '0';
		io_6530_003_en	: out std_logic := '0';
		io_6530_002_en	: out std_logic := '0';
		ram_6530_en		: out std_logic := '0';
		rom_en			: out std_logic := '0'
	);
end mem_decoder;

architecture behavior of mem_decoder is

begin
	mem_decoder_process : process(addr)
	begin
		if (addr(12 downto 10) = "000") then 											-- k0
			ram_1024_en		<= '1';
			io_6530_003_en	<= '0';
			io_6530_002_en	<= '0';
			ram_6530_en		<= '0';
			rom_en			<= '0';
		elsif (addr(12 downto 10) = "101" and addr(7 downto 6) = "00") then	-- k5
			ram_1024_en		<= '0';
			io_6530_003_en	<= '1';
			io_6530_002_en	<= '0';
			ram_6530_en		<= '0';
			rom_en			<= '0';
		elsif (addr(12 downto 10) = "101" and addr(7 downto 6) = "01") then	-- k5
			ram_1024_en		<= '0';
			io_6530_003_en	<= '0';
			io_6530_002_en	<= '1';
			ram_6530_en		<= '0';
			rom_en			<= '0';
		elsif (addr(12 downto 10) = "101" and addr(7) = '1') then				-- k5
			ram_1024_en		<= '0';
			io_6530_003_en	<= '0';
			io_6530_002_en	<= '0';
			ram_6530_en		<= '1';
			rom_en			<= '0';
		elsif (addr(12 downto 11) = "11") then											-- k6,k7
			ram_1024_en		<= '0';
			io_6530_003_en	<= '0';
			io_6530_002_en	<= '0';
			ram_6530_en		<= '0';
			rom_en			<= '1';
		else 																						-- k1, k2, k3, k4
			ram_1024_en		<= '0';
			io_6530_003_en	<= '0';
			io_6530_002_en	<= '0';
			ram_6530_en		<= '0';
			rom_en			<= '0';
		end if;
	end process;
end behavior;