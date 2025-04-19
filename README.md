### Descripción  
Extensión para VLC que carga automáticamente subtítulos compartidos con el archivo de video.  
Los subtítulos deben estar dentro de un subdirectorio con el mismo nombre que el video, dentro del directorio Subs. Ejemplo de la ruta:  
* foo_01.mkv  
* Subs\foo_01\01_sub.ass  

Las extensiones de subtítulos que buscará el script son: srt, vtt, ssa, ass, stl, scc, smi, sami, ttml, dfxp, xml, itt, idx, sub, mpl2 y lrc.  

### Uso  
* Habilita la opción **"Auto-Sub Local"** en el menú **"Ver"**.  
* Reproduce el archivo de video.  

### Errores conocidos  
* Puede ser que la selección automática de idioma no funcione.

### Instalación  
Copia el archivo `.lua` en la carpeta correspondiente de extensiones lua (¡Crea el directorio si no existe!):  
* Windows (todos los usuarios): `%ProgramFiles%\VideoLAN\VLC\lua\extensions`  
* Windows (usuario actual): `%APPDATA%\VLC\lua\extensions`  
* Linux (todos los usuarios): `/usr/lib/vlc/lua/extensions/`  
* Linux (usuario actual): `~/.local/share/vlc/lua/extensions/`
