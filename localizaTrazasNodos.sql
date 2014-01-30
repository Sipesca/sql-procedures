-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `localizaTrazasNodos`(in fechaMIN Varchar(40), in fechaMAX Varchar(40), in intervalo INT)
BEGIN

DECLARE inter INT DEFAULT intervalo*1000*60;
DECLARE corte INT DEFAULT 19;

IF intervalo >= 1440 THEN SET corte = 10; END IF;

SELECT STRAIGHT_JOIN SUBSTR(FROM_UNIXTIME(truncate(t1.tinicio/inter,0)*inter/1000),1,corte) as Fecha,
		#t1.idDispositivo,
		t1.idNodo as Origen,
		#t1.tinicio as Origen_inicio,
		#t1.tfin as Origen_fin,
		#t1.tfin-t1.tinicio as Origen_dif,
		t2.idNodo as Destino,
		#t2.tinicio as Destino_Inicio,
		#t2.tfin as Destino_fin,
		#t2.tfin-t2.tinicio as Destino_dif, 
		#from_unixtime(t1.tinicio/1000) as Origen_fecha,
		#from_unixtime(t2.tinicio/1000) as Destino_fecha,
	 count(*) as total,
	 avg(t2.tinicio - t1.tinicio)/1000 as Diferencia
	FROM
		(SELECT idNodo,tinicio,idDispositivo FROM __paso
			WHERE tinicio
					BETWEEN  UNIX_TIMESTAMP(fechaMIN)*1000
					AND  UNIX_TIMESTAMP(fechaMAX)*1000 
		) as t1 
		INNER JOIN 
			(SELECT idNodo,tinicio,idDispositivo FROM __paso 
				WHERE tinicio
					BETWEEN  UNIX_TIMESTAMP(fechaMIN)*1000-inter
					AND  UNIX_TIMESTAMP(fechaMAX)*1000+inter 
AND (t2.tinicio - t1.tinicio) BETWEEN 0 AND inter
			) as t2 
			ON	
				t1.idDispositivo = t2.idDispositivo 
				AND t1.idNodo <> t2.idNodo
				#AND (t2.tinicio - t1.tinicio) BETWEEN 0 AND inter
	GROUP BY
		t1.idNodo, t2.idNodo,
		truncate(t1.tinicio/inter,0)
	ORDER BY fecha DESC
	#LIMIT 20
;


END