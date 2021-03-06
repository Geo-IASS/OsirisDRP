;+
; NAME:
;
;   pg_plotimage
;
; PURPOSE:
;
;  Plots an image with coordinates pretty much the same way one would use the
;  plot command
;
; CATEGORY:
;
; image display utils
;
; CALLING SEQUENCE:
;
; pg_plotimage,im,x,y [,optional inputs see below]
;
; INPUTS:
;
; im: an n-by-m array
;  x: an n-element array (if not given, [1,2,...,n] is used)
;  y: an m-element array (if not given, [1,2,...,m] is used)
;
; OPTIONAL INPUTS:
;
; addcmd: set to add this command to a currently open resizeable cgWindow
; axiscolor: set to the name of the axis color
; background: set to the name of the background color
; fulledges: set this keyword to have fully sized pixels at the edge of the
; images. It will still look funny in log-scale however.
; psresolution: ps resolution in dpi (default 150)
; no_rescale: use tv instead than tvscl to plot the image
; title: the plot main title
; position: plot position
; window: set to use the resizeable graphics window cgWindow to display this command
; all the graphical optional ketwords starting with x- and y-
;
;
; OUTPUTS:
;
; NONE
;
; COMMON BLOCKS:
;
; NONE
;
; SIDE EFFECTS:
;
; a plot is generated to the current graphics device
;
; RESTRICTIONS:
;
; only tested on X and PS devices, should work with WIN, not sure about Z-buffer though
;
; PROCEDURE:
;
; Every pixel of the final image (to be plotted) is generated by interpolating
; the original dataset at the coordinates of the pixel to be displayed. 
;
; EXAMPLE:
;
;  loadct,5
;  im=dist(128,128)
;  x=findgen(128)
;  y=findgen(128)
;  pg_plotimage,im,x,y,xrange=[5,100],yrange=[5,100],/xstyle,/ystyle,/xlog
;
;
; AUTHOR:
; Paolo Grigis, SAO, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 25-FEB-2008 written PG
; 26-FEB-2008 made x and y optional PG
; 31-MAR-2008 added /isotropic PG
; 02-APR-2008 fixed bug of /isotropic PG
; 16-JAN-2008 added /fulledges option to have full 
;             sized edge pixels as requested by Brian Larsen on the IDL newsgroup
;             (it's actually a good idea, but didn't make it the default to
;             avoid breaking backwards compatibility) PG
; 18-MAY-2011 turned into a Coyote Graphic command DWF
;
;-


