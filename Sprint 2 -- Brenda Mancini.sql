    CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

    -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );


    -- Creamos la tabla transaction
    CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15) REFERENCES credit_card(id),
        company_id VARCHAR(20), 
        user_id INT REFERENCES user(id),
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id) 
    );


-- Utilitzant JOIN realitzaràs les següents consultes:
 -- Llistat dels països que estan generant vendes.
-- Des de quants països es generen les vendes.
-- Identifica la companyia amb la mitjana més gran de vendes.

SELECT DISTINCT c.country
FROM transaction t
INNER JOIN company c
ON t.company_id=c.id
WHERE t.declined=0;

SELECT COUNT(DISTINCT c.country) AS cantidad_paises_ventas
FROM transaction t 
INNER JOIN company c
ON t.company_id=c.id
WHERE t.declined=0;

SELECT t.company_id, c.company_name, ROUND(AVG(t.amount), 2) AS media_ventas
FROM transaction t
INNER JOIN company c 
ON t.company_id=c.id
WHERE t.declined=0
GROUP BY t.company_id
ORDER BY AVG(t.amount) DESC
LIMIT 1;

-- litzant només subconsultes (sense utilitzar JOIN):

-- tra totes les transaccions realitzades per empreses d'Alemanya.
-- sta les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
-- minaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

SELECT * 
FROM transaction t
WHERE t.company_id IN(SELECT DISTINCT c.id
					FROM company c
                    WHERE c.country="Germany");

SELECT c.id, c.company_name
FROM company c
WHERE c.id IN(SELECT DISTINCT t.company_id
			FROM transaction t
			WHERE t.amount>(SELECT AVG(t.amount) AS media FROM transaction t));

SELECT c.id, c.company_name
FROM company c
WHERE NOT EXISTS (SELECT *
					FROM transaction t
                    WHERE t.company_id=c.id);

-- Ejercicio 4

    -- Creamos la tabla credit_card
CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(15) PRIMARY KEY,
        iban VARCHAR(255),
        pan VARCHAR(20),
        pin VARCHAR(5),
        cvv VARCHAR(5),
        expiring_date DATE
);

ALTER TABLE credit_card 
    MODIFY COLUMN pan VARCHAR(19),
    MODIFY COLUMN pin VARCHAR(4),
    MODIFY COLUMN cvv VARCHAR(4);

ALTER TABLE transaction ADD CONSTRAINT fk_transaction_credit_card FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- Ejercicio 5
-- El departament de Recursos Humans ha identificat un error en el número de compte associat a la targeta 
-- de crèdit amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: TR323456312213576817699999. 
-- Recorda mostrar que el canvi es va realitzar.

UPDATE credit_card 
SET iban = 'TR323456312213576817699999' 
WHERE id = 'CcU-2938';

SELECT iban
FROM credit_card
WHERE id = 'CcU-2938';

-- Ejercicio 6
-- En la taula "transaction" ingressa una nova transacció amb la següent informació:
-- no me deja insertar el valor porque no está registrado este id de company. Lo inserto primero en company (resto de datos "NULL") y luego hago el insert del registro en transaction.

INSERT INTO company (id) VALUES ('b-9999');
INSERT INTO credit_card (id) VALUES ('CcU-9999');
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', NOW(), '111.11', '0');

-- Ejercicio 7
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. 
-- Recorda mostrar el canvi realitzat.

ALTER TABLE credit_card 
DROP COLUMN pan;

SELECT pan FROM credit_card;

-- Descarrega els arxius CSV que trobaràs a l'apartat de recursos:

-- american_users.csv
-- european_users.csv
-- companies.csv
-- credit_cards.csv
-- transactions.csv
-- Estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, almenys 4 taules de les quals puguis realitzar les següents consultes:
-- La taula de products.csv l'utilitzarem més endavant.

CREATE DATABASE transactions8;
USE transactions8;

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    surname VARCHAR(50),
    phone VARCHAR(30),
    email VARCHAR(100),
    birth_date VARCHAR(30),
    country VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    address VARCHAR(255),
    signup_date DATE,
    user_segment VARCHAR(50),
    income_band VARCHAR(20),
    region ENUM('american', 'european') NOT NULL
);

CREATE TABLE companies (
	company_id VARCHAR(15) PRIMARY KEY,
    company_name VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(100),
    country VARCHAR(50),
    website VARCHAR(255),
    merchant_category VARCHAR(50),
    merchant_price_position VARCHAR(50)
);

CREATE TABLE credit_cards(
	id VARCHAR(15) PRIMARY KEY,
    user_id VARCHAR(15),
    iban VARCHAR(255),
    pan VARCHAR(19),
    pin VARCHAR(4),
    cvv VARCHAR(4),
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date VARCHAR(15),
    card_type VARCHAR(20),
    card_renewal_flag VARCHAR(5)
);

CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        card_id VARCHAR(15) REFERENCES credit_cards(id),
        business_id VARCHAR(20), 
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        product_ids VARCHAR(255),
        user_id INT REFERENCES users(id),
        lat FLOAT,
        longitude FLOAT,
        discount_amount DECIMAL(10, 2),
        tax_amount DECIMAL(10, 2),
        shipping_amount DECIMAL(10, 2),
        channel VARCHAR(30),
        campaign_id VARCHAR(50),
        device_type VARCHAR(30),
        is_international BOOLEAN,
        decline_reason VARCHAR(255),
        distance_km DECIMAL(10, 2),
        FOREIGN KEY (business_id) REFERENCES companies(company_id) 
    );

ALTER TABLE transaction
    ADD CONSTRAINT fk_transaction_users 
        FOREIGN KEY (user_id) REFERENCES users(id),
    ADD CONSTRAINT fk_transaction_credit_card 
        FOREIGN KEY (card_id) REFERENCES credit_cards(id);


ALTER TABLE credit_cards 
	MODIFY COLUMN user_id INT;

ALTER TABLE credit_cards
	ADD CONSTRAINT fk_credit_cards_users
    FOREIGN KEY (user_id) REFERENCES users(id);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__american_users.csv' 
INTO TABLE users 
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(id,name,surname,phone,email,birth_date,country,city,postal_code,address,signup_date,user_segment,income_band)
SET region = 'american';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__credit_cards.csv' 
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES
(id,user_id,iban,pan,pin,cvv,track1,track2,expiring_date,card_type,card_renewal_flag);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__european_users.csv' 
INTO TABLE users 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(id,name,surname,phone,email,birth_date,country,city,postal_code,address,signup_date,user_segment,income_band)
SET region = 'european'; 

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__companies.csv' 
INTO TABLE companies
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(company_id,company_name,phone,email,country,website,merchant_category,merchant_price_position);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__transactions.csv' 
INTO TABLE transaction
FIELDS TERMINATED BY ';' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 LINES 
(id,card_id,business_id,timestamp,amount,declined,product_ids,user_id,lat,longitude,discount_amount,tax_amount,shipping_amount,channel,campaign_id,device_type,is_international,decline_reason,distance_km);

-- Exercici 9
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.

SELECT u.id, u.name
FROM users u
WHERE u.id IN(SELECT t.user_id
			FROM transaction t
			GROUP BY t.user_id
			HAVING COUNT(*)>80);

-- Exercici 10
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT cc.iban, ROUND(AVG(t.amount), 2) AS media_monto
FROM transaction t
JOIN credit_cards cc
ON cc.id = t.card_id
JOIN companies c
ON c.company_id=t.business_id
WHERE c.company_name = "Donec Ltd"
GROUP BY cc.iban;

-- Nivell 2

-- Exercici 1
-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT DATE(t.timestamp) AS fecha, SUM(t.amount) AS suma_monto
FROM transaction t
WHERE declined=0
GROUP BY DATE(t.timestamp)
ORDER BY SUM(t.amount) DESC
LIMIT 5;

-- Exercici 2
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor 
-- comprès entre 350 i 400 euros i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de 
-- març del 2024. Ordena els resultats de major a menor quantitat.

SELECT c.company_name, c.phone, c.country, DATE(t.timestamp) AS fecha, t.amount
FROM transaction t
JOIN companies c
ON c.company_id=t.business_id
WHERE t.amount>=350 AND t.amount<=400 AND DATE(t.timestamp) IN("2015-04-29", "2018-07-20", "2024-03-13")
ORDER BY t.amount DESC;

-- Exercici 3
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, però 
-- el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen igual o 
-- més de 400 transaccions o menys.

SELECT c.company_name, COUNT(*) AS cant_transacciones,
	CASE 
		WHEN COUNT(*)>=400 THEN "Mayor o igual a 400"
        ELSE "Menor a 400"
    END AS cantidad_transacciones
FROM transaction t
JOIN companies c
ON c.company_id=t.business_id
GROUP BY t.company_id
ORDER BY COUNT(*) DESC;

-- Exercici 4
-- Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de dades.

DELETE FROM transaction
WHERE id="000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";

-- Exercici 5
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. Serà 
-- necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. 
-- Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, 
-- ordenant les dades de major a menor mitjana de compra.

CREATE OR REPLACE VIEW VistaMarketing AS
SELECT c.company_id, c.company_name, c.phone, c.country, ROUND(AVG(t.amount), 2) AS media_compra
FROM transaction t
JOIN companies c
ON c.company_id=t.business_id
WHERE t.declined=0
GROUP BY c.company_id
ORDER BY media_compra DESC;

