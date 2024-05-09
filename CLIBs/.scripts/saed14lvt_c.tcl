set_app_options -name lib.workspace.group_libs_combine_physical_only -value false
set_app_options -name lib.workspace.use_workspace_tech -value true
set_app_options -name lib.workspace.fast_exploration -value true
set_app_options -name lib.workspace.reuse_lib -value true
set_app_options -name lib.workspace.create_cached_lib -value true
# workspace saed14lvt_c:
if {1} {
puts "ERROR - workspace saed14lvt_c cannot build because it has no physical source file."
} else {
create_workspace saed14lvt_c
read_db /mnt/hgfs/ASIC_shared/LIBs/stdcell_lvt/db_nldm/saed14lvt_ff0p88v25c.db
read_db /mnt/hgfs/ASIC_shared/LIBs/stdcell_lvt/db_nldm/saed14lvt_ss0p6vm40c.db
process_workspaces -check_options {-allow_missing} -output CLIBs/saed14lvt_c.ndm -force
remove_workspace


}
