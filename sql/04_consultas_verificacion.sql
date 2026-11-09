USE veterinaria_db;

SELECT VERSION() AS Version_Servidor;

SHOW TABLES;

SELECT CONSTRAINT_TYPE, COUNT(*) AS Total
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'veterinaria_db'
GROUP BY CONSTRAINT_TYPE
ORDER BY CONSTRAINT_TYPE;

DESCRIBE Cliente;
DESCRIBE Mascota;
DESCRIBE Historial_Responsable;
DESCRIBE Cita;
DESCRIBE Venta;

SELECT 'Cliente' AS Tabla, COUNT(*) AS Filas FROM Cliente
UNION ALL SELECT 'Veterinario', COUNT(*) FROM Veterinario
UNION ALL SELECT 'Cajero', COUNT(*) FROM Cajero
UNION ALL SELECT 'Proveedor', COUNT(*) FROM Proveedor
UNION ALL SELECT 'Mascota', COUNT(*) FROM Mascota
UNION ALL SELECT 'Historial_Responsable', COUNT(*) FROM Historial_Responsable
UNION ALL SELECT 'Prestacion', COUNT(*) FROM Prestacion
UNION ALL SELECT 'Producto', COUNT(*) FROM Producto
UNION ALL SELECT 'Cita', COUNT(*) FROM Cita
UNION ALL SELECT 'Venta', COUNT(*) FROM Venta
UNION ALL SELECT 'Ficha_Medica', COUNT(*) FROM Ficha_Medica
UNION ALL SELECT 'Inventario', COUNT(*) FROM Inventario
UNION ALL SELECT 'Detalle_Venta', COUNT(*) FROM Detalle_Venta
UNION ALL SELECT 'Detalle_Prestacion', COUNT(*) FROM Detalle_Prestacion;

SELECT ci.N_Cita, ci.Fecha_Hora, ci.Estado, m.Nombre AS Mascota,
       c.Nombre AS Dueno, v.Nombre AS Veterinario
FROM Cita ci
JOIN Mascota m ON m.ID_Mascota = ci.ID_Mascota
JOIN Cliente c ON c.Rut_Cliente = m.Rut_Cliente
JOIN Veterinario v ON v.Rut_Veterinario = ci.Rut_Veterinario
ORDER BY ci.Fecha_Hora;

SELECT f.ID_Ficha, m.Nombre AS Mascota, f.Diagnostico,
       v.Nombre AS Veterinario, f.Fecha_Registro
FROM Ficha_Medica f
JOIN Cita ci ON ci.N_Cita = f.N_Cita
JOIN Mascota m ON m.ID_Mascota = ci.ID_Mascota
JOIN Veterinario v ON v.Rut_Veterinario = f.Rut_Veterinario;

SELECT v.ID_Venta, v.Fecha_Pago, c.Nombre AS Cliente, v.Monto_Venta,
       (SELECT SUM(Subtotal) FROM Detalle_Venta dv
        WHERE dv.ID_Venta = v.ID_Venta) AS Total_Productos,
       (SELECT SUM(Subtotal) FROM Detalle_Prestacion dp
        WHERE dp.ID_Venta = v.ID_Venta) AS Total_Prestaciones
FROM Venta v
LEFT JOIN Cliente c ON c.Rut_Cliente = v.Rut_Cliente;

SELECT v.Nombre AS Veterinario, ci.Estado, COUNT(*) AS Cantidad
FROM Cita ci
JOIN Veterinario v ON v.Rut_Veterinario = ci.Rut_Veterinario
GROUP BY v.Nombre, ci.Estado
ORDER BY v.Nombre, ci.Estado;

SELECT m.Nombre AS Mascota, ci.Fecha_Hora, f.Diagnostico,
       f.Tratamiento, v.Nombre AS Veterinario
FROM Mascota m
JOIN Cita ci ON ci.ID_Mascota = m.ID_Mascota
JOIN Ficha_Medica f ON f.N_Cita = ci.N_Cita
JOIN Veterinario v ON v.Rut_Veterinario = f.Rut_Veterinario
ORDER BY m.Nombre, ci.Fecha_Hora;

SELECT ca.Nombre AS Cajero, v.Fecha_Pago, COUNT(*) AS Ventas,
       SUM(v.Monto_Venta) AS Total
FROM Venta v
JOIN Cajero ca ON ca.Rut_Cajero = v.Rut_Cajero
GROUP BY ca.Nombre, v.Fecha_Pago
ORDER BY v.Fecha_Pago, ca.Nombre;

