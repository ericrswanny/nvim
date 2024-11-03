if functions -q deactivate-lua
    deactivate-lua
end

function deactivate-lua
    if test -x '/home/erics/.config/nvim/lua/nvim_rocks/bin/lua'
        eval ('/home/erics/.config/nvim/lua/nvim_rocks/bin/lua' '/home/erics/.config/nvim/lua/nvim_rocks/bin/get_deactivated_path.lua' --fish)
    end

    functions -e deactivate-lua
end

set -gx PATH '/home/erics/.config/nvim/lua/nvim_rocks/bin' $PATH
