
--- Functions related to fetching and loading local and remote files.
local fetch = {}

local fs = require("luarocks.fs")
local dir = require("luarocks.dir")
local rockspecs = require("luarocks.rockspecs")
local persist = require("luarocks.persist")
local util = require("luarocks.util")
local cfg = require("luarocks.core.cfg")

--- Fetch a local or remote file.
-- Make a remote or local URL/pathname local, fetching the file if necessary.
-- Other "fetch" and "load" functions use this function to obtain files.
-- If a local pathname is given, it is returned as a result.
-- @param url string: a local pathname or a remote URL.
-- @param filename string or nil: this function attempts to detect the
-- resulting local filename of the remote file as the basename of the URL;
-- if that is not correct (due to a redirection, for example), the local
-- filename can be given explicitly as this second argument.
-- @param cache boolean: compare remote timestamps via HTTP HEAD prior to
-- re-downloading the file.
-- @return string or (nil, string, [string]): the absolute local pathname for the
-- fetched file, or nil and a message in case of errors, followed by
-- an optional error code.
function fetch.fetch_url(url, filename, cache)
   assert(type(url) == "string")
   assert(type(filename) == "string" or not filename)

   local protocol, pathname = dir.split_url(url)
   if protocol == "file" then
      return fs.absolute_name(pathname)
   elseif dir.is_basic_protocol(protocol) then
      local ok, name = fs.download(url, filename, cache)
      if not ok then
         return nil, "Failed downloading "..url..(filename and " - "..filename or ""), "network"
      end
      return name
   else
      return nil, "Unsupported protocol "..protocol
   end
end

--- For remote URLs, create a temporary directory and download URL inside it.
-- This temporary directory will be deleted on program termination.
-- For local URLs, just return the local pathname and its directory.
-- @param url string: URL to be downloaded
-- @param tmpname string: name pattern to use for avoiding conflicts
-- when creating temporary directory.
-- @param filename string or nil: local filename of URL to be downloaded,
-- in case it can't be inferred from the URL.
-- @return (string, string) or (nil, string, [string]): absolute local pathname of
-- the fetched file and temporary directory name; or nil and an error message
-- followed by an optional error code
function fetch.fetch_url_at_temp_dir(url, tmpname, filename)
   assert(type(url) == "string")
   assert(type(tmpname) == "string")
   assert(type(filename) == "string" or not filename)
   filename = filename or dir.base_name(url)

   local protocol, pathname = dir.split_url(url)
   if protocol == "file" then
      if fs.exists(pathname) then
         return pathname, dir.dir_name(fs.absolute_name(pathname))
      else
         return nil, "File not found: "..pathname
      end
   else
      local temp_dir, err = fs.make_temp_dir(tmpname)
      if not temp_dir then
         return nil, "Failed creating temporary directory "..tmpname..": "..err
      end
      util.schedule_function(fs.delete, temp_dir)
      local ok, err = fs.change_dir(temp_dir)
      if not ok then return nil, err end
      local file, err, errcode = fetch.fetch_url(url, filename)
      fs.pop_dir()
      if not file then
         return nil, "Error fetching file: "..err, errcode
      end
      return file, temp_dir
   end
end

-- Determine base directory of a fetched URL by extracting its
-- archive and looking for a directory in the root.
-- @param file string: absolute local pathname of the fetched file
-- @param temp_dir string: temporary directory in which URL was fetched.
-- @param src_url string: URL to use when inferring base directory.
-- @param src_dir string or nil: expected base directory (inferred
-- from src_url if not given).
-- @return (string, string) or (string, nil) or (nil, string):
-- The inferred base directory and the one actually found (which may
-- be nil if not found), or nil followed by an error message.
-- The inferred dir is returned first to avoid confusion with errors,
-- because it is never nil.
function fetch.find_base_dir(file, temp_dir, src_url, src_dir)
   local ok, err = fs.change_dir(temp_dir)
   if not ok then return nil, err end
   fs.unpack_archive(file)
   local inferred_dir = src_dir or dir.deduce_base_dir(src_url)
   local found_dir = nil
   if fs.exists(inferred_dir) then
      found_dir = inferred_dir
   else
      util.printerr("Directory "..inferred_dir.." not found")
      local files = fs.list_dir()
      if files then
         table.sort(files)
         for i,filename in ipairs(files) do
            if fs.is_dir(filename) then
               util.printerr("Found "..filename)
               found_dir = filename
               break
            end
         end
      end
   end
   fs.pop_dir()
   return inferred_dir, found_dir
