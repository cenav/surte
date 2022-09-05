create or replace view vw_ordenes_impresas_pendientes as
  with detail as (
    select cod_cliente, nombre, fch_pedido, pedido, pedido_item, nuot_tipoot_codigo, nuot_serie, numero, fecha
         , cant_prog, estado, pais, vendedor, empaque, formu_art_cod_art, valor, dias_impreso, fch_impresion
         , es_juego, es_prioritario
      from vw_ordenes_impresas_piezas
     group by cod_cliente, nombre, fch_pedido, pedido, pedido_item, nuot_tipoot_codigo, nuot_serie, numero
            , fecha, cant_prog, estado, pais, vendedor, empaque, formu_art_cod_art, valor, dias_impreso
            , fch_impresion, es_juego, es_prioritario
     order by dias_impreso desc, valor desc
    )
select d.cod_cliente, d.nombre, d.fch_pedido, d.pedido, d.pedido_item, d.nuot_tipoot_codigo, d.nuot_serie
     , d.numero, d.fecha, d.cant_prog, d.estado, d.pais, d.vendedor, d.empaque, d.formu_art_cod_art, d.valor
     , d.dias_impreso, d.fch_impresion, d.es_juego, d.es_prioritario
     , case
         when d.dias_impreso <= p.dias_impreso_bien then 'GREEN'
         when d.dias_impreso <= dias_impreso_mal then 'YELLOW'
         else 'RED'
       end as color
  from detail d
       join param_surte p on p.id_param = 1;

create public synonym vw_ordenes_impresas_pendientes for pevisa.vw_ordenes_impresas_pendientes;