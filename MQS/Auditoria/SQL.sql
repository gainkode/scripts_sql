-- ! SCRIPT PARA HACER COPIA DE BASE DE DATOS DE PRODUCCION Y ELIMINAR DATOS DE ALGUNOS CLIENTES 

-- ! COMANDOS
-- ! //////////////////////////////////////////////////  
# COPIAR BASE DE DATOS DE PRODUCCION
pg_dump -U doadmin -h mqs-2024-pd-bd-do-user-17915275-0.g.db.ondigitalocean.com -p 25060 -Fc defaultdb > backup_produccion.dump


# Paso 1: Borrar el contenido de la base de datos actual  
psql -U doadmin -h mqs-2024-pd-bd-do-user-17915275-0.g.db.ondigitalocean.com -p 25060 -d defaultdb -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"


# Paso 2: Restaurar desde el volcado
En Dbveaver database -> tools -> Execute SQL Script



-- ! VER DATOS ANTES DE ELIMINAR
-- ! ////////////////////////////////////////////////// 
-- 1. Seleccionar registros en la tabla `order` con `supplierId` 7 o 4 O donde `clientId` sea 3 O donde `NUMBER` esté entre 5240 y 5260
SELECT * FROM "order" WHERE "supplierId" IN (7, 4) OR "clientId" = 3 OR "number" BETWEEN 5240 AND 5260;

-- 2. Seleccionar registros en la tabla `delivery_note` relacionados con los pedidos seleccionados
SELECT * FROM "delivery_note" WHERE "orderId" IN (SELECT "id" FROM "order" WHERE "supplierId" IN (7, 4) OR "clientId" = 3 OR "number" BETWEEN 5240 AND 5260);

-- 3. Seleccionar registros en la tabla `settlement` relacionados con las notas de entrega seleccionadas
SELECT * FROM "settlement" WHERE "deliveryNoteId" IN (SELECT "id" FROM "delivery_note" WHERE "orderId" IN (SELECT "id" FROM "order" WHERE "supplierId" IN (7, 4) OR "clientId" = 3 OR "number" BETWEEN 5240 AND 5260));

-- 4. Seleccionar registros en la tabla `invoice` relacionados con los pedidos seleccionados
SELECT * FROM "invoice_orders_order" WHERE "orderId" IN (SELECT "id" FROM "order" WHERE "supplierId" IN (7, 4) OR "clientId" = 3 OR "number" BETWEEN 5240 AND 5260);



-- ! ELIMINAR DATOS
-- ! //////////////////////////////////////////////////
-- Iniciar la transacción
BEGIN;

-- 1. Eliminar registros de la tabla `invoice` relacionados con los pedidos que serán eliminados
DELETE FROM "invoice_orders_order" WHERE "orderId" IN (SELECT "id" FROM "order" WHERE "supplierId" IN (7, 4) OR "clientId" = 3 OR "number" BETWEEN 5240 AND 5260);

-- 2. Eliminar registros de la tabla `settlement` relacionados con las notas de entrega que serán eliminadas
DELETE FROM "settlement" WHERE "deliveryNoteId" IN (SELECT "id" FROM "delivery_note" WHERE "orderId" IN (SELECT "id" FROM "order" WHERE "supplierId" IN (7, 4) OR "clientId" = 3 OR "number" BETWEEN 5240 AND 5260));

-- 3. Eliminar registros de la tabla `delivery_note` relacionados con los pedidos que serán eliminados
DELETE FROM "delivery_note" WHERE "orderId" IN (SELECT "id" FROM "order" WHERE "supplierId" IN (7, 4) OR "clientId" = 3 OR "number" BETWEEN 5240 AND 5260);

-- 4. Eliminar registros de la tabla `order` con `supplierId` 7 o 4 O `clientId` igual a 3 O con `NUMBER` entre 5240 y 5260
DELETE FROM "order" WHERE "supplierId" IN (7, 4) OR "clientId" = 3 OR "number" BETWEEN 5240 AND 5260;

-- 5. Eliminar registros de la tabla `client` con `id` igual a 3
DELETE FROM "client" WHERE "id" = 3;

-- PRUEBA: Si quieres ver el resultado sin aplicarlo aún, usa ROLLBACK
-- ROLLBACK;

-- REAL: Si estás seguro de los cambios, aplica el COMMIT
-- COMMIT;