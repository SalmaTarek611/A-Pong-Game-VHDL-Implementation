library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;

  
entity clockDivider is
port ( clk: in std_logic;
clock_out: out std_logic;
an_ref: out std_logic_vector(1 downto 0));
end clockDivider;
  
architecture bhv of clockDivider is
  
signal count: std_logic_vector(31 downto 0);
signal tmp : std_logic := '0';
  
begin
  
process(clk)
begin
if(clk'event and clk='1') then
count <=count+1;
if (count = 50000000) then
tmp <= NOT tmp;
count <= "00000000000000000000000000000001";
end if;
end if;
clock_out <= tmp;
end process;
an_ref<=count(20 downto 19);
end bhv;