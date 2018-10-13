--time for ((i=0;i<1000;i++));do psql -f /tmp/s2.sql ;done|grep "{"|sort|uniq|sed -re 's/\{|\}|\(|\)//g'


DROP FUNCTION IF EXISTS transition_table;
DROP TABLE IF EXISTS transition_table;
DROP FUNCTION IF EXISTS get_moves;
DROP TABLE IF EXISTS seen;
DROP FUNCTION IF EXISTS get_src;
DROP FUNCTION IF EXISTS get_last_src;
DROP FUNCTION IF EXISTS random_move;
DROP FUNCTION IF EXISTS update_transition_table;
DROP FUNCTION IF EXISTS create_random_move;



CREATE FUNCTION transition_table(int,int)
RETURNS INT[]
language sql immutable
as $$
SELECT ARRAY(
  SELECT * from UNNEST(
        (SELECT array[
        (SELECT $1-$2 WHERE $1 - $2 > 0),
        (SELECT $1-1 WHERE ($1 - 1) % $2 <> 0 ),
        (SELECT $1+1 WHERE $1 % $2 <> 0),
        (SELECT $1+$2 WHERE $1 + $2 < $2*$2)
        ])) as X
        WHERE X IS NOT NULL
);
$$;


CREATE TABLE transition_table
  AS
    SELECT ix,transition_table(ix,3) AS ARR
    FROM generate_series(1,9) AS ix;

CREATE TABLE seen(id SERIAL,src INT);



CREATE FUNCTION get_moves(INT)
RETURNS INT[]
LANGUAGE SQL
AS $$
  SELECT array((
  SELECT * FROM UNNEST((
  SELECT arr FROM transition_table
  WHERE ix = $1)) AS X
  WHERE X NOT IN (SELECT src FROM seen)))
$$;



CREATE FUNCTION get_src()
  returns INT
  LANGUAGE SQL
  AS $$
    SELECT ix FROM transition_table
    WHERE ix NOT IN (SELECT src FROM seen )
    ORDER BY random()
    LIMIT 1
$$;


INSERT INTO seen (src) VALUES ((SELECT get_src()));


create function get_last_src()
  returns int language sql
  as $$
select src from seen
where id in (select max(id) from seen);
$$;


create function random_move()
returns INT
LANGUAGE SQL
as $$
select * from UNNEST((
SELECT get_moves((
select get_last_src() ))
)) ORDER BY random()
limit 1;
$$;

create function update_transition_table()
  RETURNS VOID
  LANGUAGE SQL
AS $$
  DELETE FROM transition_table
    where ix in (select src from seen)
$$;

CREATE FUNCTION create_random_move()
  RETURNS VOID
  LANGUAGE SQL
  AS $$
  insert into seen (src) values ((select random_move()));
  $$;


SELECT create_random_move() FROM generate_series(1,8);

DELETE FROM seen
  WHERE src IS NULL;

SELECT * FROM seen;

SELECT (
  CASE
  WHEN (SELECT count(*) FROM seen) = 9
  THEN (select array_agg(s) FROM (SELECT src FROM seen) AS s)
  ELSE (select array_agg(s) FROM (SELECT 0) AS s)
  End
) AS f
FROM seen
LIMIT 1;
