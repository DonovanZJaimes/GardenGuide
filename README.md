#  ![AppIconLaunch](https://github.com/user-attachments/assets/989e873b-37b8-40bb-98c0-1be4b5032cf1)  GardenGuide


GardenGuide es un proyecto para encontrar información sobre plantas. Solo tienes que tomarle una foto a una planta o buscar su nombre, y la app te mostrará datos como imágenes, nombres comunes, una descripción y plantas similares.  
Además, puedes guardar tus plantas favoritas y añadirlas a tu jardín personal, donde podrás llevar un control de cuándo y cuánta agua necesitan.

## Screenshots

<img width="220" alt="Captura de pantalla 2025-02-22 a la(s) 2 37 33 p m" src="https://github.com/user-attachments/assets/17e0bdba-b568-432b-a4e0-a43e335b4514" />
<img width="220" alt="Captura de pantalla 2025-02-22 a la(s) 2 41 49 p m" src="https://github.com/user-attachments/assets/cf2c4241-1976-47ea-8180-fd6701a6bb74" />
<img width="220" alt="Captura de pantalla 2025-02-22 a la(s) 3 00 10 p m" src="https://github.com/user-attachments/assets/ff1e1c0f-85b8-402c-8ad0-479282278575" />  
<img width="220" alt="Captura de pantalla 2025-02-22 a la(s) 2 51 15 p m" src="https://github.com/user-attachments/assets/e5a2f73c-01f9-447e-be7a-318ac8acad22" />
<img width="220" alt="Captura de pantalla 2025-02-22 a la(s) 2 52 54 p m" src="https://github.com/user-attachments/assets/dac481ed-8fb4-44bb-8211-d656f24c4206" />
<img width="220" alt="Captura de pantalla 2025-02-22 a la(s) 2 47 30 p m" src="https://github.com/user-attachments/assets/050b673f-c0d4-4286-ab93-a78672a3a1ac" />  
<img width="220" alt="Captura de pantalla 2025-02-22 a la(s) 3 11 00 p m" src="https://github.com/user-attachments/assets/75297f80-8e67-49c0-83b1-25cb586190d6" />
<img width="220" alt="Captura de pantalla 2025-02-22 a la(s) 2 56 14 p m" src="https://github.com/user-attachments/assets/432bc6be-8f96-4a6b-aa50-018a1e40fdc2" />
<img width="220" alt="Captura de pantalla 2025-02-22 a la(s) 3 12 57 p m" src="https://github.com/user-attachments/assets/b6fae0e1-7cf4-4727-88fd-dea56dd45bfa" />
<img width="220" alt="Captura de pantalla 2025-02-22 a la(s) 4 03 29 p m" src="https://github.com/user-attachments/assets/bee01fd1-d888-4dbd-8012-9ebe5de322b5" />


## Demo
| Demo 1 | Demo 2 | Demo 3 |
| --- | --- | --- |
|![Demo1](https://github.com/user-attachments/assets/aa8e6f2d-2d87-4f93-ab8d-b23b24bce0ad)  |  ![Demo2](https://github.com/user-attachments/assets/c5229b4b-731a-4aae-805b-fa90548223ac) |  ![Demo3](https://github.com/user-attachments/assets/77561d4c-062c-4810-9dc7-6c313dd5fd35) |


## Información

### Funcionalidades
 - **Identificación por imagen:** Permite tomar una foto de una planta y te muestra una lista de plantas similares.
- **Búsqueda por nombre:** Puedes buscar una planta escribiendo su nombre.
- **Información detallada:** El proyecto te proporciona información sobre la planta, como:

  - Descripción general
  - Nombres comunes
  - Partes editables
  - Recomendaciones de riego y más.


- **Favoritos:** Puedes guardar las plantas que más te gusten en tu lista de favoritos.
- **Jardín personal:** Añade plantas a tu jardín personal donde podrás:

  - Registrar información sobre su riego (cuándo y cuánto regar)
  - Modificar la programación de riego
  - Eliminar plantas de tu jardín personal.


### Patrón de arquitectura
Este proyecto sigue el patrón de diseño Modelo-Vista-Controlador (MVC). En cada carpeta, encontrarás típicamente la siguiente estructura de organización de archivos.

<img width="334" alt="MVC" src="https://github.com/user-attachments/assets/825fe2a6-3ba4-4d24-a90e-7fec9f3922be" />

### GardenGuide Data API
Este proyecto está siendo desarrollada con la API de Plant.id de Kindwise, la cual ha sido fundamental en varias vistas de la app. 
Gracias a esta API, se facilita la obtención de información detallada sobre cada planta, lo que ha sido clave para la creación del proyecto. 
Para más detalles, visita la página web de la API.   
Página web de la API: [Plant.id by kindwise](https://www.kindwise.com/plant-id).  

<img width="567" alt="Captura de pantalla 2025-02-22 a la(s) 1 57 49 p m" src="https://github.com/user-attachments/assets/6b837f97-d636-4bf4-a46f-2ece1dca9271" />


### Frameworks en GitHub
Para garantizar el correcto funcionamiento del proyecto, se utilizaron cuatro frameworks esenciales, los cuales fueron integrados mediante “Package Dependencies”.
- [Kingfisher](https://github.com/onevcat/Kingfisher).
- [GoogleSignIn](https://github.com/google/GoogleSignIn-iOS).
- [Firebase](https://github.com/firebase/firebase-ios-sdk).
- [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing).


#### Framework de Firebase
Se emplearon las siguientes librerías del framework de Firebase para garantizar el correcto funcionamiento del proyecto, abarcando desde la autenticación de usuarios hasta el almacenamiento en la nube y otras funcionalidades clave.  

![logo-vertical](https://github.com/user-attachments/assets/1687d225-e0b3-4f7e-909a-687fd3d10e40) 

- Firebase Analytics
- Firebase Auth
- Firebase Crashlytics
- Firebase Firestore
- Firebase Remote Config


### Testeo
Se realizaron tres tipos de pruebas para evaluar distintas clases del proyecto y asegurar su calidad. Estas pruebas incluyeron:
- Pruebas Unitarias (Unit Tests)
- Pruebas de Interfaz de Usuario (UI Tests)
- Pruebas de Captura de Pantalla (Snapshot Testing)


## Iniciar 
Al ejecutar el proyecto, verás cuatro opciones para registrarte: de forma anónima, con correo electrónico, a través de Google o mediante Twitter.
> [!TIP]
> Si no deseas registrarte, puedes acceder utilizando las siguientes credenciales:
> - Correo: GardenGuidePrueba4@gmail.com 
> - Contraseña: Garden1!

### Mock
Actualmente, al descargar o clonar el proyecto, está configurado para no usar los mocks. Sin embargo, si prefieres usarlos y no hacer llamadas directas a la API, sigue estos pasos:

> Dirígete a la carpeta "Utils" y dentro encontrarás el archivo "MockManagerSingleton". Este archivo contiene una variable booleana configurada como false. Cámbiala a true para activar el uso del mock y desactivar las llamadas a la API.
> 


> <img width="788" alt="Captura de pantalla 2025-02-22 a la(s) 2 02 08 p m" src="https://github.com/user-attachments/assets/af1c4937-8756-4c98-b584-7bc9418890e2" />











