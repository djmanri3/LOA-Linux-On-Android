# Linux on Android

![Screenshot](Linux_on_Android2.png)

## Requirimientos
- termux terminal app
- termux api app (ssh)
- Server X11
    - termux:x11 app (telegram o repo oficial https://github.com/termux/termux-x11/actions/workflows/debug_build.yml)
    - XServer XDLS (en la Play Store)

## Arbol de directorios
```
├── install_environment.sh
├── lib
├── install_ssh_server.sh
    └── proot_scripts
        ├── install_kde_vnc_and_x11.sh
        ├── install_proot.sh
        ├── proot_ui.sh
        └── proot_ui_low.sh
    ├── termux-x11
        ├── termux-x11-nightly-1.02.07-0-all.deb
        ├── termux-x11-universal.apk
    ├── tools
        ├── install_ssh_server.sh
        ├── termux-api.apk
```

## Paquetes que se instalarán
Este script insatala los siguientes paquetes:
- x11-repo
- pulseaudio
- openssl
- xfce4*
- firefox
- termux-x11.deb (en telegram o en el repo oficial https://github.com/termux/termux-x11/actions/workflows/debug_build.yml)

## SIN PROOT

### Scripts necesario:
- **install_environment.sh**: instala todos los paquetes necesarios para el entorno, x11 y genera el script para arrancar el entorno

### PROS:
- Más liviano: ya que unicmanete se instala el entorno xfce4
- Más optimo: como unicamente carga un entorno de escritorio es más rapido

### CONTRAS:
- Menor compativilidad con paquetes: estamos limitados a los repos de termux
- Menos privilegios: si nuestro dispositivo no esta roteado no podremos escalar a root
- El audio del navegador Firefox no funciona
- No podemos instalar Chromium

### Instalación

Hay que tener en cuenta que el archivo **termux-x11.deb** se debe descargar de la aplicación Telegram o del repo, pero este se tiene que encontrar en la carpeta de Download/Telegram, si no, **no lo instalará**

- [ ] Primero tener instalado termux https://f-droid.org/repo/com.termux_118.apk
- [ ] Ejecutar el script **install_environment.sh** con el parametro **vanila**
```
./install_environment.sh vanila
```
- [ ] El script anterior generará un script llamado **start_environment.sh** con este arrancaremos el entorno o ejecutando ./install_environment.sh vanila_start 

### Uso
1. Primero deberemos de abrir la app **termux:x11**
2. Posteriormente ejecutaremos el siguiente script **start_environment.sh** (./start_environment.sh vanila_start)

## CON PROOT

### Scripts necesario:
- **install_environment.sh**: instala todos los paquetes necesarios para el entorno, x11 y genera el script para arrancar el entorno
- **install_proot.sh**: realiza la instalación de proot con el entorno XFCE4 y distribución Ubuntu
- **proot_ui.sh**: Configura la pantalla virtual mediante **Termux-x11** para que sea accesible por proot
- **proot_ui_low.sh**: Configura la pantalla virtual medinate **XServer XDLS** para que sea accesible por proot
- **start.sh**: Inicia el servicio de pulseaudio y el escritorio con **Termux-x11**
- **start_low.sh**: Inicia el servicio de pulseaudio y el escritorio con **XServer XDLS**
- **install_chromium.sh**: instala chromium dentro de proot (ejecutar dentro de este mismo)

### PROS:
- Mayor libertad: ya que somos usuarios root
- Mayor cantidad de paquetes instalables y dependencias: podremos instalar todo lo que este contemplado en los repos de Ubuntu (el unico problema que me he encontrado es al instalar Firefox ya que hay que instalarlo por snap)
- Podemos instalar Chromium!
- El audio funciona en el navegador (Chromium)

### CONTRAS:
- Sistema más pesado: esto es debido a que hemos instalado una versión entera de Ubuntu
- Ocupa mayor espacio: al estar instalado un Ubuntu normal y corriente tenemos bastantes paquetes que algunos nunca utilizaremos
- No podremos instalar Firefox: debido a que para instalar paquetes de tipo snap necesitamos systemd

### Instalación

- [ ] Primero tener instalado termux https://f-droid.org/repo/com.termux_118.apk
- [ ] Realizar un **apt update && apt upgrade**
- [ ] Posteriormente ejecutar el script **install_environment.sh** con el parametro proot
```
./install_environment.sh proot
```
- [ ] Abriremos una de las aplicaciones para el manejo de ventabas (Termux-x11 o XServer XDLS), posteriormente ejecutaremos el siguiente comando ./install_environment.sh proot_start
#### Termux-x11
```
./install_environment.sh proot_start
```

#### XServer XDLS
```
cd proot_scripts && ./proot_ui_low.sh
```

### Uso
1. Primero deberemos de abrir la app **termux:x11** o XServer XDLS
2. Ejecutamos el script **./install_environment.sh proot_start** (Termux-x11) o **proot_ui_low.sh** (XServer XDLS) (estos scripts se encargan de que arranque todos los servicios dentro de proot)

### Instalación de Chromium

Unicamente deberemos ejecutar dentro del proot el script llamado **install_chromium.sh**

# Links de interes sobre este proyecto:

- Udroid: https://udroid-rc.gitbook.io/udroid-wiki/udroid-landing/readme
- Canal de YouTube sobre el tema: https://www.youtube.com/@TechnicalBot

# Agradecimientos
- Equipo de udroid
- Canal de YpuTube Tecnicalbot
- Equipo de termux
