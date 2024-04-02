library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.ALL; --Kod içerinde aritmetik iþlemler yapacaðýz
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.ALL;


entity kare_surat is

generic(

constant Horizontal_Visible_Area : integer := 1024; --Görünür alan,Front Porch, Back Porch ve Sync Pulse deðerleri generic içerisinde constant olarak tanýmlandý
constant Horizontal_Front_Porch : integer := 48;
constant Horizontal_Back_Porch : integer := 208;
constant Horizontal_Sync_Pulse : integer := 96;

constant Vertical_Visible_Area : integer := 768;
constant Vertical_Front_Porch : integer := 1;
constant Vertical_Back_Porch : integer := 36;
constant Vertical_Sync_Pulse : integer := 3


);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           vgaRed   : out STD_LOGIC_VECTOR(3 downto 0); --RGB
           vgaBlue  : out STD_LOGIC_VECTOR(3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR(3 downto 0);
           Hsync    : out STD_LOGIC; --Yatay Senkronizasyon çiktisi
           Vsync    : out STD_LOGIC  --Dikey Senkronizasyon çiktisi
           
           );
end kare_surat;

architecture Behavioral of kare_surat is

 
signal Horizontal_Position : integer:=0; -- O an yatayda bulunduðumuz piksel deðeri
signal Vertical_Position : integer:=0;   -- O an dikeyde bulunduðumuz piksel deðeri
signal Oynat :std_logic:='0';            -- O anda görünür bölgedeysek oynat sinyali '1' olacak


begin



-----------------------------------------------------------------------------------



Yatay: process(clk,rst) begin

    if(rst='1') then
    
        Horizontal_Position<=0;
   
    elsif(rising_edge(clk)) then
    
        if(Horizontal_Position=Horizontal_Visible_Area + Horizontal_Front_Porch + Horizontal_Back_Porch + Horizontal_Sync_Pulse) then --Yatayda sinira ulasildiysa basa dön 
            
                Horizontal_Position<=0;

            
         else
         
                Horizontal_Position<=Horizontal_Position+1; ----Yatayda sinira ulasilmadiysa 1 saga kay 


        end if;
     end if;
        
end process;

-----------------------------------------------------------------------------------




Dikey: process(clk,rst,Horizontal_Position) begin
 
 
if(rst='1') then   
        Vertical_Position<=0;

elsif(rising_edge(clk)) then


        if(Horizontal_Position=Horizontal_Visible_Area + Horizontal_Front_Porch + Horizontal_Back_Porch + Horizontal_Sync_Pulse) then--Yatayda satirin sonuna gelmiþse if bloguna gir 
             
                if(Vertical_Position=Horizontal_Visible_Area + Vertical_Front_Porch + Vertical_Back_Porch + Vertical_Sync_Pulse) then --Dikayde sinira ulasildiysa basa dön                 
                        Vertical_Position<=0;   
                 else
                      Vertical_Position<=Vertical_Position+1; ----Dikayde sinira ulasilmadiysa bir alt satira geç 
                end if;
        end if;
                
end if;
        

end process;
        
        
----------------------------------------------------------------------------------


Yatay_Senkronizasyon : process(clk,rst,Horizontal_Position) begin

    if(rst='1') then
    
       Hsync<='0';
   
    elsif(rising_edge(clk)) then
    
        if((Horizontal_Position<=Horizontal_Visible_Area+Horizontal_Front_Porch) OR (Horizontal_Position > Horizontal_Visible_Area+Horizontal_Front_Porch+Horizontal_Sync_Pulse)) then -- Sync Pulse içerisnde degise Hsync '1' olacak
            
                Hsync<='1';

            
         else
         
                Hsync<='0';


        end if;
     end if;
        
end process;



-----------------------------------------------------------------------------------


Dikey_Senkronizasyon : process(clk,rst,Vertical_Position) begin

    if(rst='1') then
    
       Vsync<='0';
   
    elsif(rising_edge(clk)) then
    
        if((Vertical_Position<=Vertical_Visible_Area+Vertical_Front_Porch) OR (Vertical_Position > Vertical_Visible_Area + Vertical_Front_Porch+Vertical_Sync_Pulse)) then -- Sync Pulse içerisnde degise Hsync '0' olacak
            
                Vsync<='1';

            
         else
         
                Vsync<='0';


        end if;
     end if;
        
end process;


-----------------------------------------------------------------------------------


Video_Oynat: process(clk,rst, Vertical_Position,Horizontal_Position) begin -- Görünür bölge içerisindeysek oynat sinyali '1' olacak


    if(rst='1') then
    
       oynat<='0';
   
    elsif(rising_edge(clk)) then
    
        if((Horizontal_Position <= Horizontal_Visible_Area)and(Vertical_Position <= Vertical_Visible_Area)) then 
            
                oynat<='1';

            
         else
         
                oynat<='0';


        end if;
     end if;



end process;


-----------------------------------------------------------------------------------

ekrana_basim_islemi: process(clk,rst, Vertical_Position,Horizontal_Position,oynat) begin --Mimaride olusturdugumuz piksel araliklarini ilgili renklere boyariz


    if(rst='1') then
    
        vgaRed  <="0000";--Siyah
        vgaBlue <="0000";
        vgaGreen<="0000";
           
    elsif(rising_edge(clk)) then
    
        if(oynat='1') then 
  -------------------------------------------------------------------------------------------------------------------------      
            if((Vertical_Position<=100)) then
        
            vgaRed  <="1111";--Beyaz
            vgaBlue <="1111";
            vgaGreen<="1111";
 