SELECT ID_Producto, Nombre_Producto, Precio_Unitario, Stock, Fecha_Vencimiento
FROM Producto
WHERE Stock < 30 OR Fecha_Vencimiento <= '2026-12-31'
ORDER BY Fecha_Vencimiento;

SELECT pr.Nombre_Prestacion, SUM(dp.Cantidad) AS Veces,
       SUM(dp.Subtotal) AS Ingresos
FROM Detalle_Prestacion dp
JOIN Prestacion pr ON pr.ID_Prestacion = dp.ID_Prestacion
GROUP BY pr.ID_Prestacion, pr.Nombre_Prestacion
ORDER BY Ingresos DESC;

SELECT c.Nombre AS Cliente, COUNT(m.ID_Mascota) AS Mascotas,
       GROUP_CONCAT(m.Nombre ORDER BY m.Nombre SEPARATOR ', ') AS Nombres
FROM Cliente c
LEFT JOIN Mascota m ON m.Rut_Cliente = c.Rut_Cliente
GROUP BY c.Rut_Cliente, c.Nombre
ORDER BY Mascotas DESC, c.Nombre;

SELECT ci.N_Cita, ci.Fecha_Hora, ci.Estado,
       m.Nombre AS Mascota, c.Nombre AS Cliente, v.Nombre AS Veterinario
FROM Cita ci
JOIN Mascota m ON m.ID_Mascota = ci.ID_Mascota
JOIN Cliente c ON c.Rut_Cliente = m.Rut_Cliente
JOIN Veterinario v ON v.Rut_Veterinario = ci.Rut_Veterinario
ORDER BY ci.Fecha_Hora;

SELECT v.Rut_Veterinario, v.Nombre AS Veterinario, ci.N_Cita,
       ci.Fecha_Hora, ci.Estado, ci.Bloque_Activo, m.Nombre AS Mascota
FROM Cita ci
JOIN Veterinario v ON v.Rut_Veterinario = ci.Rut_Veterinario
JOIN Mascota m ON m.ID_Mascota = ci.ID_Mascota
WHERE ci.Bloque_Activo IS NOT NULL
ORDER BY ci.Bloque_Activo, v.Nombre;

SELECT c.Rut_Cliente, c.Nombre AS Cliente, v.ID_Venta, v.Fecha_Pago, v.Forma_Pago,
       p.Nombre_Producto AS Producto, dv.Cantidad AS Cant_Prod, dv.Subtotal AS Subtotal_Prod,
       pr.Nombre_Prestacion AS Prestacion, dp.Subtotal AS Subtotal_Prest,
       v.Monto_Venta AS Total_Venta
FROM Venta v
LEFT JOIN Cliente c ON c.Rut_Cliente = v.Rut_Cliente
LEFT JOIN Detalle_Venta dv ON dv.ID_Venta = v.ID_Venta
LEFT JOIN Producto p ON p.ID_Producto = dv.ID_Producto
LEFT JOIN Detalle_Prestacion dp ON dp.ID_Venta = v.ID_Venta
LEFT JOIN Prestacion pr ON pr.ID_Prestacion = dp.ID_Prestacion
ORDER BY v.Fecha_Pago, v.ID_Venta;

SELECT pr.Rut_Proveedor, pr.Nombre_Proveedor AS Proveedor,
       p.Nombre_Producto AS Producto, i.Tipo_Movimiento,
       i.Cantidad, i.Fecha_Movimiento
FROM Inventario i
JOIN Producto p ON p.ID_Producto = i.ID_Producto
JOIN Proveedor pr ON pr.Rut_Proveedor = i.Rut_Proveedor
WHERE i.Tipo_Movimiento = 'entrada'
ORDER BY i.Fecha_Movimiento;

SELECT m.ID_Mascota, m.Nombre AS Mascota, c.Rut_Cliente,
       c.Nombre AS Cliente_Responsable, h.Fecha_Inicio, h.Fecha_Fin,
       IF(h.Fecha_Fin IS NULL, 'Vigente', 'Histórico') AS Estado_Tenencia
FROM Historial_Responsable h
JOIN Mascota m ON m.ID_Mascota = h.ID_Mascota
JOIN Cliente c ON c.Rut_Cliente = h.Rut_Cliente
ORDER BY m.ID_Mascota, h.Fecha_Inicio;
