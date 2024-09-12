library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity main is
Port ( 
clk: in STD_LOGIC;
vgaRed,vgaGreen,vgaBlue: out std_logic_vector(3 downto 0);
Hsync,Vsync: out std_logic;
btnU,btnD,btnR,btnL: in std_logic;
an: out STD_LOGIC_VECTOR(3 downto 0);
seg: out STD_LOGIC_VECTOR(6 downto 0));
end main;

architecture Behavioral of main is
constant paddle_speed: integer:=5;
constant ball_speed: integer:=3;
component VGA_driver is port (
clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           vgaRed,vgaGreen,vgaBlue: out std_logic_vector(3 downto 0);
           Hsync,Vsync: out std_logic;
           new_frame : out std_logic;
	       H_pos : out integer;
	       V_pos : out integer;
	       red_in	 : in std_logic_vector(3 downto 0);
	       green_in  : in std_logic_vector(3 downto 0);
	       blue_in	 : in std_logic_vector(3 downto 0));
end component;
component clockDividerVGA is port ( clk,reset: in std_logic;
clock_out: out std_logic);
end component;
component Debounce_Switch is port (
    i_Clk    : in  std_logic;
    i_Switch : in  std_logic;
    o_Switch : out std_logic
    );
end component;
component clockDivider is port ( clk: in std_logic;
clock_out: out std_logic;
an_ref: out std_logic_vector(1 downto 0));
end component;
  
--VGA Signals 
signal clk_in: std_logic;
signal reset: std_logic:='0';
signal new_frame: std_logic:='0';
signal set_red, set_green, set_blue : std_logic_vector(3 downto 0):= (others => '0');
signal hpos: integer;
signal vpos: integer;

--Paddle Signals 
signal left_paddle_x: integer:=10;
signal left_paddle_y: integer:=200;
signal right_paddle_x: integer:=612;
signal right_paddle_y: integer:=203;
signal up_deb_left,down_deb_left,up_deb_right,down_deb_right:std_logic;

--Ball Signals 
signal ball_x: integer:=300;
signal ball_y: integer:=203;
signal ball_up: std_logic:='0';
signal ball_right: std_logic:='1';
signal ball_speed_x: integer range 0 to 15:= ball_speed;
signal ball_speed_y: integer range 0 to 15:= ball_speed;

--Score 
signal left_score: std_logic_vector(3 downto 0);
signal right_score: std_logic_vector(3 downto 0);
signal left_score_most: std_logic_vector(3 downto 0);
signal right_score_most: std_logic_vector(3 downto 0);
signal left_score_least: std_logic_vector(3 downto 0);
signal right_score_least: std_logic_vector(3 downto 0);
signal LED_IN: std_logic_vector(3 downto 0);
signal anode_ref: std_logic_vector(1 downto 0);
signal clk_score: std_logic;
signal left_wins: std_logic;
signal right_wins: std_logic;
signal restart: std_logic;
begin

clkDiv: clockDividerVGA port map(clk,reset,clk_in);
vga1: VGA_driver port map (clk,reset,vgaRed,vgaGreen,vgaBlue,Hsync,Vsync,new_frame,hpos,vpos,set_red,set_green,set_blue);
clk_score1: clockDivider port map(clk,clk_score,anode_ref);
--Button Debouncing 
D_upL: Debounce_Switch port map(clk_in,btnU,up_deb_left);
D_downL: Debounce_Switch port map(clk_in, btnL,down_deb_left);
D_upR: Debounce_Switch port map(clk_in,btnR,up_deb_right);
D_downR: Debounce_Switch port map(clk_in,btnD,down_deb_right);
process (clk_in) 
begin
 
	if (rising_edge(clk_in)) then
		--2 x 60 pixel paddles
		if ( (hpos >= left_paddle_x and hpos < left_paddle_x + 2) and (vpos >= left_paddle_y and vpos < left_paddle_y + 60) ) then
		if(left_score=10 and right_score<10) then
		    set_red <= "1111";
			set_blue<="0000";
			set_green<="1111";
		  else 
			set_red <= "1111";
			set_blue<="0000";
			set_green<="0000";
		 end if;
		elsif ( (hpos >= right_paddle_x and hpos < right_paddle_x + 2) and (vpos >= right_paddle_y and vpos < right_paddle_y + 60) ) then
		  if(right_score=10 and left_score<10) then
		    set_red <= "1111";
			set_blue<="0000";
			set_green<="1111";
		  else 
			set_red <= "1111";
			set_blue<="0000";
			set_green<="0000";
		 end if;
		elsif((hpos>=ball_x and hpos<ball_x+15) and (vpos >= ball_y and vpos < ball_y + 15) ) then
			set_blue<="1111";
			set_red<="0000";
			set_green<="0000";
		else 
		    set_blue<="0000";
			set_red<="0000";
			set_green<="0000";
		end if;
	end if;
end process;

