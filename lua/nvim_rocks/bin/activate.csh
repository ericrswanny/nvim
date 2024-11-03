which deactivate-lua >&/dev/null && deactivate-lua

alias deactivate-lua 'if ( -x '\''/home/erics/.config/nvim/lua/nvim_rocks/bin/lua'\'' ) then; setenv PATH `'\''/home/erics/.config/nvim/lua/nvim_rocks/bin/lua'\'' '\''/home/erics/.config/nvim/lua/nvim_rocks/bin/get_deactivated_path.lua'\''`; rehash; endif; unalias deactivate-lua'

setenv PATH '/home/erics/.config/nvim/lua/nvim_rocks/bin':"$PATH"
rehash