end

--- Obtain a rock and unpack it.
-- If a directory is not given, a temporary directory will be created,
-- which will be deleted on program termination.
-- @param rock_file string: URL or filename of the rock.
-- @param dest string or nil: if given, directory will be used as
-- a permanent destination.
-- @return string or (nil, string, [string]): the directory containing the contents
-- of the unpacked rock.
function fetch.fetch_and_unpack_rock(rock_file, dest)
   assert(type(rock_file) == "string")
   assert(type(dest) == "string" or not dest)

   local name = dir.base_name(rock_file):match("(.*)%.[^.]*%.rock")
   
   local err, errcode
   rock_file, err, errcode = fetch.fetch_url_at_temp_dir(rock_file,"luarocks-rock-"..name)
   if not rock_file then
      return nil, "Could not fetch rock file: " .. err, errcode
   end

   rock_file = fs.absolute_name(rock_file)
   local unpack_dir
   if dest then
      unpack_dir = dest
      local ok, err = fs.make_dir(unpack_dir)
      if not ok then
         return nil, "Failed unpacking rock file: " .. err
      end
   else
      unpack_dir = fs.make_temp_dir(name)
   end
   if not dest then
      util.schedule_function(fs.delete, unpack_dir)
   end
   local ok, err = fs.change_dir(unpack_dir)
   if not ok then return nil, err end
   ok, err = fs.unzip(rock_file)
   if not ok then
      return nil, "Failed unpacking rock file: " .. rock_file .. ": " .. err
   end
   fs.pop_dir()
   return unpack_dir
end

--- Back-end function that actually loads the local rockspec.
-- Performs some validation and postprocessing of the rockspec contents.
-- @param rel_filename string: The local filename of the rockspec file.
-- @param quick boolean: if true, skips some steps when loading
-- rockspec.
-- @return table or (nil, string): A table representing the rockspec
-- or nil followed by an error message.
function fetch.load_local_rockspec(rel_filename, quick)
   assert(type(rel_filename) == "string")
   local abs_filename = fs.absolute_name(rel_filename)

   local basename = dir.base_name(abs_filename)
   if basename ~= "rockspec" then
      if not basename:match("(.*)%-[^-]*%-[0-9]*") then
         return nil, "Expected filename in format 'name-version-revision.rockspec'."
      end
   end

   local tbl, err = persist.load_into_table(abs_filename)
   if not tbl then
      return nil, "Could not load rockspec file "..abs_filename.." ("..err..")"
   end
   
   local rockspec, err = rockspecs.from_persisted_table(abs_filename, tbl, err, quick)
   if not rockspec then
      return nil, abs_filename .. ": " .. err
   end

   local name_version = rockspec.package:lower() .. "-" .. rockspec.version
   if basename ~= "rockspec" and basename ~= name_version .. ".rockspec" then
      return nil, "Inconsistency between rockspec filename ("..basename..") and its contents ("..name_version..".rockspec)."
   end
   
   return rockspec
end

--- Load a local or remote rockspec into a table.
-- This is the entry point for the LuaRocks tools. 
-- Only the LuaRocks runtime loader should use
-- load_local_rockspec directly.
-- @param filename string: Local or remote filename of a rockspec.
-- @param location string or nil: Where to download. If not given,
-- a temporary dir is created.
-- @return table or (nil, string, [string]): A table representing the rockspec
-- or nil followed by an error message and optional error code.
function fetch.load_rockspec(filename, location)
   assert(type(filename) == "string")

   local name
   local basename = dir.base_name(filename)
   if basename == "rockspec" then
      name = "rockspec"
   else
      name = basename:match("(.*)%.rockspec")
      if not name then
         return nil, "Filename '"..filename.."' does not look like a rockspec."
      end
   end
   
   local err, errcode
   if location then
      local ok, err = fs.change_dir(location)
      if not ok then return nil, err end
      filename, err = fetch.fetch_url(filename)
      fs.pop_dir()
   else
      filename, err, errcode = fetch.fetch_url_at_temp_dir(filename,"luarocks-rockspec-"..name)
   end
   if not filename then
      return nil, err, errcode
   end

   return fetch.load_local_rockspec(filename)
