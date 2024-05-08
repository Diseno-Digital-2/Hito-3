onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_hito3_completo/nRst
add wave -noupdate /test_hito3_completo/clk
add wave -noupdate /test_hito3_completo/fin
add wave -noupdate -radix decimal /test_hito3_completo/posicion
add wave -noupdate -radix decimal /test_hito3_completo/U2/almacen
add wave -noupdate -radix decimal /test_hito3_completo/U2/contador
add wave -noupdate -radix decimal /test_hito3_completo/offset
add wave -noupdate /test_hito3_completo/fin_offset
add wave -noupdate -divider Filtro
add wave -noupdate -radix decimal /test_hito3_completo/posicion
add wave -noupdate -radix decimal /test_hito3_completo/offset
add wave -noupdate -radix decimal /test_hito3_completo/U3/posicion_ajustada_offset
add wave -noupdate /test_hito3_completo/fin
add wave -noupdate -divider Registros
add wave -noupdate -radix decimal /test_hito3_completo/U3/posicionT0
add wave -noupdate -radix decimal /test_hito3_completo/U3/posicionT1
add wave -noupdate -radix decimal /test_hito3_completo/U3/posicionT2
add wave -noupdate -radix decimal /test_hito3_completo/U3/posicionT3
add wave -noupdate -radix decimal /test_hito3_completo/U3/posicionT4
add wave -noupdate -radix decimal /test_hito3_completo/U3/posicionT5
add wave -noupdate -radix decimal /test_hito3_completo/U3/posicionT6
add wave -noupdate -radix decimal /test_hito3_completo/U3/posicionT7
add wave -noupdate -radix decimal /test_hito3_completo/U3/suma_posiciones
add wave -noupdate -radix decimal /test_hito3_completo/posicion_procesada
add wave -noupdate /test_hito3_completo/fin_procesado
add wave -noupdate -divider Leds
add wave -noupdate -radix decimal /test_hito3_completo/U4/posicion_reg
add wave -noupdate /test_hito3_completo/LEDs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1545885 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {4060692 ps} {4412280 ps}
