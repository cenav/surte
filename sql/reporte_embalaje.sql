select o.numero, o.formu_art_cod_art, o.estado
  from pr_ot o
 where o.nuot_tipoot_codigo = 'AR'
   and o.numero = 412357;

-- enbalajes una sola línea
  with embalajes as (
    select distinct f.cod_art
                  , listagg(f.cod_for || ' (R ' || f.canti || ')', ' | ')
                            within group (order by f.cod_for)
                            over (partition by f.cod_art) as embalaje
      from pcformulas f
           join articul a on f.cod_for = a.cod_art
     where a.cod_lin between '800' and '899'
       and length(a.cod_lin) = 3
       and a.cod_lin not in ('840', '855', '871', '875', '880', '896')
       and f.cod_art in ('KIT AUT V 80100 R', 'KIT AUT VK 95455 R', 'AUT F 200.026 NA')
    )
select o.numero, e.cod_art, e.embalaje, o.cant_prog
  from pr_ot o
       join embalajes e on o.formu_art_cod_art = e.cod_art
      and o.nuot_tipoot_codigo = 'AR'
--       and o.numero = 412357
      and o.estado = '1'
 order by cod_art;

create or replace view vw_planeamiento_embalaje as
  with stock_almacen as (
    select cod_art, sum(stock) as stock
      from almacen
     where cod_alm = '06'
     group by cod_art
    )
select o.numero, o.estado, o.fecha, f.cod_art, f.cod_for as embalaje, f.canti as rendimiento
     , o.cant_prog * f.canti as requerimiento, s.stock, a.cant_requerida as requerimiento_total
     , a.stock_requerida as stock_seguridad, a.consumo_mensual * 3 as prom_ultimos_meses
  from pr_ot o
       join pcformulas f on o.formu_art_cod_art = f.cod_art
       join vw_articulo a on f.cod_for = a.cod_art
       join stock_almacen s on f.cod_for = s.cod_art
 where o.nuot_tipoot_codigo = 'AR'
   and o.estado = '1'
   and a.cod_lin between '800' and '899'
   and length(a.cod_lin) = 3
   and a.cod_lin not in ('840', '855', '871', '875', '880', '896');

select numero, estado, fecha, cod_art, embalaje, rendimiento, requerimiento, requerimiento_total
     , stock, stock_seguridad, prom_ultimos_meses
  from vw_planeamiento_embalaje
 where numero = 412357;

select * from vw_planeamiento_embalaje;

select *
  from vw_stock_almacen
 where cod_art = 'DUR 230.230';

select *
  from vw_articulo
 where cod_art = 'DUR 230.230';

select *
  from pcformulas
 where cod_art = 'KIT AUT V 80100 R';

select *
  from pr_ot_det
 where ot_nuot_tipoot_codigo = 'AR'
   and ot_numero = 412357;

select *
  from pcformulas
 where cod_for = 'DUR 230.230';

select *
  from vendedores
 order by cod_vendedor;
