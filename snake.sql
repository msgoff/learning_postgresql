--time for ((i=0;i<1000;i++));do psql -f /tmp/s2.sql ;done|grep "{"|sort|uniq|sed -re 's/\{|\}|\(|\)//g'

drop FUNCTION if EXISTS transition_table;
DROP TABLE if EXISTS transition_table;
drop function if EXISTS get_moves;
drop table if EXISTS seen;
drop function if exists get_src;
drop function if exists get_last_src;
drop function if exists random_move;
drop function if exists update_transition_table;


create function transition_table(int,int)
returns int[]
language sql immutable
as
$$
SELECT ARRAY(
SELECT * from UNNEST(
(SELECT array[
(SELECT $1-$2 where $1 - $2 > 0),
(SELECT $1-1 where ($1 - 1) % $2 <> 0 ),
(SELECT $1+1 where $1 % $2 <> 0),
(SELECT $1+$2 where $1 + $2 < $2*$2)
])) as X
where X is not NULL
);
$$;


create table transition_table as
select ix,transition_table(ix,3) AS arr
from generate_series(1,9) as ix;


create table seen(id serial,src int);


create function get_moves(int)
returns int[]
LANGUAGE SQL
as $$
  select array((
  select * from UNNEST((
  select arr from transition_table
  where ix = $1)) as X
  where X not in (select src from seen)))

$$;

create function get_src()
  returns INT
  LANGUAGE SQL
  as $$

    select ix from transition_table
    where ix not in (select src from seen )
    order by random()

    limit 1

  $$;


insert into seen (src) values  ((select get_src()));

create function get_last_src()
  returns int language sql
  as $$
select src from seen
where id in (select max(id) from seen);
$$;


create function random_move()
returns INT
LANGUAGE SQL
as
$$
select * from UNNEST((
SELECT get_moves((
select get_last_src()
))))
order by random()
limit 1;
$$;


create function update_transition_table()
  returns void
  LANGUAGE SQL
  as
  $$
  delete from transition_table
    where ix in (select src from seen)
  $$;


insert into seen (src) values  ((select random_move()));
insert into seen (src) values  ((select random_move()));
insert into seen (src) values  ((select random_move()));
insert into seen (src) values  ((select random_move()));
insert into seen (src) values  ((select random_move()));
insert into seen (src) values  ((select random_move()));
insert into seen (src) values  ((select random_move()));
insert into seen (src) values  ((select random_move()));


delete from seen
  where src is Null;

select * from seen;

select (
  CASE
  when (select count(*) from seen) = 9
  Then (select array_agg(s) from (select src from seen) as s)
  ELSE (select array_agg(s) from (select * from generate_series(0,0)) as s)
  End
) as f
from seen
limit 1
;
