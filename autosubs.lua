--[[
  autosubs.lua
  Extensión VLC para autocaragar subtítulos desde Subs/<nombre_video> recursivamente.
  Coloca este archivo en la carpeta de extensiones de VLC.
--]]

-- Descriptor: le indica a VLC que llame a input_changed()
function descriptor()
  return {
    title       = "Auto-Subs Locales",
    version     = "1.2",
    author      = "GRFKNT",
    shortdesc   = "Auto-Sub Local",
    description = "Busca recursivamente subtítulos en Subs/<nombre_base>/ y los añade como pistas.",
    capabilities = { "input-listener" }
  }
end

function activate() end
function deactivate() end

function input_changed()
  local item = vlc.input.item()
  if not item then return end

  local uri = item:uri()
  local video_path = uri_to_path(uri)
  if not video_path then return end

  local subs = find_subtitles(video_path)
  for _, sub in ipairs(subs) do
    vlc.msg.dbg("Auto-Subs: añadiendo "..sub)
    vlc.input.add_subtitle(sub)
  end
end

function uri_to_path(uri)
  local m = uri:match("^file:///(.+)$")
  if not m then return nil end
  m = vlc.strings.decode_uri(m)
  if package.config:sub(1,1) == "\\" then
    m = m:gsub("/", "\\")
  end
  return m
end

function find_subtitles(video_path)
  local sep = package.config:sub(1,1)
  local video_dir = video_path:match("(.*" .. sep .. ")") or "./"
  local video_name = video_path:match("([^" .. sep .. "]+)%.%w+$") or ""

  local subs_dir = video_dir .. "Subs" .. sep .. video_name .. sep

  -- Verificar si la carpeta Subs/<video> existe
  local list_cmd
  if sep == "\\" then
    list_cmd = string.format('dir "%s" /b /a:-d 2>nul', subs_dir)
  else
    list_cmd = string.format('find "%s" -maxdepth 1 -type f 2>/dev/null', subs_dir)
  end

  local subtitles = {}
  local p = io.popen(list_cmd)
  if p then
    for line in p:lines() do
      line = line:gsub("[\r\n]+$", "")
      local filename = line:match("([^" .. sep .. "]+)$") or line
      local extension = filename:match("%.([^%.]+)$")
      if extension then
        extension = extension:lower()
        if is_subtitle_extension(extension) then
          table.insert(subtitles, subs_dir .. filename)
        end
      end
    end
    p:close()
  end

  return subtitles
end

function is_subtitle_extension(ext)
  local extensions = {
    srt=true, vtt=true, ssa=true, ass=true, stl=true,
    scc=true, smi=true, sami=true, ttml=true, dfxp=true,
    xml=true, itt=true, idx=true, sub=true, mpl2=true, lrc=true
  }
  return extensions[ext] or false
end
