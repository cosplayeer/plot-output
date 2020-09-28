load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

   ;
   ; Whether to generate remapping weight files, or 
   ;   to actually regrid fields
   ;
   ;gen_weights = True
   ;gen_weights = False 
   regrid = True

   ;
   ;... read input MPAS files:
   ;
   ;files = systemfunc("ls history.*.nc |head -n 1")
   s = files
   suffix = get_file_suffix(s,1)
   strs = str_split(suffix,"_.-")
   ;_time2 = strs(0) + " " + strs(1) + ":" + strs(2) + ":00"
   time_hours = cd_inv_calendar(tointeger(strs(0)),tointeger(strs(1)),tointeger(strs(2)),tointeger(strs(3)),00,00, "hours since 1800-01-01 00:00", 0)
   _time = time_hours
   ;_time = tostring(strs(0) + strs(1) + strs(2) + strs(3)) ; +strs(4)) ; + "00")
   print(_time)
   _time!0 = "time_hours"
   f = addfiles(files,"r")

   ;
   ;... get lat/lon coordinates from first input file
   ;
   r2d  = 180.0d/(atan(1)*4.0d) ; conversion from radians to degrees.
   lonCellSrc = f[0]->lonCell * r2d
   latCellSrc = f[0]->latCell * r2d
;
   ;... interpolation to 1-deg latitude-longitude grid:
   ;
   opt = True
   opt@ForceOverwrite = True
   opt@SrcGridLon = lonCellSrc ; source grid lon input.
   opt@SrcGridLat = latCellSrc ; source grid lat input.
   opt@SrcGridType = "unstructured"
   ;opt@DstGridType = "0.5x0.5" ; destination grid
   opt@DstGridType = "0.03125x0.03125" ; destination grid
   opt@DstLLCorner = (/ 30.00d, 90.00d /) ; lat, lon
   opt@DstURCorner = (/ 40.00d,  100.00d /)
   ;opt@DstLLCorner = (/-89.50d, -179.50d /)
   ;opt@DstURCorner = (/ 89.50d,  179.50d /)
   ;opt@DstLLCorner = (/-90.00d, -180.00d /)
   ;opt@DstURCorner = (/ 90.00d,  180.00d /)
   opt@SrcFileName = "src_grid.nc"
   opt@DstFileName = "dst_grid.nc"
   opt@WgtFileName = "weights.nc"

   ;
   ;... get dimension sizes and predefine the coordinate variables and their dimensionality:
   ;
   ;mpas = f[:]->uReconstructMeridional
   mpas = f[:]->zgrid

   dims = dimsizes(mpas)
   rank = dimsizes(dims)
   print("rank: "+rank)
   nTime   = 1
   nCells  = dims(0)
   if (rank .eq. 3) then
      nLevels = dims(2)
   end if
   print("nTime   = "+nTime  )
   print("nCells  = "+nCells )
   if (rank .eq. 2) then
      nLevels = dims(1)
      print("nLevels = "+nLevels)
   end if
   print("          ")
   delete(dims)

   ; 3-d fields need to have the nCells and nVertLevels dimensions swapped
   if (rank .eq. 3) then
      ;mpas_reorder = mpas(Time|:,nVertLevels|:,nCells|:)
      mpas_reorder = mpas(Time|:,nVertLevelsP1|:,nCells|:)
   else
      mpas_reorder = mpas(nVertLevelsP1|:,nCells|:)
   end if
   delete(mpas)
   if (gen_weights) then
      if (rank .eq. 3) then
         mpas_regrid = ESMF_regrid(mpas_reorder(0,:,:),opt)
      else
         mpas_regrid = ESMF_regrid(mpas_reorder(0,:),opt)
      end if

   else
   if (regrid) then

      mpas_regrid = ESMF_regrid_with_weights(mpas_reorder,opt@WgtFileName,False)
      dims = dimsizes(mpas_regrid)
      rank = dimsizes(dims)
      print("hi rank")
      print(rank)

      print(dims)
      nTime   = 1 ;dims(0)
      print("nTime   = "+nTime)
      if (rank .eq. 4) then
         nLevels = dims(1)
         nLat    = dims(2)
         nLon    = dims(3)
         print("nLevels = "+nLevels)
      else
         nLevels = dims(0)
         nLat    = dims(1)
         nLon    = dims(2)
      end if
      print("nLevels    = "+nLevels )
      print("nLat    = "+nLat )
      print("nLon    = "+nLon )
      mpas_regrid_at_missing_value = mpas_regrid@_FillValue
      printVarSummary(mpas_regrid)

      ;
      ;... open output NetCDF file
      ;
      filenames = "latlon_hgt.nc"
      if (fileexists(filenames)) then
          fout  = addfile (filenames, "w")
      else
          fout  = addfile (filenames, "c")
      end if 

      if (rank .eq. 4) then
         dimNames = (/"Time", "lat" , "lon" , "levels"/)
         dimSizes = (/-1    , nLat  , nLon  , nLevels /)
         dimUnlim = (/True  , False , False , False   /)
	print("rank .eq. 4")
      else
         dimNames = (/"levels", "lat" , "lon"/)
         dimSizes = (/nLevels    , nLat  , nLon/)
         dimUnlim = (/False  , False , False/)
	print("rank .eq. 3")
      end if
      filedimdef(fout,dimNames,dimSizes,dimUnlim)

      lat = fspan(30.00d,40.00d,nLat)
      lon = fspan(90.00d,100.00,nLon)
      ;lat = fspan(-90.00d,90.00d,nLat)
      ;lon = fspan(-180.00d,180.00,nLon)

      ;
      ;copy global atttibutes from the input to the output file:
      ;
      fileattdef(fout,f[0])

      ;
      ;... predefine the dimensionality of the variables to be written out:
      ;
      filevardef(fout,"latitude" ,typeof(lat)  ,(/"lat"/))
      filevardef(fout,"longitude",typeof(lon)  ,(/"lon"/))
      filevardef(fout,"longitude",typeof(lon)  ,(/"lon"/))
      if (rank .eq. 4) then
         filevardef(fout,"zgrid",typeof(mpas_regrid),(/"Time","levels","lat","lon"/))
      else
         filevardef(fout,"zgrid",typeof(mpas_regrid),(/"levels","lat","lon"/))
      end if
      filevardef(fout,"time",(/"double"/)  ,"ncl_scalar")
      filevarattdef(fout,"time",_time)

      ;
      ;... output data:
      ;
      fout->latitude  = (/lat/)
      fout->longitude = (/lon/)
      fout->zgrid = (/mpas_regrid/)
      print(_time)
      fout->time = _time

   end if
   end if

end

