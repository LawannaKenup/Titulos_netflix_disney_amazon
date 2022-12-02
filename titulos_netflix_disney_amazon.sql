-- Criação de 3 tabelas temporarias chamadas 'netflix', 'disney' e 'amazon' contendo uma nova
-- coluna chamada 'show_id2' com um novo id para as tabelas 'netflix_titles', 'disney_plus_titles',
-- e 'amazon_prime_titles'.


-- Tabela netflix:

CREATE TEMPORARY TABLE netflix AS 
SELECT *, 
CASE 
	WHEN show_id LIKE '%s%' THEN REPLACE(show_id, 's', 'n')
END AS show_id
FROM netflix_titles;

-- Tabela disney:

CREATE TEMPORARY TABLE disney AS
SELECT *,
CASE 
	WHEN show_id LIKE '%s%' THEN REPLACE(show_id, 's', 'd')
END AS show_id2
FROM disney_plus_titles;

-- Tabela amazon:

CREATE TEMPORARY TABLE amazon AS 
SELECT *, 
CASE
	WHEN show_id LIKE '%s%' THEN REPLACE(show_id, 's', 'a') 
END AS show_id2 
FROM amazon_prime_titles;

-- Criação de uma tabela temporaria fazendo uma união entre as 3 tabelas 'netflix', 
-- 'disney' e 'amazon'.

CREATE TEMPORARY TABLE tabelao AS
SELECT  *
FROM netflix
UNION ALL 
SELECT * 
FROM disney
UNION ALL
SELECT * 
FROM amazon;

-- Criação de uma nova tabela chamada 'tabelao1' alterando os valores vazios por Null.

CREATE TABLE tabelao1 AS 
SELECT
		show_id2,
    	"type", 
    	title,
    	CASE
			WHEN director = '' THEN Null
    	 		ELSE director
    	END AS director,
    	CASE
			WHEN "cast"= '' THEN Null
    	 		ELSE "cast"
    	END AS "cast",
    	CASE 
			WHEN country = '' THEN Null
    			ELSE country
    	END AS country,
    	CASE 
			WHEN date_added = '' THEN Null
    			ELSE date_added
    	END AS date_added,
    	release_year, 
    	CASE 
			WHEN rating = '' THEN Null
    			ELSE rating
    	END AS rating,
    	CASE 
			WHEN duration ='' THEN Null
    			ELSE duration
    	END AS duration,
    	listed_in,
    	description
FROM tabelao;

-- Normalização das colunas 'cast', 'country', 'listed_in', 'date_added' e 'duration' da 
-- tabela 'tabelao1'.


-- Coluna 'cast':

CREATE  TABLE cast_table AS(
	
	WITH cast_table AS 
	(
    	SELECT show_id2, UNNEST(string_to_array("cast", ',')) AS split_cast
    	FROM tabelao1
	)

SELECT * FROM cast_table
);

-- Coluna 'listed_in': 

CREATE  TABLE genre_table AS (

	WITH genre_table AS 
	(
		SELECT show_id2, UNNEST(string_to_array(listed_in, ',')) split_listed_in 
		FROM tabelao1
    )

SELECT * FROM genre_table
);

-- Coluna 'date_added':

CREATE  TABLE  date_table as (
	
	WITH  date_table as 
	(
		SELECT  show_id2, date_added,
    	CASE 
    		WHEN date_added LIKE '%%' THEN EXTRACT(DAY FROM CAST(date_added AS DATE)) 
    	END AS "day",
    	CASE
    		WHEN date_added LIKE '%%' THEN EXTRACT(MONTH FROM CAST(date_added AS DATE))
    	END AS "month",
    	CASE
    		WHEN date_added LIKE '%%' THEN EXTRACT(YEAR FROM cast(date_added AS DATE))
    	END  AS "YEAR", 
  		CASE 
    		WHEN date_added LIKE '%%' THEN CAST(date_added AS DATE)
  		END AS iso_date_1,
  		CASE
    		WHEN date_added LIKE '%%' THEN (EXTRACT(YEAR FROM CAST(date_added AS DATE))||'/'||
    		                                EXTRACT(MONTH FROM CAST(date_added AS DATE))||'/'||
 		                                    EXTRACT(DAY FROM CAST(date_added AS DATE))) 
 		END AS iso_date_2,
  		CASE
    		WHEN date_added LIKE '%%' THEN TO_CHAR(CAST(date_added AS DATE), 'yymmdd') 
  		END AS iso_date_3,
  		CASE
  		  	WHEN date_added LIKE '%%' THEN TO_CHAR(CAST(date_added AS DATE), 'yyyymmdd') 
  		END AS iso_date_4
		FROM tabelao1
  	)

SELECT * FROM date_table
);

