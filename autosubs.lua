--[[
  autosubs.lua
  Extensión VLC para autocaragar subtítulos desde Subs/<nombre_video> recursivamente.
  Coloca este archivo en la carpeta de extensiones de VLC.
--]]

-- Descriptor: le indica a VLC que llame a input_changed()
function descriptor()
  return {
    title       = "Auto-Subs Locales",
    version     = "1.0",
    author      = "GRFKNT",
    shortdesc   = "Auto-Sub Local",
    description = "Busca recursivamente subtítulos en Subs/<nombre_base>/ y los añade como pistas.",
    capabilities = { "input-listener" }
  }
end

-- Función vacía (necesaria)
function activate() end
function deactivate() end

-- Se llama cada vez que cambia el media
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

-- Convierte URI 'file:///C:/ruta/video.mp4' a ruta de sistema
function uri_to_path(uri)
  local m = uri:match("^file:///(.+)$")
  if not m then return nil end
  -- Decodifica %20, %XX
  m = vlc.strings.decode_uri(m)
  -- En Windows URI viene con '/', convertir a '\'
  if package.config:sub(1,1) == "\\" then
    m = m:gsub("/", "\\")
  end
  return m
end

-- Busca recursivamente archivos .srt en Subs/<base>/
function find_subtitles(video_path)
  local sep = package.config:sub(1,1)        -- '/' en Unix, '\' en Win :contentReference[oaicite:1]{index=1}
  local dir  = video_path:match("(.*" .. sep .. ")") or "./"
  local base = video_path:match("([^" .. sep .. "]+)%.%w+$")
  local subs_dir = dir .. "Subs" .. sep .. base

local cmd
if sep == "\\" then
  -- Windows: usa dir /s /b y findstr con múltiples extensiones
  cmd = string.format(
    'dir "%s" /b /s | findstr /i "\\.srt$ \\|\\.vtt$ \\|\\.ssa$ \\|\\.ass$ \\|\\.stl$ \\|\\.scc$ \\|\\.smi$ \\|\\.sami$ \\|\\.ttml$ \\|\\.dfxp$ \\|\\.xml$ \\|\\.itt$ \\|\\.idx$ \\|\\.sub$ \\|\\.mpl2$ \\|\\.lrc$"',
    subs_dir
  )
else
  -- Unix: usa find con múltiples -iname
  cmd = string.format(
    'find "%s" \\( -iname "*.srt" -o -iname "*.vtt" -o -iname "*.ssa" -o -iname "*.ass" -o -iname "*.stl" -o -iname "*.scc" -o -iname "*.smi" -o -iname "*.sami" -o -iname "*.ttml" -o -iname "*.dfxp" -o -iname "*.xml" -o -iname "*.itt" -o -iname "*.idx" -o -iname "*.sub" -o -iname "*.mpl2" -o -iname "*.lrc" \\)',
    subs_dir
  )
end

  local subs_files = {}
  for line in io.popen(cmd):lines() do
    -- eliminar saltos, si los hay
    line = line:gsub("[\r\n]+$", "")
    table.insert(subs_files, line)
  end
  return subs_files
end
