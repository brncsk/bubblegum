set print thread-events off

set $_exitcode = -1
run
if $_exitcode != -1 
    quit
end
