# hycov
clients over view for hyprland plugin 


# install 

only support hyprland sourc code after(2023-12-22)

```
bash install.sh

```

# useage(hyprland.con)
```
plugin = /usr/lib/libhycov.so
bind = CTRL_ALT,h,hycov:enteroverview
bind = CTRL_ALT,m,hycov:leaveoverview
bind = CTRL_ALT,k,hycov:toggleoverview

plugin {
    hycov {
        overview_gappo = 60 #gas width from screem 
        overview_gappi = 24 #gas width from clients
	    hotarea_size = 10 #hotarea size in bottom left,10x10
	    enable_hotarea = 1 # enable mouse cursor hotarea       
    }
}

```