PRO pg_plotimage,im,x,y,isotropic=isotropic,fulledges=fulledges,_extra=_extra $
                ,xrange=xrange,yrange=yrange,position=position,title=title $
                ,xstyle=xstyle,ystyle=ystyle,smooth=smooth,xlog=xlog,ylog=ylog $
                ,no_rescale=no_rescale,psresolution=psresolution $
                ,xcharsize=xcharsize,xgridstyle=xgridstyle,xminor=xminor,xthick=xthick $
                ,xtick_get=xtick_get,xtickformat=xtickformat,xtickinterval=xtickinterval $
                ,xticklayout=xticklayout,xticklen=xticklen,xtickname=xtickname,xticks=xticks $
                ,xtickunits=xtickunits,xtickv=xtickv,xtitle=xtitle $
                ,ycharsize=ycharsize,ygridstyle=ygridstyle,yminor=yminor,ythick=ythick $
                ,ytick_get=ytick_get,ytickformat=ytickformat,ytickinterval=ytickinterval $
                ,yticklayout=yticklayout,yticklen=yticklen,ytickname=ytickname,yticks=yticks $
                ,ytickunits=ytickunits,ytickv=ytickv,ytitle=ytitle,noerase=noerase $
                ,axiscolor=axiscolor, background=background, layout=layout, window=window, addcmd=addcmd


    Compile_Opt idl2

    Catch, theError
    IF theError NE 0 THEN BEGIN
        Catch, /CANCEL
        void = cgErrorMsg()
        IF N_Elements(thisMulti) NE 0 THEN !P.Multi = thisMulti
        IF N_Elements(currentState) NE 0 THEN cgSetColorState, currentState
        RETURN
    ENDIF
    
    ; Set up PostScript device for working with colors.
    IF !D.Name EQ 'PS' THEN Device, COLOR=1, BITS_PER_PIXEL=8
    
    ; Check parameters.
    IF N_Params() EQ 0 THEN BEGIN
        Print, 'USE SYNTAX: pg_plotimage, im, x, y'
        RETURN
    ENDIF
    
    ; Pay attention to !P.Noerase in setting the NOERASE kewyord. This must be
    ; done BEFORE checking the LAYOUT properties.
    IF !P.NoErase NE 0 THEN noerase = !P.NoErase ELSE noerase = Keyword_Set(noerase)
    
    ; Do they want this plot in a resizeable graphics window?
    IF Keyword_Set(addcmd) THEN window = 1
    IF Keyword_Set(window) AND ((!D.Flags AND 256) NE 0) THEN BEGIN
            
        ; Special treatment for overplotting or adding a command.
        IF Keyword_Set(overplot) OR Keyword_Set(addcmd) THEN BEGIN
        cgWindow, 'pg_plotimage', im, x, y, isotropic=isotropic,fulledges=fulledges,_extra=_extra $
                ,xrange=xrange,yrange=yrange,position=position,title=title $
                ,xstyle=xstyle,ystyle=ystyle,smooth=smooth,xlog=xlog,ylog=ylog $
                ,no_rescale=no_rescale,psresolution=psresolution $
                ,xcharsize=xcharsize,xgridstyle=xgridstyle,xminor=xminor,xthick=xthick $
                ,xtick_get=xtick_get,xtickformat=xtickformat,xtickinterval=xtickinterval $
                ,xticklayout=xticklayout,xticklen=xticklen,xtickname=xtickname,xticks=xticks $
                ,xtickunits=xtickunits,xtickv=xtickv,xtitle=xtitle $
                ,ycharsize=ycharsize,ygridstyle=ygridstyle,yminor=yminor,ythick=ythick $
                ,ytick_get=ytick_get,ytickformat=ytickformat,ytickinterval=ytickinterval $
                ,yticklayout=yticklayout,yticklen=yticklen,ytickname=ytickname,yticks=yticks $
                ,ytickunits=ytickunits,ytickv=ytickv,ytitle=ytitle,noerase=noerase $
                ,axiscolor=axiscolor, background=background, layout=layout, addcmd=1
             RETURN
        ENDIF
        
        ; Open a new window or replace the current commands, as required.
        currentWindow = cgQuery(/CURRENT, COUNT=wincnt)
        IF wincnt EQ 0 THEN replaceCmd = 0 ELSE replaceCmd=1
        cgWindow, 'pg_plotimage', im, x, y, isotropic=isotropic,fulledges=fulledges,_extra=_extra $
                ,xrange=xrange,yrange=yrange,position=position,title=title $
                ,xstyle=xstyle,ystyle=ystyle,smooth=smooth,xlog=xlog,ylog=ylog $
                ,no_rescale=no_rescale,psresolution=psresolution $
                ,xcharsize=xcharsize,xgridstyle=xgridstyle,xminor=xminor,xthick=xthick $
                ,xtick_get=xtick_get,xtickformat=xtickformat,xtickinterval=xtickinterval $
                ,xticklayout=xticklayout,xticklen=xticklen,xtickname=xtickname,xticks=xticks $
                ,xtickunits=xtickunits,xtickv=xtickv,xtitle=xtitle $
                ,ycharsize=ycharsize,ygridstyle=ygridstyle,yminor=yminor,ythick=ythick $
                ,ytick_get=ytick_get,ytickformat=ytickformat,ytickinterval=ytickinterval $
                ,yticklayout=yticklayout,yticklen=yticklen,ytickname=ytickname,yticks=yticks $
                ,ytickunits=ytickunits,ytickv=ytickv,ytitle=ytitle,noerase=noerase $
                ,axiscolor=axiscolor, background=background, layout=layout, replaceCmd=replaceCmd            
         RETURN
    ENDIF
    
    ; Get the current color table vectors.
    TVLCT, rr, gg, bb, /GET
    
    ; Going to do this in decomposed color, if possible.
    cgSetColorState, 1, CURRENTSTATE=currentState
    
    ; Set up the layout, if necessary.
    IF N_Elements(layout) NE 0 THEN BEGIN
       thisMulti = !P.Multi
       totalPlots = layout[0]*layout[1]
       !P.Multi = [0,layout[0], layout[1], 0, 0]
       IF layout[2] EQ 1 THEN BEGIN
            noerase = 1
            !P.Multi[0] = 0
       ENDIF ELSE BEGIN
            !P.Multi[0] = totalPlots - layout[2] + 1
       ENDELSE
    ENDIF

  nx=n_elements(x)
  ny=n_elements(y)


  s=size(im)
  IF s[0] NE 2 THEN Message, 'Only 2D images are allowed.
  IF nx EQ 0 THEN x=findgen(s[1])+1
  IF ny EQ 0 THEN y=findgen(s[2])+1
  IF n_elements(background) EQ 0 THEN background = 'white'  
  IF n_elements(axiscolor) EQ 0 THEN axiscolor = 'opposite'
  
  
  IF n_elements(xrange) NE 2 THEN BEGIN 
     IF keyword_set(fulledges) THEN BEGIN 
        xrange=[min(x)-(x[1]-x[0])*0.5,max(x)+(x[nx-1]-x[nx-2])*0.5] 
     ENDIF $ 
     ELSE BEGIN 
        xrange=[min(x),max(x)]
     ENDELSE 
  ENDIF

  IF n_elements(yrange) NE 2 THEN BEGIN 
     IF keyword_set(fulledges) THEN BEGIN 
        yrange=[min(y)-(y[1]-y[0])*0.5,max(y)+(y[ny-1]-y[ny-2])*0.5] 
     ENDIF $
     ELSE BEGIN 
        yrange=[min(y),max(y)] 
     ENDELSE 
  ENDIF

