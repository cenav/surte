create or replace view vw_ordenes_impresas_piezas as
  with impresion as (
    select nuot_tipoot_codigo, nuot_serie, numero, max(fecha) as fch_impresion
      from pr_ot_impresion
     where nuot_tipoot_codigo = 'AR'
     group by nuot_tipoot_codigo, nuot_serie, numero
    )
     , ordenes as (
    select h.abre01 as pedido, h.per_env as pedido_item, h.nuot_tipoot_codigo, h.nuot_serie, h.numero, h.fecha
         , h.estado, h.destino, h.formu_art_cod_art, h.cant_prog
         , case g.grupo when 1 then 1 else 0 end as es_juego, i.fch_impresion
         , round(sysdate - i.fch_impresion) as dias_impreso
         , d.art_cod_art, d.cant_formula
      from pr_ot h
           join pr_ot_det d
                on h.numero = d.ot_numero
                  and h.nuot_serie = d.ot_nuot_serie
                  and h.nuot_tipoot_codigo = d.ot_nuot_tipoot_codigo
           left join tab_lineas l on h.cod_lin = l.linea
           left join tab_grupos g on l.grupo = g.grupo
           join impresion i
                on h.numero = i.numero
                  and h.nuot_serie = i.nuot_serie
                  and h.nuot_tipoot_codigo = i.nuot_tipoot_codigo
     where h.nuot_tipoot_codigo = 'AR'
       and h.estado = 1
       and d.cod_lin not between '800' and '899'
    )
     , pedidos as (
    -- exportacion
    select p.numero as pedido, d.nro as pedido_item, p.cod_cliente, p.nombre, p.fecha as fch_pedido
         , o.numero, o.nuot_serie, o.nuot_tipoot_codigo, o.fecha, o.estado, o.destino, o.cant_prog
         , o.dias_impreso, o.formu_art_cod_art, o.es_juego, o.fch_impresion, d.preuni, a.codigo_aux as pais
         , p.zona as vendedor, p.empaque
         , round(d.canti * d.preuni, 2) as valor
         , o.art_cod_art, o.cant_formula
      from expedidos p
           join expedido_d d
                on p.numero = d.numero
           join ordenes o on o.pedido = p.numero and o.pedido_item = d.nro and o.destino = '1'
           left join expaises a on p.pais = a.pais
     union all
-- nacional
    select p.numero as pedido, d.nro as pedido_item, p.cod_cliente, p.nombre, p.fecha as fch_pedido
         , o.numero, o.nuot_serie, o.nuot_tipoot_codigo, o.fecha, o.estado, o.destino, o.cant_prog
         , o.dias_impreso, o.formu_art_cod_art, o.es_juego, o.fch_impresion, d.preuni, p.pais
         , 'PE' as vendedor, p.empaque
         , round(d.canti * d.preuni, 2) as valor
         , o.art_cod_art, o.cant_formula
      from expednac p
           join expednac_d d
                on p.numero = d.numero
           join ordenes o on o.pedido = p.numero and o.pedido_item = d.nro and o.destino = '2'
    )
select nvl(gcc.cod_grupo, p.cod_cliente) as cod_cliente
     , nvl(gc.dsc_grupo, p.nombre) as nombre
     , p.fch_pedido, p.pedido, p.pedido_item, p.nuot_tipoot_codigo, p.nuot_serie, p.numero, p.fecha
     , p.cant_prog, p.estado, p.pais, p.vendedor, p.empaque, p.formu_art_cod_art, p.valor, p.dias_impreso
     , p.fch_impresion, p.es_juego, nvl(gc.es_prioritario, 0) as es_prioritario
     , p.art_cod_art, p.cant_formula
  from pedidos p
       left join grupo_cliente_cliente gcc on p.cod_cliente = gcc.cod_cliente
       left join grupo_cliente gc on gc.cod_grupo = gcc.cod_grupo;

create public synonym vw_ordenes_impresas_piezas for pevisa.vw_ordenes_impresas_piezas;