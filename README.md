# WorldClocks - App de Relojes Mundiales para macOS

Una aplicación minimalista para la barra de menú de macOS que muestra la hora en tiempo real para Chile, Pacific (US West Coast) y East Coast (US East Coast).

<img width="436" height="342" alt="image" src="https://github.com/user-attachments/assets/b9ffd319-09e9-4fc7-8fb9-8c84bdd59016" />



## Características

- 🕐 Muestra 3 zonas horarias simultáneamente (Chile, Pacific, East Coast)
- ⏱️ Actualización en tiempo real sin segundos para una vista más limpia
- 🔄 Conversor de zonas horarias integrado: ingresa una hora en cualquier zona y ve el equivalente en las otras
- 🎨 Diseño minimalista y elegante
- 📍 Vive en la barra de menú (sin icono en el Dock)
- 🌙 Compatible con modo oscuro/claro

## Instalación

### Opción 1: Descargar App Compilada (Más Fácil)

1. Descarga `WorldClocks.zip` desde el repositorio
2. Descomprime el archivo (doble clic)
3. Arrastra `WorldClocks.app` a tu carpeta Aplicaciones
4. Abre WorldClocks desde Aplicaciones
5. Si macOS te pide permiso de seguridad:
   - Ve a Preferencias del Sistema → Privacidad y Seguridad
   - Haz clic en "Abrir de todas formas"
6. La app aparecerá en tu barra de menú con un icono de reloj 🕐

### Opción 2: Compilar con Xcode (Para Desarrolladores)

1. Descarga y descomprime el proyecto
2. Abre `WorldClocks.xcodeproj` en Xcode
3. Selecciona tu equipo de desarrollo en Signing & Capabilities (o usa "Sign to Run Locally")
4. Presiona ⌘+R para compilar y ejecutar
5. La app aparecerá en tu barra de menú con un icono de reloj 🕐

### Opción 3: Compilar desde Terminal

```bash
cd WorldClocks
xcodebuild -project WorldClocks.xcodeproj -scheme WorldClocks -configuration Release build
cp -R ~/Library/Developer/Xcode/DerivedData/WorldClocks-*/Build/Products/Release/WorldClocks.app /Applications/
```

## Uso

- Haz clic en el icono del reloj (🕐) en la barra de menú
- Se abrirá un popover mostrando las 3 zonas horarias
- Haz clic en cualquier lugar fuera del popover para cerrarlo

### Conversor de Zonas Horarias

1. Haz clic en el botón "Time Converter" en la parte inferior del popover
2. Selecciona la zona horaria de referencia (Chile, Pacific, o East Coast)
3. Ingresa la hora que deseas convertir (formato HH:MM)
4. La conversión se hace automáticamente mientras escribes

**Ejemplo:** Si ingresas 14:00 en Chile, verás automáticamente qué hora es en Pacific y East Coast.

## Iniciar con el Sistema

Para que la app se inicie automáticamente con tu Mac:

1. Ve a Preferencias del Sistema → General → Ítems de inicio
2. Agrega WorldClocks.app a la lista

## Personalización

Puedes modificar las zonas horarias editando el array `timeZones` en `WorldClocksApp.swift`:

```swift
let timeZones: [(name: String, identifier: String)] = [
    ("CHILE", "America/Santiago"),
    ("PACIFIC", "America/Los_Angeles"),
    ("EAST COAST", "America/New_York")
]
```

Lista de identificadores de zona horaria: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

## Requisitos

- macOS 13.0 o superior
- Xcode 15.0 o superior (para compilar)

## Licencia

Uso libre - haz lo que quieras con el código 🎉
