create or replace view vw_rango_dias_impreso as
  with colores as (
    select 1 as id, 'GREEN' as color
      from dual
     union
    select 2, 'YELLOW'
      from dual
     union
    select 3, 'RED'
      from dual
    )
     , columa as (
    select dias_impreso_bien, dias_impreso_mal, 999999 as dias_impreso_grave
      from param_surte
    )
     , fila as (
    -- convierte columnas en filas
    select col, val
      from columa
        unpivot (val for col in (dias_impreso_bien, dias_impreso_mal, dias_impreso_grave))
    )
     , rango as (
    select f.col, lag(f.val + 1, 1, 0) over (order by f.val) as desde, f.val as hasta
      from fila f
    )
     , detalle as (
    select rownum as id, r.col, r.desde, r.hasta
         , 'de ' || r.desde || ' a ' || replace(r.hasta, 999999, '+') || ' dias' as descripcion
      from rango r
    )
select d.id, d.col, d.desde, d.hasta, d.descripcion, c.color
  from detalle d
       join colores c on d.id = c.id;

create public synonym vw_rango_dias_impreso for pevisa.vw_rango_dias_impreso;