-------------------------------------------------------------------------------------------------------------------------      
             
            elsif((Vertical_Position>100)and(Vertical_Position<=200)) then
            
                if((Horizontal_Position>=312)and(Horizontal_Position<=700)) then
                
                        vgaRed  <="0000";--Siyah
                        vgaBlue <="0000";
                        vgaGreen<="0000";
                

                
                else
                        vgaRed  <="1111";--Beyaz
                        vgaBlue <="1111";
                        vgaGreen<="1111";
                           
       
               end if; 

-------------------------------------------------------------------------------------------------------------------------      
             
            elsif((Vertical_Position>200)and(Vertical_Position<=300)) then
            
                if((Horizontal_Position>=312)and(Horizontal_Position<=700)) then
                
                        vgaRed  <="1111";--Ten rengi
                        vgaBlue <="1010";
                        vgaGreen<="1101";
                

                
                else
                        vgaRed  <="1111";--Beyaz
                        vgaBlue <="1111";
                        vgaGreen<="1111";
                           
       
               end if;
         
-------------------------------------------------------------------------------------------------------------------------      
             
            elsif((Vertical_Position>300)and(Vertical_Position<=340)) then
            
                if(((Horizontal_Position>=352)and(Horizontal_Position<=390)) or ((Horizontal_Position>=622)and(Horizontal_Position<=660) ) ) then
                
                
                        vgaRed  <="0000";--Siyah
                        vgaBlue <="0000";
                        vgaGreen<="0000";

                        
                elsif(((Horizontal_Position>=312)and(Horizontal_Position<352)) or ((Horizontal_Position>=390)and(Horizontal_Position<622)) or  ((Horizontal_Position>=660)and(Horizontal_Position<=700))) then
                
                        vgaRed  <="1111";--Ten rengi
                        vgaBlue <="1010";
                        vgaGreen<="1101";
                        
                        
                else 
                
                        vgaRed  <="1111";--Beyaz
                        vgaBlue <="1111";
                        vgaGreen<="1111";
                
                
                
                end if;


-------------------------------------------------------------------------------------------------------------------------      
             
            elsif((Vertical_Position>340)and(Vertical_Position<=380)) then
            
                    if((Horizontal_Position>=312)and(Horizontal_Position<=700)) then
                            
                        vgaRed  <="1111";--Ten rengi
                        vgaBlue <="1010";
                        vgaGreen<="1101";
                        
                   else 
                
                        vgaRed  <="1111";--Beyaz
                        vgaBlue <="1111";
                        vgaGreen<="1111";
                

                    end if;

-------------------------------------------------------------------------------------------------------------------------     
             
            elsif((Vertical_Position>380)and(Vertical_Position<=390)) then
                            

                if((Horizontal_Position>=501)and(Horizontal_Position<=511))  then
                
                        vgaRed  <="0000";--Siyah
                        vgaBlue <="0000";
                        vgaGreen<="0000";
                        
                elsif((Horizontal_Position>=312)and(Horizontal_Position<501)) or ((Horizontal_Position>=511)and(Horizontal_Position<=700)) then
                
                        vgaRed  <="1111";--Ten rengi
                        vgaBlue <="1010";
                        vgaGreen<="1101";
                        
                        
                else 
                
                        vgaRed  <="1111";--Beyaz
                        vgaBlue <="1111";
                        vgaGreen<="1111";
                
                
                
                end if;


-------------------------------------------------------------------------------------------------------------------------      
             
            elsif((Vertical_Position>390)and(Vertical_Position<=450)) then
                            
                    if((Horizontal_Position>=312)and(Horizontal_Position<=700)) then
                            
                        vgaRed  <="1111";--Ten rengi
                        vgaBlue <="1010";
                        vgaGreen<="1101";
                        
                   else 
                
                        vgaRed  <="1111";--Beyaz
                        vgaBlue <="1111";
                        vgaGreen<="1111";
                

                    end if;
  

-------------------------------------------------------------------------------------------------------------------------    
             
            elsif((Vertical_Position>450)and(Vertical_Position<=460)) then
                            
                        
                if((Horizontal_Position>=352)and(Horizontal_Position<=660))  then
                
                        vgaRed  <="1111";--Kýrmýzý
                        vgaBlue <="0000";
                        vgaGreen<="0000";
                        
                elsif((Horizontal_Position>=312)and(Horizontal_Position<352)) or ((Horizontal_Position>660)and(Horizontal_Position<=700)) then
                
                        vgaRed  <="1111";--Ten rengi
                        vgaBlue <="1010";
                        vgaGreen<="1101";
                        
                        
                else 
                
                        vgaRed  <="1111";--Beyaz
                        vgaBlue <="1111";
                        vgaGreen<="1111";
                
                
                
                end if;



-------------------------------------------------------------------------------------------------------------------------      
             
            elsif((Vertical_Position>460)and(Vertical_Position<=600)) then
                            
                    if((Horizontal_Position>=312)and(Horizontal_Position<=700)) then
                            
                        vgaRed  <="1111";--Ten rengi
                        vgaBlue <="1010";
                        vgaGreen<="1101";
                        
                   else 
                
                        vgaRed  <="1111";--Beyaz
                        vgaBlue <="1111";
                        vgaGreen<="1111";
                

                    end if;
-------------------------------------------------------------------------------------------------------------------------      

             
            elsif((Vertical_Position>600)and(Vertical_Position<=768)) then
                            
                
                        vgaRed  <="1111";--Beyaz
                        vgaBlue <="1111";
                        vgaGreen<="1111";
                

                 
-------------------------------------------------------------------------------------------------------------------------     

            end if;
          
        else

         
            vgaRed  <="0000";--Siyah
            vgaBlue <="0000";
            vgaGreen<="0000";

              
     end if;

end if;

end process;



end Behavioral;