-- Coluna 'duration':

CREATE  TABLE time_table AS (
	
	WITH time_table1 AS 
	(
		SELECT show_id2, duration, 
  		CASE
  			WHEN (string_to_array(duration, ' '))[2] LIKE 'Season%' 
				THEN (string_to_array(duration, ' '))[1]::INT * 10
  			WHEN (string_to_array(duration, ' '))[2] = 'min' 
				THEN to_char(to_timestamp((string_to_array(duration, ' '))[1]::INT * 60),'HH24')::INT
  		END AS HOURS,
    	CASE
  			WHEN (string_to_array(duration, ' '))[2] LIKE 'Season%' 
				THEN (string_to_array(duration, ' '))[1]::INT * 600
  			WHEN (string_to_array(duration, ' '))[2] = 'min' 
				THEN (string_to_array(duration, ' '))[1]::INT
  		END AS MINUTES
  		FROM tabelao1
	)
    
SELECT * FROM time_table1
);

-- Análise dos dados para averiguar quais séres tem tempo de duração somados de 30 horas ou mais.

SELECT "type", title, SUM(hours) temopo_total
FROM tabelao1 t
INNER JOIN time_table tt ON t.show_id2 = tt.show_id2
GROUP BY title, "type"
HAVING SUM(hours) >= 30  AND "type" LIKE '%TV Show%';

-- Criação de uma coluna que tem a informação particionada pela categoria e realização de uma
-- consulta do tempo máximo em horas de cada segmento.

SELECT
	title,
	split_listed_in,
	MAX(hours) OVER (PARTITION BY split_listed_in) AS tempo_max_genero
FROM tabelao1 t
INNER JOIN time_table tt ON t.show_id2 = tt.show_id2
INNER JOIN genre_table g ON t.show_id2 = g.show_id2
WHERE "type" LIKE '%Movie%';

-- Criação de uma tabela para normalizar os dados da coluna 'director' chamada 'director_table'. 

CREATE TABLE director_table AS (
	
	WITH director_table AS 
	( 
		SELECT show_id2, UNNEST(string_to_array(director, ',')) AS "split_director" 
		FROM tabelao1
	)

SELECT * FROM director_table
);

-- Criação de uma tabela com uma nova coluna de classificação dos conteudos por 
-- estrelas pelos seguintes critérios:

-- 1. O conteúdo precisa ter no mínimo 120 minutos. =  uma estrela (*); 
-- 2. A produção ser americana. =  uma estrela (*);
-- 3. A produção ser francesa. =  uma estrela (*);
-- 4. A quantidade do elenco precisa ser igual ou maior que 3. =  uma estrela (*);
-- 5. O número dos diretores precisa ser igual a 1 ou 2. =  uma estrela (*);

CREATE TABLE classificacao AS 	
SELECT title, "type", classificacao
FROM (
		SELECT *,
		CASE 
			WHEN title = title THEN CONCAT(criterio1,criterio2,criterio3,criterio4,criterio5)
				ELSE Null
		END AS classificacao
		FROM (
				SELECT *,
				CASE 
					WHEN minutes > 120  THEN '*'
						ELSE Null
					END AS criterio1,
				CASE 
					WHEN country LIKE '%United States%' THEN '*'
						ELSE Null
					END AS criterio2,
				CASE 
					WHEN country LIKE '%France%' THEN '*'
						ELSE Null
				END AS criterio3,
				CASE 
					WHEN total_cast >=3 THEN '*'
						ELSE Null
				END AS criterio4,
				CASE 
					WHEN total_director = 1 or total_director = 2 THEN '*'
						ELSE Null
				END AS criterio5
				FROM (
						SELECT
 								t.show_id2,title, country , (minutes)::int
 						FROM tabelao1 t
 						LEFT JOIN time_table tt ON t.show_id2 = tt.show_id2 
					) z
				LEFT JOIN
					(
						SELECT 
							t.show_id2, COUNT(split_cast) total_cast
						FROM tabelao1 t
						LEFT JOIN cast_table c ON t.show_id2 = c.show_id2 
						GROUP BY t.show_id2, title
					) y ON z.show_id2 = y.show_id2 
				LEFT JOIN
					(
						SELECT
	 						t.show_id2, 
							"type",
	 						COUNT(split_director) total_director
	 					FROM tabelao1 t
    					LEFT JOIN director_table d on t.show_id2 = d.show_id2
	 					GROUP BY t.show_id2, title, "type"
					) x ON y.show_id2 = x.show_id2)d)b
				ORDER BY classificacao DESC;

