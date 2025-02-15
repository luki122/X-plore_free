#
# TdumpWin
# ----------------------------------------------------------------------
# Implements Tdump window for gdb
#
#   PUBLIC ATTRIBUTES:
#
#
#   METHODS:
#
#     reconfig ....... called when preferences change
#
#
#   X11 OPTION DATABASE ATTRIBUTES
#
#
# ----------------------------------------------------------------------
#   AUTHOR:  Elena Zannoni <ezannoni@cygnus.com>
#   Copyright (C) 1998 Cygnus Solutions
#


itcl_class TdumpWin {
  # ------------------------------------------------------------------
  #  CONSTRUCTOR - create new tdump window
  # ------------------------------------------------------------------
  constructor {config} {
    #
    #  Create a window with the same name as this object
    #
    set class [$this info class]
    @@rename $this $this-tmp-
    @@frame $this -class $class 
    @@rename $this $this-win-
    @@rename $this-tmp- $this

    set top [winfo toplevel $this]
    wm withdraw $top

    build_win
    add_hook gdb_update_hook "$this update"
    after idle [list wm deiconify $top]

  }


  # ------------------------------------------------------------------
  #  METHOD:  build_win - build the main tdump window
  # ------------------------------------------------------------------
  method build_win {} {

     tixScrolledText $this.stext -scrollbar y -height 200 -width 500
     set twin [$this.stext subwidget text]
    
    # make window non editable
    $twin configure -insertwidth 0 

    pack append $this $this.stext {left expand fill}
    update
  }


  # ------------------------------------------------------------------
  #  METHOD:  update - update widget when PC changes
  # ------------------------------------------------------------------
  method update {} {
    #debug "tdump: update"
    gdbtk_busy
    set tframe_num [gdb_get_trace_frame_num]

    if { $tframe_num!=-1 } {
      debug "doing tdump"
      $twin delete 0 end

      if {[catch {gdb_cmd "tdump $tframe_num" 0} tdump_output]} {
	tk_messageBox -title "Error" -message $tdump_output -icon error \
	  -type ok
      } else {
	#debug "tdum output is $tdump_output"
	
	$twin insert end $tdump_output
	$twin see insert
      }
    }
    gdbtk_idle
  }

  # ------------------------------------------------------------------
  #  DESTRUCTOR - destroy window containing widget
  # ------------------------------------------------------------------
  destructor {
    remove_hook gdb_update_hook "$this update"
    set top [winfo toplevel $this]
    destroy $this
    destroy $top
  }

  # ------------------------------------------------------------------
  #  METHOD:  config - used to change public attributes
  # ------------------------------------------------------------------
  method config {config} {}
    
  # ------------------------------------------------------------------
  #  METHOD:  reconfig - used when preferences change
  # ------------------------------------------------------------------
  method reconfig {} {
  }
  
  #
  #  PROTECTED DATA
  #
  protected maxwidth 0
  protected twin
}

