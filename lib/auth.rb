# Tasks

- [ ] Explicar que es Fudo(2-3 parrafos, 100 palabras max)
- [ ] Explicar que es TCP(2-3 parrafos, 50 palabras max)
- [ ] Explicar que es HTTP(2-3 parrafos, 50 palabras max)
- [ ] Rack API (ruby sin rails)

- [ ] El proyecto debe estar hosteado en GitHub/GitLab o cualquier repo git, incluyendo los archivos .md de los 3 primeros puntos.
- [ ] Endpoint de autenticación, que reciba usuario y contraseña.
- [ ] Endpoint para creación de productos. Este endpoint debe ser asíncrono, es decir que la respuesta a esta llamada no debe indicar que el producto ya fue creado, sino que se creará
- [ ] Endpoint para consulta de productos.
- [ ] Además de estos endpoints, se puede tener cualquier otro endpoint adicional que facilite el comportamiento asíncrono de la creación de productos.
- [ ] Se debe exponer también en la raíz un archivo llamado AUTHORS, que indique tu nombre y apellido. Este archivo también debe ser estático y la respuesta debe indicar que se cachee por 24 hs.
- [ ] La API debe estar especificada en un archivo llamado openapi.yaml que siga la especificación de OpenAPI. Este archivo debe ser expuesto como un archivo estático en la raíz y nunca debe ser cacheado por los clientes.

### Notas

Los endpoints relacionados a la creación y consulta de productos deben validar que se haya autenticado antes.
La respuesta de la api debe ser comprimida con gzip (siempre que el cliente lo solicite).

No hace falta tener acceso a una base de datos. La persistencia de los productos puede ser en memoria.
Los atributos de los productos es suficiente que sean sólo id y nombre

Opcionalmente, poder levantar el proyecto en Docker.
Agregar en el README la forma de levantar el proyecto.
Para cualquier cosa no indicada en los puntos anteriores, hay libertad en la decisión.