SELECT * FROM classificacao;

-- Criação de uma coluna que possui o rank dos melhores filmes pelos critérios de classificação.

SELECT  
	title,
	"type",
	classificacao, 
	DENSE_RANK() OVER(ORDER BY classificacao DESC) AS ranking_filme
FROM classificacao
WHERE "type" LIKE '%Movie%';

-- Criação de uma coluna que possui o rank das melhores séries pelos critérios de classificação.

SELECT  
	title, 
	"type", 
	classificacao, 
	DENSE_RANK() OVER(ORDER BY classificacao DESC) AS ranking_serie
FROM   classificacao
WHERE "type" LIKE '%TV Show%';


-- Criação de 3 funções ao qual recebem um valor inteiro como string que correspode ao dia
-- e mês em que o usuário nasceu (DDMM) e retorna uma sugestão de filme aos quais o dia 
-- e mês de publicação na plataforma dão match, onde a classificação de conteudo precisa ser 
-- maior ou igual a 3 estrelas e caso o cliente não goste da sugestão, ele pode ter como
-- retorno a sugestão anterior a essa, gerando uma segunda sugestão. 


-- Primeira sugestão:

CREATE OR REPLACE FUNCTION sugestao_1(val text) RETURNS text AS $$
BEGIN
RETURN
(
	with classificacao_1 AS
	(
		SELECT  DISTINCT(titulo) 
		FROM(
			SELECT title,
			CASE 
				WHEN  val = TO_CHAR(CAST(date_added AS DATE), 'ddmm') THEN title 
			END AS titulo
			FROM tabelao1)x 
		LEFT JOIN classificacao z ON x.title = x.title
		WHERE titulo IS NOT Null AND classificacao >= '***'
	)
	
	SELECT  titulo 
	FROM(
		SELECT  
			titulo,
			ROW_NUMBER() OVER (ORDER BY titulo ASC) AS linha 
		FROM classificacao_1)x
	WHERE linha = 1
		
);
END; $$
LANGUAGE PLPGSQL;

-- teste:
SELECT sugestao_1('0903');


-- Segunda sugestão:

CREATE OR REPLACE FUNCTION sugestao_2(val text) RETURNS text AS $$
BEGIN
RETURN
(
	with classificacao_1 AS 
	(
		SELECT  DISTINCT(titulo) 
		FROM(
		   	SELECT
				title,
			    CASE 
					WHEN  val = TO_CHAR(CAST(date_added AS DATE), 'ddmm') THEN title 
				END AS titulo
				FROM tabelao1)x 
				LEFT JOIN classificacao z ON x.title = x.title
				WHERE titulo IS NOT Null AND classificacao >= '***')
	
	SELECT  titulo 
	FROM(
		SELECT 
			titulo,
			ROW_NUMBER() OVER (ORDER BY titulo ASC) AS linha FROM classificacao_1)x
	WHERE linha = 2	
);
END; $$
LANGUAGE PLPGSQL;

-- teste:
SELECT sugestao_2('0903');


-- Junção das duas sugestões:

CREATE OR REPLACE FUNCTION sugestao(val text) RETURNS text AS $$
BEGIN
RETURN
(
	SELECT
		CONCAT(
				'sugestao_1: ',
				'( ',
				sugestao_1(val),
				' )',
				' ', 
				'sugestao_2: ',
				' (',
				sugestao_2(val),
				')'
			  )
);
END; $$
LANGUAGE PLPGSQL;

-- teste:
SELECT sugestao('0903');