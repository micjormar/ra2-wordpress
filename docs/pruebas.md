# Pruebas de funcionamiento y rendimiento

| Prueba | Resultado | ¿Correcto? |
|---|---|---|
| Servicios en marcha |db |ngix |wordpress
| Sitio y panel |Ambos se pueden entrar y se ve el tema
| Subida de ficheros |Varias imagenes subidas sin errores
| Enlaces permanentes |Cargan todos los enlaces de las entradas sin errores
| Persistencia (down/up) |El contenido sigue ahí
| Seguridad (403) |Da el resultado esperado


## Rendimiento

- Tiempos de respuesta en el aula (5 medidas):
0.689244s
0.066994s
0.052422s
0.057201s
0.054467s

- Memoria por contenedor (docker stats):
ngix -> 5.148MiB
wordpress -> 66.24MiB
db -> 96.93MiB

- Interpretación:
Consumo por capas: La base de datos es el servicio que más memoria requiere (~97 MiB) para mantener sus índices y buffers en memoria, seguido por la aplicación PHP/WordPress (~66 MiB). Nginx destaca por su extrema ligereza (~5 MiB), limitándose a gestionar las peticiones HTTP y reenviar el tráfico.

Diferencia entre peticiones: La primera petición tarda más debido al tiempo de "calentamiento" inicial: se deben cargar componentes de PHP en memoria, inicializar conexiones con la base de datos y generar cachés internas. Las peticiones 2 a 5 son sensiblemente más rápidas porque las conexiones ya están establecidas y parte del contenido o consultas han sido retenidas en caché.


## Publicación
- Dirección desde la que accedió mi compañero/a: http://10.20.13.26:8080
- Dirección pública en Codespaces (paso 4, si lo hice):
- Tiempos desde Codespaces y comparación con el aula:
