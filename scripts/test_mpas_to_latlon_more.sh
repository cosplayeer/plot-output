#!/bin/bash
#generate latlon.nc
rm -rf latlon.nc
#rm -rf latlon_hgt.nc
ncl outputhead.ncl
# set resolution 0.25
#sed -i 's/0.125x0.125/0.25x0.25/1' mpas*ncl
# set resolution 0.125
#sed -i 's/0.25x0.25/0.125x0.125/1' mpas*ncl
# set resolution 0.0625
sed -i 's/0.125x0.125/0.0625x0.0625/1' mpas*ncl
sed -i 's/0.25x0.25/0.0625x0.0625/1' mpas*ncl
# set resolution 0.03125
sed -i 's/0.25x0.25/0.0625x0.0625/1' mpas*ncl
sed -i 's/0.125x0.125/0.0625x0.0625/1' mpas*ncl
sed -i 's/0.0625x0.0625/0.03125x0.03125/1' mpas*ncl
flists=`ls history*nc |head -n 7`
#echo $flists
for i in $flists; do
    echo "hi"$i
    ncl gen_weights=True files=\"$i\" mpas_to_latlon_u.ncl 
    echo "hi"$i
    ncl gen_weights=False files=\"$i\" mpas_to_latlon_u.ncl 
    echo "hi"$i
    ncl gen_weights=True files=\"$i\" mpas_to_latlon_v.ncl 
    echo "hi"$i
    ncl gen_weights=False files=\"$i\" mpas_to_latlon_v.ncl 
    # pressure
    echo "hi"$i
    ncl gen_weights=True files=\"$i\" mpas_to_latlon_pressure.ncl 
    echo "hi"$i
    ncl gen_weights=False files=\"$i\" mpas_to_latlon_pressure.ncl 
    # relhum
    ncl gen_weights=True files=\"$i\" mpas_to_latlon_relhum.ncl 
    ncl gen_weights=False files=\"$i\" mpas_to_latlon_relhum.ncl 
    # t2m
    ncl gen_weights=True files=\"$i\" mpas_to_latlon_t2m.ncl 
    ncl gen_weights=False files=\"$i\" mpas_to_latlon_t2m.ncl 
    # u10
    ncl gen_weights=True files=\"$i\" mpas_to_latlon_u10.ncl 
    ncl gen_weights=False files=\"$i\" mpas_to_latlon_u10.ncl 
    # v10
    ncl gen_weights=True files=\"$i\" mpas_to_latlon_v10.ncl 
    ncl gen_weights=False files=\"$i\" mpas_to_latlon_v10.ncl 

    ###
    rm -rf latlon_hgt.nc
    echo "hi"$i
    ncl gen_weights=True files=\"$i\" mpas_to_latlon_hgt.ncl 
    echo "hi"$i
    ncl gen_weights=False files=\"$i\" mpas_to_latlon_hgt.ncl 
#generate output.csv
#ncl outputcsv.ncl
done
