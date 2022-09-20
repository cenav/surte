create or replace view vw_formula_saos as
select f.cod_art, f.cod_for, f.tipo, f.canti, f.neto, f.linea, a.tp_art
     , case when lag(f.cod_art) over (order by null) = f.cod_art then null else f.cod_art end quiebre
  from pcformulas f
       join articul m on f.cod_art = m.cod_art
       join articul a on f.cod_for = a.cod_art
 where m.tp_art = 'A'
   and a.tp_art = 'P';

create public synonym vw_formula_saos for pevisa.vw_formula_saos;