
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA_driver is
Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           vgaRed,vgaGreen,vgaBlue: out std_logic_vector(3 downto 0);
           Hsync,Vsync: out std_logic;
           new_frame : out std_logic;
	       H_pos : out integer;
	       V_pos : out integer;
	       red_in	 : in std_logic_vector(3 downto 0);
	       green_in  : in std_logic_vector(3 downto 0);
	       blue_in	 : in std_logic_vector(3 downto 0));
end VGA_driver;

architecture Behavioral of VGA_driver is
constant HD: integer:= 639;
constant HFP : integer := 16;
constant HSP : integer := 96;
constant HBP : integer := 48;

constant VD : integer := 479;
constant VFP : integer := 10;
constant VSP : integer := 2;
constant VBP : integer := 33; 

signal clk_in:std_logic;
signal H_count,V_count:integer:=0;

component clockDividerVGA is port ( clk,reset: in std_logic;
clock_out: out std_logic);
end component;

begin
H_pos<=H_count;
V_pos<=V_count;
clock: clockDividerVGA port map(clk,reset,clk_in);
H_and_V_count: process(clk_in,reset)
begin
  if (reset='1') then 
     H_count<=0;
     V_count<=0;
  elsif (clk_in'event and clk_in='1') then 
     if (H_count= HD + HFP + HSP + HBP) then
       H_count<=0;
       if (V_count= VD + VFP + VSP + VBP) then
         V_count<=0;
         new_frame<='1';
       else 
          V_count<=V_count+1;
       end if;
     else 
       new_frame<='0';
       H_count<=H_count+1;
     end if;
   end if;
end process;

HSYNC_proc : process(clk_in,reset,H_count)
begin 
  if(reset='1') then 
    Hsync<='0';
  elsif(clk_in='1' and clk_in'event)then  
    if(H_count<= (HD+ HFP) or H_count>=(HD+HFP+HSP)) then
      Hsync<='0';
    else 
      Hsync<='1';
    end if;
  end if;
end process;

VSYNC_proc : process(clk_in,reset,V_count)
begin 
if(reset='1') then 
    Vsync<='0';
  elsif(clk_in='1' and clk_in'event)then  
    if(V_count<= (VD+ VFP) or V_count>=(VD+VFP+VSP)) then
      Vsync<='0';
    else 
      Vsync<='1';
    end if;
  end if;
end process;

draw_frame: process(clk_in, H_count, V_count)
begin 
if(clk_in='1' and clk_in'event) then 
  if(H_count>HD or V_count>VD) then 
   vgaRed<="0000";
   vgaGreen<="0000";
   vgaBlue<="0000";
  elsif((H_count>=3 and H_count<=624 and V_count>=10 and V_count<=14) or (H_count>=3 and H_count<=624 and V_count>=450 and V_count<=454) or  (V_count>=10 and V_count<=454 and H_count>=3 and H_count<=7) or (V_count>=10 and V_count<=454 and H_count>=620 and H_count<=624)) then 
   vgaRed<="0000";
   vgaGreen<="1111";
   vgaBlue<="0000";
  else 
   vgaRed<=red_in;
   vgaGreen<=green_in;
   vgaBlue<=blue_in;
  end if;
end if;
end process;


end Behavioral;
