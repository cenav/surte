select *
  from pr_ot
 where nuot_tipoot_codigo = 'AR'
   and numero = 984536;

select * from vw_ordenes_impresas_pendientes;

select * from orden_emitida_surte_m;

select * from orden_emitida_surte_l;

select *
  from orden_emitida_surte_m e
       join pr_ot o
            on e.ot_tpo = o.nuot_tipoot_codigo
              and e.ot_ser = o.nuot_serie
              and e.ot_nro = o.numero
 where o.estado = '1';


create or replace view vw_saos_emitidos as
  with impresion as (
    select nuot_tipoot_codigo, nuot_serie, numero, max(fecha) as fch_impresion
      from pr_ot_impresion
     where nuot_tipoot_codigo = 'AR'
     group by nuot_tipoot_codigo, nuot_serie, numero
    )
     , detalle as (
    select o.nuot_tipoot_codigo, o.nuot_serie, o.numero, o.fecha, o.estado, formu_art_cod_art
         , cant_prog, a.tp_art, fch_impresion, round(sysdate - i.fch_impresion) as dias_impreso
      from pr_ot o
           join articul a on o.formu_art_cod_art = a.cod_art
           left join impresion i
                     on o.numero = i.numero
                       and o.nuot_serie = i.nuot_serie
                       and o.nuot_tipoot_codigo = i.nuot_tipoot_codigo
     where o.nuot_tipoot_codigo = 'AR'
       and o.nuot_serie = 3
       and o.estado = '1'
       and a.tp_art = 'A'
    )
select nuot_tipoot_codigo, nuot_serie, numero, fecha, estado, formu_art_cod_art, cant_prog, tp_art
     , fch_impresion, dias_impreso
     , case
         when d.dias_impreso <= p.dias_impreso_bien then 'GREEN'
         when d.dias_impreso <= p.dias_impreso_mal then 'YELLOW'
         when d.dias_impreso is null then 'GRAY'
         else 'RED'
       end as color
  from detalle d
       join param_surte p on p.id_param = 1
 order by dias_impreso desc nulls last;

select nuot_tipoot_codigo, nuot_serie, numero, fecha, estado, formu_art_cod_art, cant_prog, tp_art
     , fch_impresion, dias_impreso, color
  from vw_saos_emitidos;