SELECT * FROM VistaMarketing ORDER BY media_compra DESC;

-- Nivell 3
-- Exercici 1
-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les tres últimes transaccions 
-- han estat declinades aleshores és inactiu, si almenys una no és rebutjada aleshores és actiu. Partint d’aquesta 
-- taula respon:

-- 👉 Quantes targetes estan actives?

SELECT evaluadas_declinadas.card_id, current_timestamp() AS fecha_evaluacion,
	CASE
		WHEN evaluadas_declinadas.cantidad_evaluadas>0 AND evaluadas_declinadas.cantidad_declinadas!=evaluadas_declinadas.cantidad_evaluadas THEN "activo"
		ELSE "inactivo"
	END AS "estado_tarjetas"
FROM
	(
	SELECT ultimas_tres_tarjetas.card_id, COUNT(*) AS cantidad_evaluadas, SUM(declined) AS cantidad_declinadas, ultimas_tres_tarjetas.timestamp
	FROM
		(
		SELECT t1.card_id, t1.declined, t1.timestamp 
		FROM transaction t1 
		WHERE ( SELECT COUNT(*) AS cant_decl
				FROM transaction t2 
				WHERE t2.card_id = t1.card_id AND t2.timestamp > t1.timestamp ) < 3
		) AS ultimas_tres_tarjetas 
	GROUP BY ultimas_tres_tarjetas.card_id, ultimas_tres_tarjetas.timestamp
	) AS evaluadas_declinadas;
USE transactions8;

SELECT COUNT(DISTINCT contar_activas.card_id) AS cantidad_tarjetas_activas
FROM
(
SELECT evaluadas_declinadas.card_id, current_timestamp(),
	CASE
		WHEN evaluadas_declinadas.cantidad_evaluadas>0 AND evaluadas_declinadas.cantidad_declinadas!=evaluadas_declinadas.cantidad_evaluadas THEN "activo"
		ELSE "inactivo"
	END AS "estado_tarjetas"
FROM
	(
	SELECT ultimas_tres_tarjetas.card_id, COUNT(*) AS cantidad_evaluadas, SUM(declined) AS cantidad_declinadas, ultimas_tres_tarjetas.timestamp
	FROM
		(
		SELECT t1.card_id, t1.declined, t1.timestamp 
		FROM transaction t1 
		WHERE ( SELECT COUNT(*) AS cant_decl
				FROM transaction t2 
				WHERE t2.card_id = t1.card_id AND t2.timestamp > t1.timestamp ) < 3
		) AS ultimas_tres_tarjetas 
	GROUP BY ultimas_tres_tarjetas.card_id, ultimas_tres_tarjetas.timestamp
	) AS evaluadas_declinadas) AS contar_activas
WHERE contar_activas.estado_tarjetas="activo";

-- Exercici 2
-- Crea una taula amb la qual puguem unir les dades de l'arxiu de products.csv amb la base de dades creada 
-- (ja que fins ara no podíem fer-ho), tenint en compte que des de transaction tens product_ids. Genera la 
-- següent consulta:

-- 👉 Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

CREATE TABLE IF NOT EXISTS products (
	id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    colour VARCHAR(100),
    weight VARCHAR(100),
    warehouse_id VARCHAR(100),
    category VARCHAR(100),
    brand VARCHAR(100),
    cost DECIMAL(10, 2),
    launch_date DATE);


CREATE TABLE transaction_products (
    transaction_id VARCHAR(255),
    product_id INT,
    PRIMARY KEY (transaction_id, product_id),
    CONSTRAINT fk_transaction 
        FOREIGN KEY (transaction_id) REFERENCES transaction(id) 
        ON DELETE RESTRICT,
    CONSTRAINT fk_product 
        FOREIGN KEY (product_id) REFERENCES products(id) 
        ON DELETE RESTRICT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/N1-Ex.8__products.csv' 
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(id, product_name, @price, colour, weight, warehouse_id, category, brand, @cost, launch_date)
SET 
    price = CAST(REPLACE(@price, '$', '') AS DECIMAL(10, 2)),
    cost = CAST(REPLACE(@cost, '$', '') AS DECIMAL(10, 2));

INSERT INTO transaction_products (transaction_id, product_id)
SELECT 
    t.id,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ',', n.n), ',', -1)) AS product_id
FROM transaction t
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 
    UNION ALL SELECT 9 UNION ALL SELECT 10
) n 
ON CHAR_LENGTH(t.product_ids) - CHAR_LENGTH(REPLACE(t.product_ids, ',', '')) >= n.n - 1;

ALTER TABLE transaction DROP COLUMN product_ids;

SELECT tp.product_id, COUNT(*)
FROM transaction_products tp
GROUP BY tp.product_id;
