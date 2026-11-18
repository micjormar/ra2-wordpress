# Despliegue de WordPress con Docker Compose y GitHub Codespaces

## 1. Qué es el proyecto
Este proyecto consiste en el despliegue y configuración de un sitio web basado en **WordPress**, utilizando una arquitectura de contenedores con **Docker Compose**. El entorno consta de tres servicios principales:
* **Nginx**: Actúa como servidor web y proxy inverso.
* **WordPress**: Contenedor con la aplicación y PHP-FPM.
* **Base de Datos (MariaDB/MySQL)**: Almacena de forma persistente la información del sitio.

El proyecto incluye fases de pruebas de rendimiento, seguridad, publicación en red local de aula y despliegue temporal en la nube mediante **GitHub Codespaces**

## 2. Requisitos previos
Antes de arrancar el proyecto, asegúrate de tener instalado:
* Git.
* Docker y Docker Compose.

## 3. Cómo arrancarlo desde cero
Sigue estos pasos para poner en marcha el entorno en tu equipo[cite: 5]:

1. Clona el repositorio y cambia a la rama de trabajo:

   git clone https://github.com/micjormar/ra2-wordpress
   cd ra2-wordpress
   git switch ra2-cms

2. Configura las variables de entorno:
Copia el archivo de plantilla .env.example para crear tu archivo .env:

   cp .env.example .env

3. Crea la base de datos y el usuario en MySQL:
Ejecuta las sentencias SQL necesarias en tu contenedor de base de datos para inicializar la BD configurada en tu .env

4. Arranca los contenedores:

   sudo docker compose up -d

5. Cómo abrirlo en GitHub Codespaces

    - Entra a tu repositorio en GitHub, ve al selector de ramas y elige ra2-cms.

    - Haz clic en el botón verde Code -> pestaña Codespaces -> Create codespace on ra2-cms.

    - Configura el archivo .env, crea la base de datos y arranca con docker compose up -d.

    - En la pestaña PORTS de VS Code, cambia la visibilidad del puerto 8080 a Public y abre la URL generada.

6. Estructura de carpetas y documentación

La estructura del proyecto está organizada de la siguiente manera:

├── .devcontainer/       # Configuración para GitHub Codespaces
├── docs/                # Documentación del proyecto y evidencias
│   └── pruebas.md       # Registro de pruebas de funcionamiento y rendimiento
├── docker-compose.yml   # Definición de los servicios (Nginx, WordPress, DB)
├── .env.example         # Plantilla de variables de entorno
└── README.md            # Este archivo de descripción general
