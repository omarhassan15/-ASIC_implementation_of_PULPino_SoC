puts "Elaborating PULPino\r\n\r\n"


set RTL_PATH            "/home/ICer/GP/PULPino/rtl"
set DEFINES_PATH 	"/home/ICer/GP/PULPino/defines"

#Add the path of the libraries and RTL files to the search_path variable
lappend search_path $RVT_DB_PATH $RTL_PATH $DEFINES_PATH

### listing includes & packages
set include_files [glob -directory $DEFINES_PATH *.*]

## analyzing listing includes & packages
analyze -autoread $include_files			

####listing RTL files
set files [glob -nocomplain -directory $RTL_PATH *.{sv,v,vhd}]
set RTL_files {}

foreach file $files {
    if {[string match -nocase *define* $file] != 1 || [string match -nocase *package* $file] != 1} {
        lappend RTL_files $file
    }
}

# Now, RTL_files contains the list of files with .sv, .v, or .vhd extension
# and do not contain *define* or *package* in their names


####### Analyzing RTL files   ############
analyze -autoread  $RTL_files

########## elaborate ################
elaborate pulpino_top

###################### Defining toplevel ###################################

current_design $top_module


########### checking unresolved stuff #############
link
