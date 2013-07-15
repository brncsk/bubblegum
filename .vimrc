nnoremap <Leader>m :w<Bar>
	\ execute 'silent !tmux select-pane -R'<Bar>
	\ execute 'silent !tmux send-keys -t right C-c C-l'<Bar>
	\ execute 'silent !tmux send-keys -t right "make clean  &&  make  &&  gdb ./bubblegum; tmux select-pane -R" C-M'<Bar>
	\ redraw!<C-M>
