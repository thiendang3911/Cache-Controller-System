transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/ASUS/Downloads/doan {C:/Users/ASUS/Downloads/doan/controller.v}
vlog -vlog01compat -work work +incdir+C:/Users/ASUS/Downloads/Cache/Cache {C:/Users/ASUS/Downloads/Cache/Cache/address_logic.v}
vlog -vlog01compat -work work +incdir+C:/Users/ASUS/Downloads/Cache/Cache {C:/Users/ASUS/Downloads/Cache/Cache/cache_memory.v}
vlog -vlog01compat -work work +incdir+C:/Users/ASUS/Downloads/Cache/Cache {C:/Users/ASUS/Downloads/Cache/Cache/comparator.v}
vlog -vlog01compat -work work +incdir+C:/Users/ASUS/Downloads/Cache/Cache {C:/Users/ASUS/Downloads/Cache/Cache/data_ram_1024x16.v}
vlog -vlog01compat -work work +incdir+C:/Users/ASUS/Downloads/Cache/Cache {C:/Users/ASUS/Downloads/Cache/Cache/tag_ram_1024x12.v}
vlog -vlog01compat -work work +incdir+C:/Users/ASUS/Downloads/Cache/Cache {C:/Users/ASUS/Downloads/Cache/Cache/datapath_top.v}
vlog -vlog01compat -work work +incdir+C:/Users/ASUS/Downloads/Cache/Cache {C:/Users/ASUS/Downloads/Cache/Cache/cache_system_top.v}
vlog -vlog01compat -work work +incdir+C:/Users/ASUS/Downloads/Cache/Cache {C:/Users/ASUS/Downloads/Cache/Cache/issp.v}
vlog -vlog01compat -work work +incdir+C:/Users/ASUS/Downloads/Cache/Cache {C:/Users/ASUS/Downloads/Cache/Cache/DE2_Cache_Tester.v}
vlog -vlog01compat -work work +incdir+C:/Users/ASUS/Downloads/Cache/Cache {C:/Users/ASUS/Downloads/Cache/Cache/sdram_controller_ip.v}

vlog -vlog01compat -work work +incdir+C:/Users/ASUS/Downloads/Cache/Cache {C:/Users/ASUS/Downloads/Cache/Cache/cache_system_top_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneii_ver -L rtl_work -L work -voptargs="+acc"  cache_system_top_tb

add wave *
view structure
view signals
run -all
