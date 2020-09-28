;--------------output csv-------------------
foutf = "output" + ".csv"
;bbb = systemfunc("/bin/rm -f "+ foutf )
header = (/"timestamp, windspeed, winddir"/)
hlist=[/header/]
write_table(foutf,"w",hlist,"%s")