end

--- Download sources for building a rock using the basic URL downloader.
-- @param rockspec table: The rockspec table
-- @param extract boolean: Whether to extract the sources from
-- the fetched source tarball or not.
-- @param dest_dir string or nil: If set, will extract to the given directory;
-- if not given, will extract to a temporary directory.
-- @return (string, string) or (nil, string, [string]): The absolute pathname of
-- the fetched source tarball and the temporary directory created to
-- store it; or nil and an error message and optional error code.
function fetch.get_sources(rockspec, extract, dest_dir)
   assert(rockspec:type() == "rockspec")
   assert(type(extract) == "boolean")
   assert(type(dest_dir) == "string" or not dest_dir)

   local url = rockspec.source.url
   local name = rockspec.name.."-"..rockspec.version
   local filename = rockspec.source.file
   local source_file, store_dir
   local ok, err, errcode
   if dest_dir then
      ok, err = fs.change_dir(dest_dir)
      if not ok then return nil, err, "dest_dir" end
      source_file, err, errcode = fetch.fetch_url(url, filename)
      fs.pop_dir()
      store_dir = dest_dir
   else
      source_file, store_dir, errcode = fetch.fetch_url_at_temp_dir(url, "luarocks-source-"..name, filename)
   end
   if not source_file then
      return nil, err or store_dir, errcode
   end
   if rockspec.source.md5 then
      if not fs.check_md5(source_file, rockspec.source.md5) then
         return nil, "MD5 check for "..filename.." has failed.", "md5"
      end
   end
   if extract then
      local ok, err = fs.change_dir(store_dir)
      if not ok then return nil, err end
      ok, err = fs.unpack_archive(rockspec.source.file)
      if not ok then return nil, err end
      if not fs.exists(rockspec.source.dir) then

         -- If rockspec.source.dir can't be found, see if we only have one
         -- directory in store_dir.  If that's the case, assume it's what
         -- we're looking for.
         -- We only do this if the rockspec source.dir was not set, and only
         -- with rockspecs newer than 3.0.
         local file_count, found_dir = 0

         if not rockspec.source.dir_set and rockspec:format_is_at_least("3.0") then
            for file in fs.dir() do
               file_count = file_count + 1
               if fs.is_dir(file) then
                  found_dir = file
               end
            end
         end

         if file_count == 1 and found_dir then
            rockspec.source.dir = found_dir
         else
            return nil, "Directory "..rockspec.source.dir.." not found inside archive "..rockspec.source.file, "source.dir", source_file, store_dir
         end
      end
      fs.pop_dir()
   end
   return source_file, store_dir
end

--- Download sources for building a rock, calling the appropriate protocol method.
-- @param rockspec table: The rockspec table
-- @param extract boolean: When downloading compressed formats, whether to extract
-- the sources from the fetched archive or not.
-- @param dest_dir string or nil: If set, will extract to the given directory.
-- if not given, will extract to a temporary directory.
-- @return (string, string) or (nil, string): The absolute pathname of
-- the fetched source tarball and the temporary directory created to
-- store it; or nil and an error message.
function fetch.fetch_sources(rockspec, extract, dest_dir)
   assert(rockspec:type() == "rockspec")
   assert(type(extract) == "boolean")
   assert(type(dest_dir) == "string" or not dest_dir)

   local protocol = rockspec.source.protocol
   local ok, proto
   if dir.is_basic_protocol(protocol) then
      proto = fetch
   else
      ok, proto = pcall(require, "luarocks.fetch."..protocol:gsub("[+-]", "_"))
      if not ok then
         return nil, "Unknown protocol "..protocol
      end
   end
   
   if cfg.only_sources_from
   and rockspec.source.pathname
   and #rockspec.source.pathname > 0 then
      if #cfg.only_sources_from == 0 then
         return nil, "Can't download "..rockspec.source.url.." -- download from remote servers disabled"
      elseif rockspec.source.pathname:find(cfg.only_sources_from, 1, true) ~= 1 then
         return nil, "Can't download "..rockspec.source.url.." -- only downloading from "..cfg.only_sources_from
      end
   end
   return proto.get_sources(rockspec, extract, dest_dir)
end

return fetch
