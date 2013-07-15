set print thread-events off
break g_log

set $_exitcode = -1
run
if $_exitcode != -1 
    quit
end
