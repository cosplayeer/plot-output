a=addfile("latlon.nc","r")
b=addfile("latlon_hgt.nc","r")
u=a->uReconstructZonal
printVarSummary(u)
v=a->uReconstructMeridional
u10=a->u10
v10=a->v10
pres = a->pressure
rh = a->relhum
t2m = a->t2m
latitude0=a->latitude
latitude = latitude0(27:32)
;print(latitude0)
longitude0=a->longitude
longitude = longitude0(17:22)

print(a)
printVarSummary(rh)
printVarSummary(u10)