;  IF (n_elements(position) NE 4) AND !P.multi[1] EQ 0 THEN position=[0.1,0.1,0.9,0.9]
  IF n_elements(xlog) NE 1 THEN xlog=0
  IF n_elements(ylog) NE 1 THEN ylog=0
  

  ;establish plot coordinates, draw axis
  cgplot,[0,0],xrange=xrange,yrange=yrange,position=position,title=title $
            ,xstyle=xstyle,ystyle=ystyle,xlog=xlog,ylog=ylog,/nodata,isotropic=isotropic $
            ,xcharsize=xcharsize,xgridstyle=xgridstyle,xminor=xminor,xthick=xthick $
            ,xtick_get=xtick_get,xtickformat=xtickformat,xtickinterval=xtickinterval $
            ,xticklayout=xticklayout,xticklen=xticklen,xtickname=xtickname,xticks=xticks $
            ,xtickunits=xtickunits,xtickv=xtickv,xtitle=xtitle $
            ,ycharsize=ycharsize,ygridstyle=ygridstyle,yminor=yminor,ythick=ythick $
            ,ytick_get=ytick_get,ytickformat=ytickformat,ytickinterval=ytickinterval $
            ,yticklayout=yticklayout,yticklen=yticklen,ytickname=ytickname,yticks=yticks $
            ,ytickunits=ytickunits,ytickv=ytickv,ytitle=ytitle,noerase=noerase,_extra=_extra $
            ,color=axiscolor, background=background

  ;get pixel size of window
  xsize=!D.x_size
  ysize=!D.y_size

  position=[!X.window[0],!Y.window[0],!X.window[1],!Y.window[1]]

  IF !D.name EQ 'PS' THEN BEGIN 
     IF n_elements(psresolution) NE 1 THEN psresolution=150
     xsize=xsize/(2.54*!D.x_px_cm)*psresolution
     ysize=ysize/(2.54*!D.y_px_cm)*psresolution
  ENDIF



  ;compute pixel size of plot area
  dxpix=round((position[2]-position[0])*xsize)
  dypix=round((position[3]-position[1])*ysize)


  ;compute coordinates in data space for the all the *pixels* of the image to be displayed
  ;in both linear and log scale
  IF xlog EQ 1 THEN BEGIN 
     nxpix=10^(!x.crange[0]+findgen(dxpix)/(dxpix-1.)*(!X.crange[1]-!X.crange[0]))
  ENDIF $
  ELSE BEGIN 
     nxpix=!x.crange[0]+findgen(dxpix)/(dxpix-1.)*(!X.crange[1]-!X.crange[0])
  ENDELSE 

  IF ylog EQ 1 THEN BEGIN
     nypix=10^(!y.crange[0]+findgen(dypix)/(dypix-1.)*(!Y.crange[1]-!Y.crange[0]))
  ENDIF $
  ELSE BEGIN 
     nypix=!y.crange[0]+findgen(dypix)/(dypix-1.)*(!Y.crange[1]-!Y.crange[0])
  ENDELSE 


  ;axis range in data coordinates
  actualxrange=xlog EQ 0 ? !x.crange : 10.^!x.crange
  actualyrange=ylog EQ 0 ? !y.crange : 10.^!y.crange

  
  ;we have two coordinates, x,y and npix,npiy
  ;but we only need to apply the interpolation in the intersection
  ;between x and xrange, and y and yrange

  ;if the bottom, top, right, left lines muct be
  ;one pixel size (instead of half)
  IF keyword_set(fulledges) THEN BEGIN 

  
     neededcoordindx=where(nxpix GE min(x)-(x[1]-x[0])*0.5 AND nxpix LE max(x)+(x[nx-1]-x[nx-2])*0.5,countx)
     neededcoordindy=where(nypix GE min(y)-(y[1]-y[0])*0.5 AND nypix LE max(y)+(y[ny-1]-y[ny-2])*0.5,county)

  ENDIF $
  ELSE BEGIN 
     ;pixels coordinates only between min(x) and max(x), min(y) and max(y)
     neededcoordindx=where(nxpix GE min(x) AND nxpix LE max(x),countx)
     neededcoordindy=where(nypix GE min(y) AND nypix LE max(y),county)
  ENDELSE


  ;original image pixels only in xrange and yrange
  neededindx=where(x GE actualxrange[0] AND x LE actualxrange[1],countx2)
  neededindy=where(y GE actualyrange[0] AND y LE actualyrange[1],county2)
  
  IF (countx EQ 0) OR (county EQ 0) THEN RETURN
  IF (countx2 EQ 0) OR (county2 EQ 0) THEN RETURN


  ;interpolates the coordinates to get back to index space for the new image
  xint=interpol(findgen(countx2),x[neededindx],nxpix[neededcoordindx])
  yint=interpol(findgen(county2),y[neededindy],nypix[neededcoordindy])

  ;this makes blocky pixels if interpolation is not wanted
  IF NOT keyword_set(smooth) THEN BEGIN 
     xint=round(xint)
     yint=round(yint)
  ENDIF

  ;interpolate the original image to get the new image to display
  ;the new image size is given by the pixel in the plot area
  newimage=interpolate(im[min(neededindx):max(neededindx),min(neededindy):max(neededindy)],xint,yint,/grid) 
 
  IF keyword_set(fulledges) THEN BEGIN 

                                ;get coordinates of lower left & upper right pixel in normalized coordinates
     normcoordllc=convert_coord(max([min(x)-(x[1]-x[0])*0.5,actualxrange[0]]),max([min(y)-(y[1]-y[0])*0.5,actualyrange[0]]),/data,/to_norm)
     normcoordurc=convert_coord(min([max(x)+(x[nx-1]-x[nx-2])*0.5,actualxrange[1]]),min([max(y)+(y[ny-1]-y[ny-2])*0.5,actualyrange[1]]),/data,/to_norm)

  ENDIF $
  ELSE BEGIN 
                                ;get coordinates of lower left & upper right pixel in normalized coordinates
     normcoordllc=convert_coord(max([min(x),actualxrange[0]]),max([min(y),actualyrange[0]]),/data,/to_norm)
     normcoordurc=convert_coord(min([max(x),actualxrange[1]]),min([max(y),actualyrange[1]]),/data,/to_norm)
    
  ENDELSE 



  ;plot image on the screen, rescaling depends on the value of rescale kyword
  ;xsize,ysize needed for PS output only
  cgSetColorState, 0, CURRENT=current
  IF keyword_set(no_rescale) THEN $
     tv,newimage,normcoordllc[0],normcoordllc[1],/normal $
       ,xsize=normcoordurc[0]-normcoordllc[0],ysize=normcoordurc[1]-normcoordllc[1] $
  ELSE $     
     tvscl,newimage,normcoordllc[0],normcoordllc[1],/normal $
          ,xsize=normcoordurc[0]-normcoordllc[0],ysize=normcoordurc[1]-normcoordllc[1]
  cgSetColorState, current

  ;replot the x- and y- axis, as they may have been overwritten by the image
  ;most of the stuff is just keyword propagation
  IF ylog EQ 1 THEN BEGIN 
      cgaxis,1,10.^!Y.crange[0],xaxis=0,xlog=xlog,xstyle=xstyle,xrange=xrange,/data $
                ,xcharsize=xcharsize,xgridstyle=xgridstyle,xminor=xminor,xthick=xthick $
                ,xtick_get=xtick_get,xtickformat=xtickformat,xtickinterval=xtickinterval $
                ,xticklayout=xticklayout,xticklen=xticklen,xtickname=xtickname,xticks=xticks $
                ,xtickunits=xtickunits,xtickv=xtickv,xtitle=xtitle, color=axiscolor
     cgaxis,1,10.^!Y.crange[1],xaxis=1,xlog=xlog,xstyle=xstyle,xrange=xrange,/data,xtickname=REPLICATE(' ', 30)  $
                ,xcharsize=xcharsize,xgridstyle=xgridstyle,xminor=xminor,xthick=xthick $
                ,xtick_get=xtick_get,xtickformat=xtickformat,xtickinterval=xtickinterval $
                ,xticklayout=xticklayout,xticklen=xticklen,xticks=xticks $
                ,xtickunits=xtickunits,xtickv=xtickv, color=axiscolor
  ENDIF ELSE BEGIN 
     cgaxis,1,!Y.crange[0],xaxis=0,xlog=xlog,xstyle=xstyle,xrange=xrange,/data $
                ,xcharsize=xcharsize,xgridstyle=xgridstyle,xminor=xminor,xthick=xthick $
                ,xtick_get=xtick_get,xtickformat=xtickformat,xtickinterval=xtickinterval $
                ,xticklayout=xticklayout,xticklen=xticklen,xtickname=xtickname,xticks=xticks $
                ,xtickunits=xtickunits,xtickv=xtickv,xtitle=xtitle, color=axiscolor
     cgaxis,1,!Y.crange[1],xaxis=1,xlog=xlog,xstyle=xstyle,xrange=xrange,/data,xtickname=REPLICATE(' ', 30)  $
                ,xcharsize=xcharsize,xgridstyle=xgridstyle,xminor=xminor,xthick=xthick $
                ,xtick_get=xtick_get,xtickformat=xtickformat,xtickinterval=xtickinterval $
                ,xticklayout=xticklayout,xticklen=xticklen,xticks=xticks $
                ,xtickunits=xtickunits,xtickv=xtickv, color=axiscolor
  ENDELSE

  IF xlog EQ 1 THEN BEGIN 
     cgaxis,10.^!X.crange[0],1,yaxis=0,ylog=ylog,ystyle=ystyle,yrange=yrange,/data $
                ,ycharsize=ycharsize,ygridstyle=ygridstyle,yminor=yminor,ythick=ythick $
                ,ytick_get=ytick_get,ytickformat=ytickformat,ytickinterval=ytickinterval $
                ,yticklayout=yticklayout,yticklen=yticklen,ytickname=ytickname,yticks=yticks $
                ,ytickunits=ytickunits,ytickv=ytickv,ytitle=ytitle, color=axiscolor
     cgaxis,10.^!X.crange[1],1,yaxis=1,ylog=ylog,ystyle=ystyle,yrange=yrange,/data,ytickname=REPLICATE(' ', 30) $
                ,ycharsize=ycharsize,ygridstyle=ygridstyle,yminor=yminor,ythick=ythick $
                ,ytick_get=ytick_get,ytickformat=ytickformat,ytickinterval=ytickinterval $
                ,yticklayout=yticklayout,yticklen=yticklen,yticks=yticks $
                ,ytickunits=ytickunits,ytickv=ytickv, color=axiscolor
  ENDIF ELSE BEGIN 
     cgaxis,!X.crange[0],1,yaxis=0,ylog=ylog,ystyle=ystyle,yrange=yrange,/data $
                ,ycharsize=ycharsize,ygridstyle=ygridstyle,yminor=yminor,ythick=ythick $
                ,ytick_get=ytick_get,ytickformat=ytickformat,ytickinterval=ytickinterval $
                ,yticklayout=yticklayout,yticklen=yticklen,ytickname=ytickname,yticks=yticks $
                ,ytickunits=ytickunits,ytickv=ytickv,ytitle=ytitle, color=axiscolor 
     cgaxis,!X.crange[1],1,yaxis=1,ylog=ylog,ystyle=ystyle,yrange=yrange,/data,ytickname=REPLICATE(' ', 30) $
                ,ycharsize=ycharsize,ygridstyle=ygridstyle,yminor=yminor,ythick=ythick $
                ,ytick_get=ytick_get,ytickformat=ytickformat,ytickinterval=ytickinterval $
                ,yticklayout=yticklayout,yticklen=yticklen,yticks=yticks $
                ,ytickunits=ytickunits,ytickv=ytickv, color=axiscolor
  ENDELSE

    ; Restore the decomposed color state if you can.
    cgSetColorState, currentState
    
    ; Restore the color table. Can't do this for the Z-buffer or
    ; the snap shot will be incorrect.
    IF (!D.Name NE 'Z') THEN TVLCT, rr, gg, bb
    
    ; Clean up if you are using a layout.
    IF N_Elements(layout) NE 0 THEN !P.Multi = thisMulti
 
END

