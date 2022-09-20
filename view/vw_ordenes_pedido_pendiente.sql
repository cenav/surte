create or replace view vw_ordenes_pedido_pendiente as
  with stock_actual as (
    select cod_art, stock
      from vw_stock_almacen
    )
     , impresion as (
    select nuot_tipoot_codigo, nuot_serie, numero, max(fecha) as fch_impresion
      from pr_ot_impresion
     where nuot_tipoot_codigo = 'AR'
     group by nuot_tipoot_codigo, nuot_serie, numero
    )
     , prioridad_marcada as (
    select id_pedido
      from view_pedidos_pendientes_38
     where exists(
               select 1
                 from pr_embarques p
                      join pr_programa_embarques_id i
                           on p.ano_embarque = i.ano and p.mes_embarque = i.mes and i.estado = 1
                where p.id_pedido = view_pedidos_pendientes_38.id_pedido
             )
    )
     , ordenes as (
    select h.abre01 as pedido, h.per_env as pedido_item, h.numero, h.nuot_serie, h.nuot_tipoot_codigo, h.fecha
         , h.hora_fab as jaba, h.estado, h.destino, d.art_cod_art, d.cant_formula, d.saldo, d.rendimiento
         , d.cant_formula - nvl(d.saldo, 0) as despachar, d.cod_lin, h.formu_art_cod_art, h.abre02
         , case g.grupo when 1 then 1 else 0 end as es_juego
         , case when i.numero is not null then 'SI' else 'NO' end as impreso, i.fch_impresion
         , case
             when d.cod_lin between '900' and '999' and length(d.cod_lin) = 3 then 1
             else 0
           end es_importado
         , case a.tp_art when 'A' then 1 else 0 end as es_sao
      from pr_ot h
           join pr_ot_det d
                on h.numero = d.ot_numero
                  and h.nuot_serie = d.ot_nuot_serie
                  and h.nuot_tipoot_codigo = d.ot_nuot_tipoot_codigo
           left join tab_lineas l on h.cod_lin = l.linea
           left join tab_grupos g on l.grupo = g.grupo
           left join articul a on d.art_cod_art = a.cod_art
           left join impresion i
                     on h.numero = i.numero
                       and h.nuot_serie = i.nuot_serie
                       and h.nuot_tipoot_codigo = i.nuot_tipoot_codigo
     where h.nuot_tipoot_codigo = 'AR'
       and d.cant_formula - nvl(d.saldo, 0) > 0
       and h.estado < 5
       and d.cod_lin not between '800' and '899'
    )
     , pedidos as (
    -- exportacion
    select p.numero as pedido, d.nro as pedido_item, p.cod_cliente, p.nombre, p.fecha as fch_pedido
         , o.numero, o.nuot_serie, o.nuot_tipoot_codigo, o.fecha, o.jaba, o.estado, o.rendimiento
         , o.destino, o.art_cod_art, o.cant_formula, o.saldo, o.despachar, o.cod_lin, o.formu_art_cod_art
         , o.abre02, o.es_juego, o.impreso, o.fch_impresion, o.es_importado, d.preuni, a.codigo_aux as pais
         , p.zona as vendedor, p.empaque, o.es_sao
         , round(d.canti * d.preuni, 2) as valor
      from expedidos p
           join expedido_d d
                on p.numero = d.numero
           join ordenes o on o.pedido = p.numero and o.pedido_item = d.nro and o.destino = '1'
           join prioridad_marcada m on p.numero = m.id_pedido
           left join expaises a on p.pais = a.pais
     union all
-- nacional
    select p.numero as pedido, d.nro as pedido_item, p.cod_cliente, p.nombre, p.fecha as fch_pedido
         , o.numero, o.nuot_serie, o.nuot_tipoot_codigo, o.fecha, o.jaba, o.estado, o.rendimiento
         , o.destino, o.art_cod_art, o.cant_formula, o.saldo, o.despachar, o.cod_lin, o.formu_art_cod_art
         , o.abre02, o.es_juego, o.impreso, o.fch_impresion, o.es_importado, d.preuni, p.pais
         , 'PE' as vendedor, p.empaque, o.es_sao
         , round(d.canti * d.preuni, 2) as valor
      from expednac p
           join expednac_d d
                on p.numero = d.numero
           join ordenes o on o.pedido = p.numero and o.pedido_item = d.nro and o.destino = '2'
           join prioridad_marcada m on p.numero = m.id_pedido
    )
     , detalle as (
    select nvl(gcc.cod_grupo, p.cod_cliente) as cod_cliente
         , nvl(gc.dsc_grupo, p.nombre) as nombre
         , p.fch_pedido, p.pedido, p.pedido_item, p.numero, p.nuot_serie, p.nuot_tipoot_codigo, p.fecha
         , p.jaba, p.estado, p.art_cod_art, p.cant_formula, p.saldo, p.pais, p.vendedor, p.empaque
         , p.cant_formula - nvl(p.saldo, 0) as despachar, p.cod_lin, p.rendimiento
         , p.formu_art_cod_art, p.abre02, nvl(s.stock, 0) as stock, p.preuni, p.valor, p.es_sao
         , case when p.cant_formula - nvl(p.saldo, 0) >= s.stock then 0 else 1 end as tiene_stock
         , p.impreso, p.fch_impresion, p.es_juego, p.es_importado, nvl(gc.es_prioritario, 0) as es_prioritario
      from pedidos p
           left join stock_actual s on p.art_cod_art = s.cod_art
           left join grupo_cliente_cliente gcc on p.cod_cliente = gcc.cod_cliente
           left join grupo_cliente gc on gc.cod_grupo = gcc.cod_grupo
    )
select d.cod_cliente, d.nombre, d.fch_pedido, d.pedido, d.pedido_item, d.numero, d.nuot_serie
     , d.nuot_tipoot_codigo, d.fecha, d.jaba, d.estado, d.art_cod_art, d.cant_formula, d.rendimiento, d.saldo
     , d.despachar, d.cod_lin, d.formu_art_cod_art, d.abre02, d.preuni, d.pais, d.vendedor, d.empaque
     , d.valor, d.stock, d.tiene_stock, d.es_sao
     , case max(d.es_importado) over (partition by d.numero, d.nuot_serie, d.nuot_tipoot_codigo)
         when 0 then 0
         else 1
       end as tiene_importado
     , case min(d.tiene_stock) over (partition by d.numero, d.nuot_serie, d.nuot_tipoot_codigo)
         when 0 then 'NO'
         else 'SI'
       end as tiene_stock_ot
     , case d.tiene_stock when 0 then 'NO' else 'SI' end as tiene_stock_item
     , d.impreso, d.fch_impresion, d.es_juego, d.es_importado, d.es_prioritario
  from detalle d
 order by nuot_serie, nuot_tipoot_codigo, numero;
