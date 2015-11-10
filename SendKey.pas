unit  SendKey;
 interface
 uses
     Windows,
     Messages;
 const
     {VK  constants  missing  from  windows.pas}
     VK_SEMICOLON        =  186;  {;}
     VK_EQUAL                =  187;  {=}
     VK_COMMA                =  188;  {,}
     VK_MINUS                =  189;  {-}
     VK_PERIOD              =  190;  {.}
     VK_SLASH                =  191;  {/}
     VK_BACKQUOTE        =  192;  {`}
     VK_LEFTBRACKET    =  219;  {[}
     VK_BACKSLASH        =  220;  {\}
     VK_RIGHTBRACKET  =  221;  {]}
     VK_QUOTE                =  222;  {'}
     downkey  =  #0;
     upkey  =  Chr(KEYEVENTF_KEYUP);  {#2}
 procedure  PlayKeys(const  keys:  String);
 function  StrToKeys(const  s:  String):  String;
 {Alt-F4:  PlayKeys(Chr(vk_menu)+#0+Chr(vk_f4)+#0+Chr(vk_f4)+#2+Chr(vk_menu)+#2)}
 {"exit":  PlayKeys(StrToKeys('exit'+chr(vk_return)));}
 {"EXIT":  PlayKeys(Chr(vk_shift)+downkey+StrToKeys('exit')+Chr(vk_shift)+upkey));}
 {or  short  form:  PlayKeys(Chr(vk_shift)+#0+StrToKeys('exit'));}
 implementation

 function  StrToKeys(const  s:  String):  String;  {keystroke  for  alone  keys}
 var
     i:  Longint;
     c:  Char;
 begin
     for  i  :=  1  to  Length(s)  do
         begin
             c  :=  s[i];
             if  c  in  ['a'..'z']  then  {Upper}
                 c  :=  Chr(Ord(c)  and  not  $20);
             Result  :=  Result  +  c  +  downkey
                                               +  c  +  upkey;
         end;
 end;

 procedure  PlayKeys(const  keys:  String);
 const
     ExtendedKeys  :  set  of  byte  =
         [  vk_up,          vk_down,
             vk_left,      vk_right,
             vk_home,      vk_end,
             vk_prior,    vk_next,
             vk_insert,  vk_delete];
 var
     i,  ips  :  Longint;
     fb,  sb:  Byte;
     keysdown:  String;
     procedure  keybd  (vk,  kp  :  Byte);
     begin
         if  vk  in  ExtendedKeys  then
             kp  :=  kp  +  KEYEVENTF_EXTENDEDKEY;
         keybd_event(vk,  MapVirtualKey(vk,  0),  kp,  0);
     end;
 begin
     keysdown  :=  '';
     for  i  :=  1  to  Length(keys)  div  2  do
         begin
             fb:=  Ord(keys[2*i  -1]);
             sb:=  Ord(keys[2*i]);
             if  sb  =  Ord(downkey)  then
                 keysdown  :=  keysdown  +  Chr(fb)
             else
                 begin
                     ips  :=  pos(Chr(fb),  keysdown);
                     if  ips  >  0  then
                         Delete(keysdown,  ips,  1)
                     else
                         Continue;
                 end;
             keybd(fb,  sb);
         end;
         {Autocomplete}
         for  i  :=  1  to  Length(keysdown)  do
             keybd(Ord(keysdown[i]),  Ord(upkey));
 end;
 end.