ball_movement: process(clk_in) 
begin 
if(rising_edge(clk_in)) then 
 if(new_frame='1') then

  if(restart='1') then 
    left_score<="0000";
    right_score<="0000";
    ball_y<=203;
    ball_x<=300;
    ball_speed_x<=ball_speed;
    ball_speed_y<=ball_speed;
    restart<='0';
  else 
    if(ball_y<435 and ball_up='0') then 
        ball_y<=ball_y+ball_speed_y;
    elsif(ball_up='0') then 
        ball_up<='1';
    elsif(ball_y>14 and ball_up='1') then 
        ball_y<=ball_y-ball_speed_y;
    elsif(ball_up='1') then
        ball_up<='0';
    end if;
    
    if(ball_x<605 and ball_right='1' and not(ball_x+15>=right_paddle_x and ball_x+15<=right_paddle_x+2 and ball_y>=right_paddle_y and ball_y<=right_paddle_y+60) ) then 
        ball_x<=ball_x+ball_speed_x;
    elsif(ball_right='1') then 
     ball_right<='0';
        if(not(ball_x+15>=right_paddle_x and ball_x+15<=right_paddle_x+2 and ball_y>=right_paddle_y and ball_y<=right_paddle_y+60)) then
        if(left_score<10 and right_score<10) then 
          left_wins<='0';
          right_wins<='0';
          left_score<=left_score+1;
          if(left_score=10 and right_score<10) then 
          --restart<='1';
          left_score<="0000";
          right_score<="0000";
          end if;
          ball_x<=300;
          ball_y<=203;
        elsif(left_score=10 and right_score<10) then 
          left_wins<='1';
          right_wins<='0';
          left_score<="0000";
          right_score<="0000";
          ball_x<=300;
          ball_y<=203;
          restart<='1';
        elsif(left_score<10 and right_score=10) then
          right_wins<='1';
          left_wins<='0';
          left_score<="0000";
          right_score<="0000";
          ball_x<=300;
          ball_y<=203;
          --restart<='1';
        end if;
        else 
          ball_right<='0';
        end if;
    elsif(ball_x>7 and ball_right='0' and not(ball_x>=left_paddle_x and ball_x<=left_paddle_x+2 and ball_y>=left_paddle_y and ball_y<=left_paddle_y+60)) then 
        ball_x<=ball_x-ball_speed_x;
    elsif(ball_right='0') then 
        ball_right<='1';
        if(not(ball_x>=left_paddle_x and ball_x<=left_paddle_x+2 and ball_y>=left_paddle_y and ball_y<=left_paddle_y+60)) then
        if(right_score<10 and left_score<10) then 
          right_wins<='0';
          left_wins<='0';
          right_score<=right_score+1;
          if(right_score=10 and left_score<10) then 
          --restart<='1';
          left_score<="0000";
          right_score<="0000";
          end if;
          ball_x<=300;
          ball_y<=203;
        elsif(right_score=10 and left_score<10) then
          right_wins<='1';
          left_wins<='0';
          left_score<="0000";
          right_score<="0000";
          ball_x<=300;
          ball_y<=203;
        elsif(right_score<10 and left_score=10) then
          left_wins<='1';
          right_wins<='0';
          left_score<="0000";
          right_score<="0000";
          ball_x<=300;
          ball_y<=203;
        end if; 
        end if;
    end if;
   end if;  
else
		if (set_blue = "1111" and set_red ="1111") then
			ball_right <= not ball_right; 
	    else 
	        ball_right<=ball_right;
		end if;
	  end if;	
	end if;
if(left_score=10) then
  left_score_most<="0001";
  left_score_least<="0000";
else 
  left_score_most<="0000";
  left_score_least<=left_score;
end if;
if(right_score=10) then
  right_score_most<="0001";
  right_score_least<="0000";
else 
  right_score_most<="0000";
  right_score_least<=right_score;
end if;
end process;

paddle_movement: process(clk_in) 
begin 
   if(rising_edge(clk_in) and new_frame='1') then 
       --left player 
       if(up_deb_left='1') then 
          if(left_paddle_y>14) then 
             left_paddle_y<=left_paddle_y-paddle_speed;
           else 
             left_paddle_y<=left_paddle_y;
           end if;
        elsif(down_deb_left='1') then 
           if(left_paddle_y<390) then 
             left_paddle_y<=left_paddle_y+paddle_speed;
           else 
             left_paddle_y<=left_paddle_y;
           end if;
        end if;
        --right player 
        if(up_deb_right='1') then 
          if(right_paddle_y>14) then 
             right_paddle_y<=right_paddle_y-paddle_speed;
           else 
             right_paddle_y<=right_paddle_y;
           end if;
          elsif(down_deb_right='1') then 
           if(right_paddle_y<390) then 
             right_paddle_y<=right_paddle_y+paddle_speed;
           else 
             right_paddle_y<=right_paddle_y;
           end if;
        end if;
       end if;
end process;
process(LED_IN)
begin
case LED_IN is 
when "0000" => seg<="0000001";
when "0001" => seg<="1001111";
when "0010" => seg<="0010010";
when "0011" => seg<="0000110";
when "0100" => seg<="1001100";
when "0101" => seg<="0100100";
when "0110" => seg<="0100000";
when "0111" => seg<="0001111";
when "1000" => seg<="0000000";
when "1001" => seg<="0000100";
when others=> seg<="1111111";
end case;
end process;
process(anode_ref)
begin 
case anode_ref is 
when "00" => an<="1011";
LED_IN<=left_score_least;
when "01" => an<="1110";
LED_IN<=right_score_least;
when "10" => an<="1101";
LED_IN<=right_score_most;
when "11" => an<="0111";
LED_IN<=left_score_most;
end case;
end process;
end behavioral;