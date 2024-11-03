-- LuaRocks configuration

rocks_trees = {
   { name = "user", root = home .. "/.luarocks" },
   { name = "system", root = "/home/erics/.config/nvim/lua/nvim_rocks" },
}
lua_interpreter = "lua"
variables = {
   LUA_DIR = "/home/erics/.config/nvim/lua/nvim_rocks",
   LUA_BINDIR = "/home/erics/.config/nvim/lua/nvim_rocks/bin",
}
