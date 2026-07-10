\ ── Scan USB ──
cr ." Init XHCI..." cr
usb:init . cr

cr ." Listing devices..." cr
usb:devices
dup 0= if 
  drop cr ." [Aucun peripherique]" cr
else
  cr ." Total: " dup . cr
  >r
  r@ 0 do
    ."  Device " i . ." : "
    ." Conf:"  .      \ conf
    ."  Pid:"  .      \ pid
    ."  Vid:"  .      \ vid
    ."  Speed:" .     \ speed
    ."  Port:" .      \ port
    ."  Slot:" .      \ slot
    cr
  loop
  r> drop
then
cr ." [OK]" cr
