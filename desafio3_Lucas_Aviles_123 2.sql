-- 0. Eliminar, crear y conectar la base de datos
DROP DATABASE IF EXISTS desafio3_lucas_aviles_123;
CREATE DATABASE desafio3_lucas_aviles_123;
\connect desafio3_lucas_aviles_123;

-- 1. Crear tabla usuarios
CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  rol VARCHAR(50) NOT NULL
);

-- 2. Insertar 5 usuarios (mínimo un administrador)
INSERT INTO usuarios (email, nombre, apellido, rol) VALUES
  ('admin@ejemplo.com', 'Admin', 'Usuario', 'administrador'),
  ('user1@ejemplo.com', 'Usuario', 'Uno', 'usuario'),
  ('user2@ejemplo.com', 'Usuario', 'Dos', 'usuario'),
  ('user3@ejemplo.com', 'Usuario', 'Tres', 'usuario'),
  ('user4@ejemplo.com', 'Usuario', 'Cuatro', 'usuario');

-- 3. Crear tabla posts
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  titulo VARCHAR(200) NOT NULL,
  contenido TEXT NOT NULL,
  fecha_creacion TIMESTAMP NOT NULL,
  fecha_actualizacion TIMESTAMP NOT NULL,
  destacado BOOLEAN NOT NULL,
  usuario_id BIGINT
);

-- 4. Insertar 5 posts según consigna
INSERT INTO posts (titulo, contenido, fecha_creacion, fecha_actualizacion, destacado, usuario_id) VALUES
  ('Título Admin 1', 'Contenido del post 1', NOW(), NOW(), TRUE, 1),
  ('Título Admin 2', 'Contenido del post 2', NOW(), NOW(), FALSE, 1),
  ('Título Usuario 1', 'Contenido del post 3', NOW(), NOW(), FALSE, 2),
  ('Título Usuario 2', 'Contenido del post 4', NOW(), NOW(), TRUE, 2),
  ('Título Sin Autor', 'Contenido del post 5', NOW(), NOW(), FALSE, NULL);

-- 5. Crear tabla comentarios
CREATE TABLE comentarios (
  id SERIAL PRIMARY KEY,
  contenido TEXT NOT NULL,
  fecha_creacion TIMESTAMP NOT NULL,
  usuario_id BIGINT NOT NULL,
  post_id BIGINT NOT NULL
);

-- 6. Insertar 5 comentarios según consigna
INSERT INTO comentarios (contenido, fecha_creacion, usuario_id, post_id) VALUES
  ('Comentario 1', NOW(), 1, 1),
  ('Comentario 2', NOW(), 2, 1),
  ('Comentario 3', NOW(), 3, 1),
  ('Comentario 4', NOW(), 1, 2),
  ('Comentario 5', NOW(), 2, 2);

-- 7. Nombre y email junto a título y contenido del post (punto 2)
SELECT u.nombre, u.email, p.titulo, p.contenido
FROM usuarios u
JOIN posts p ON u.id = p.usuario_id;

-- 8. id, título y contenido de los posts de administradores (punto 3)
SELECT p.id, p.titulo, p.contenido
FROM posts p
WHERE p.usuario_id IN (
  SELECT id FROM usuarios WHERE rol = 'administrador'
);

-- 9. Cantidad de posts por usuario (id y email, punto 4)
SELECT u.id, u.email, COUNT(p.id) AS cantidad_posts
FROM usuarios u
LEFT JOIN posts p ON u.id = p.usuario_id
GROUP BY u.id, u.email;

-- 10. Email del usuario con más posts (punto 5)
SELECT u.email
FROM usuarios u
JOIN posts p ON u.id = p.usuario_id
GROUP BY u.email
ORDER BY COUNT(p.id) DESC
LIMIT 1;

-- 11. Fecha del último post de cada usuario (punto 6)
SELECT u.id, MAX(p.fecha_creacion) AS fecha_ultimo_post
FROM usuarios u
LEFT JOIN posts p ON u.id = p.usuario_id
GROUP BY u.id;

-- 12. Título y contenido del post con más comentarios (punto 7)
SELECT p.titulo, p.contenido
FROM posts p
JOIN comentarios c ON p.id = c.post_id
GROUP BY p.id, p.titulo, p.contenido
ORDER BY COUNT(c.id) DESC
LIMIT 1;

-- 13. Título, contenido del post y comentario con email del autor (punto 8)
SELECT p.titulo AS post_titulo,
       p.contenido AS post_contenido,
       c.contenido AS comentario_contenido,
       u.email AS email_comentador
FROM posts p
LEFT JOIN comentarios c ON p.id = c.post_id
LEFT JOIN usuarios u ON c.usuario_id = u.id;

-- 14. Contenido del último comentario de cada usuario (punto 9)
SELECT c.usuario_id, c.contenido
FROM comentarios c
WHERE (c.usuario_id, c.fecha_creacion) IN (
  SELECT usuario_id, MAX(fecha_creacion)
  FROM comentarios
  GROUP BY usuario_id
);

-- 15. Emails de usuarios sin comentarios (punto 10)
SELECT u.email
FROM usuarios u
LEFT JOIN comentarios c ON u.id = c.usuario_id
WHERE c.id IS NULL;
