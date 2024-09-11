  with detalle as (
    select v.cod_cliente, v.nombre, v.fch_pedido, v.pedido, v.pedido_item, v.nuot_serie
         , v.nuot_tipoot_codigo, v.numero, v.fecha, v.formu_art_cod_art, v.estado, v.art_cod_art
         , v.cant_formula, v.rendimiento, v.saldo, v.despachar, v.cod_lin, v.abre02, v.preuni
         , v.valor, v.stock, v.tiene_stock, v.tiene_stock_ot, v.tiene_stock_item, v.tiene_importado
         , v.impreso, v.fch_impresion, v.es_juego, v.es_importado, v.es_prioritario, v.es_sao
         , v.cant_prog, v.es_reservado, v.es_simulacion, v.es_nuevo
         , case
             when lag(v.numero) over (order by null) = v.numero
               then null
             else v.numero
           end as oa
         , dense_rank() over (
      order by
        v.es_reservado desc
        , case when p.prioritario = 1 then v.es_prioritario end desc
        , case when p.prioritario = 1 then v.orden_prioritario end
--         , case when trunc(sysdate) - v.fch_pedido > :p_dias then 1 else 0 end desc
        , case :p_orden
            when 1 then
              case when v.valor > p.valor_item then 1 else 0 end
          end desc
        , case :p_orden
            when 1 then
              v.es_juego
          end
        , case :p_orden
            when 1 then
              v.valor
            when 2 then
              v.total_art
          end desc
        , case :p_orden
            when 1 then
              v.es_juego
          end
        , case :p_orden
            when 2 then
              v.fch_pedido
          end
        , v.pedido
        , v.pedido_item
      ) as ranking
      from vw_ordenes_pedido_pendiente v
           join param_surte p on p.id_param = 1
     where ((v.es_prioritario = 1 and :p_dias < 120)
       or ((v.pais = :p_pais or :p_pais is null)
         and (v.vendedor = :p_vendedor or :p_vendedor is null)
         and (v.empaque = :p_empaque or :p_empaque is null)
         and (trunc(sysdate) - v.fch_pedido > :p_dias or :p_dias is null)
         and (v.es_juego = :p_es_juego or :p_es_juego is null)
         and (v.es_nuevo = :p_es_nuevo or :p_es_nuevo is null or v.es_prioritario = 1)
         and (exists(
           select * from tmp_selecciona_cliente t where v.cod_cliente = t.cod_cliente
           ) or
              not exists(
                select *
                  from tmp_selecciona_cliente
                ))
         and (exists(
           select * from tmp_selecciona_articulo t where v.formu_art_cod_art = t.cod_art
           ) or
              not exists(
                select *
                  from tmp_selecciona_articulo
                ))
              )
       )
       and v.impreso = 'NO'
--            and pedido = 14660
--            and pedido_item = 135
    )
select *
  from detalle d
 order by ranking, oa;

  select *
    from expedidos
   where estado != '9'
     and fecha > add_months(trunc(sysdate), -(12 * 3));

-- clientes nuevos
  select case
           when v.nombre_corp is not null then v.nombre_corp
           else e.cod_cliente
         end as cliente
       , case
           when v.nombre_corp is not null then v.nombre_corp
           when c.abreviada is not null then c.abreviada
           else c.nombre
         end as nombre
       , count(*) as compras
    from expedidos e
         left join exclientes_varios v on e.cod_cliente = v.cod_cliente
         left join exclientes c on e.cod_cliente = c.cod_cliente
   where e.estado != '9'
     and e.fecha > add_months(sysdate, -(12 * 3))
  having count(*) <= 2
   group by case
              when v.nombre_corp is not null then v.nombre_corp
              else e.cod_cliente
            end
          , case
              when v.nombre_corp is not null then v.nombre_corp
              when c.abreviada is not null then c.abreviada
              else c.nombre
            end
   order by nombre;

  select *
    from expedidos
   where cod_cliente = '998121';


  select * from exclientes
  where cod_cliente = '998121';

  select * from exclientes_varios;
-- 998048

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
       , cliente_nuevo as (
      select case
               when v.nombre_corp is not null then v.nombre_corp
               else e.cod_cliente
             end as cod_corporativo
           , case
               when v.nombre_corp is not null then v.nombre_corp
               when c.abreviada is not null then c.abreviada
               else c.nombre
             end as nombre
           , count(*) as compras
        from expedidos e
             left join exclientes_varios v on e.cod_cliente = v.cod_cliente
             left join exclientes c on e.cod_cliente = c.cod_cliente
       where e.estado != '9'
         and e.fecha > add_months(sysdate, -(12 * 3))
      having count(*) <= 2
       group by case
                  when v.nombre_corp is not null then v.nombre_corp
                  else e.cod_cliente
                end
              , case
                  when v.nombre_corp is not null then v.nombre_corp
                  when c.abreviada is not null then c.abreviada
                  else c.nombre
                end
       order by nombre
      )
       , ordenes as (
      select h.abre01 as pedido, h.per_env as pedido_item, h.numero, h.nuot_serie
           , h.nuot_tipoot_codigo, h.fecha
           , h.hora_fab as jaba, h.estado, h.destino, d.art_cod_art, d.cant_formula, d.saldo
           , d.rendimiento
           , d.cant_formula - nvl(d.saldo, 0) as despachar, d.cod_lin, h.formu_art_cod_art, h.abre02
           , h.cant_prog
           , case g.grupo when 1 then 1 else 0 end as es_juego
           , case when i.numero is not null then 'SI' else 'NO' end as impreso, i.fch_impresion
           , case
               when d.cod_lin between '900' and '999' and length(d.cod_lin) = 3 then 1
               else 0
             end as es_importado
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
      select p.numero as pedido, d.nro as pedido_item, p.cod_cliente
           , coalesce(c.abreviada, p.nombre) as nombre, p.fecha as fch_pedido, o.numero
           , o.nuot_serie, o.nuot_tipoot_codigo, o.fecha, o.jaba, o.estado, o.rendimiento, o.destino
           , o.art_cod_art, o.cant_formula, o.saldo, o.despachar, o.cod_lin, o.formu_art_cod_art
           , o.abre02, o.es_juego, o.impreso, o.fch_impresion, o.es_importado, d.preuni
           , a.codigo_aux as pais, p.zona as vendedor, p.empaque, o.es_sao, o.cant_prog
           , round(d.canti * d.preuni, 2) as valor
           , case
               when v.nombre_corp is not null then v.nombre_corp
               else p.cod_cliente
             end as cod_corporativo
        from expedidos p
             join expedido_d d
                  on p.numero = d.numero
             join ordenes o on o.pedido = p.numero and o.pedido_item = d.nro and o.destino = '1'
             join prioridad_marcada m on p.numero = m.id_pedido
             left join expaises a on p.pais = a.pais
             left join exclientes c on p.cod_cliente = c.cod_cliente
             left join exclientes_varios v on p.cod_cliente = v.cod_cliente
       union all
-- nacional
      select p.numero as pedido, d.nro as pedido_item, p.cod_cliente, p.nombre
           , p.fecha as fch_pedido, o.numero, o.nuot_serie, o.nuot_tipoot_codigo, o.fecha, o.jaba
           , o.estado, o.rendimiento, o.destino, o.art_cod_art, o.cant_formula, o.saldo, o.despachar
           , o.cod_lin, o.formu_art_cod_art, o.abre02, o.es_juego, o.impreso, o.fch_impresion
           , o.es_importado, d.preuni, p.pais, 'PE' as vendedor, p.empaque, o.es_sao, o.cant_prog
           , round(d.canti * d.preuni, 2) as valor, p.cod_cliente as cod_corporativo
        from expednac p
             join expednac_d d
                  on p.numero = d.numero
             join ordenes o on o.pedido = p.numero and o.pedido_item = d.nro and o.destino = '2'
             join prioridad_marcada m on p.numero = m.id_pedido
      )
       , detalle as (
      select nvl(gcc.cod_grupo, p.cod_cliente) as cod_cliente
           , nvl(gc.dsc_grupo, p.nombre) as nombre
           , p.fch_pedido, p.pedido, p.pedido_item, p.numero, p.nuot_serie, p.nuot_tipoot_codigo
           , p.fecha
           , p.jaba, p.estado, p.art_cod_art, p.cant_formula, p.saldo, p.pais, p.vendedor, p.empaque
           , p.cant_formula - nvl(p.saldo, 0) as despachar, p.cod_lin, p.rendimiento
           , p.formu_art_cod_art, p.abre02, nvl(s.stock, 0) as stock, p.preuni, p.valor, p.es_sao
           , p.cant_prog
           , case when p.cant_formula - nvl(p.saldo, 0) >= s.stock then 0 else 1 end as tiene_stock
           , p.impreso, p.fch_impresion, p.es_juego, p.es_importado
           , nvl(gc.es_prioritario, 0) as es_prioritario
           , nvl(gc.orden, 0) as orden_prioritario
           , nvl(gc.es_simulacion, 0) as es_simulacion
           , case when n.cod_corporativo is not null then 1 else 0 end as es_nuevo
        from pedidos p
             left join stock_actual s on p.art_cod_art = s.cod_art
             left join grupo_cliente_cliente gcc on p.cod_cliente = gcc.cod_cliente
             left join grupo_cliente gc on gc.cod_grupo = gcc.cod_grupo
             left join cliente_nuevo n on p.cod_corporativo = n.cod_corporativo
      )
  select d.cod_cliente, d.nombre, d.fch_pedido, d.pedido, d.pedido_item, d.numero, d.nuot_serie
       , d.nuot_tipoot_codigo, d.fecha, d.jaba, d.estado, d.art_cod_art, d.cant_formula
       , d.rendimiento, d.saldo
       , d.despachar, d.cod_lin, d.formu_art_cod_art, d.abre02, d.preuni, d.pais, d.vendedor
       , d.empaque
       , d.valor, d.stock, d.tiene_stock, d.es_sao, d.cant_prog
       , case max(d.es_importado) over (partition by d.numero, d.nuot_serie, d.nuot_tipoot_codigo)
           when 0 then 0
           else 1
         end as tiene_importado
       , case min(d.tiene_stock) over (partition by d.numero, d.nuot_serie, d.nuot_tipoot_codigo)
           when 0 then 'NO'
           else 'SI'
         end as tiene_stock_ot
       , d.tiene_stock as tiene_stock_item, d.impreso, d.fch_impresion, d.es_juego, d.es_importado
       , d.es_prioritario, d.orden_prioritario, d.es_simulacion
       , case when r.pedido_nro is not null then 1 else 0 end as es_reservado, d.es_nuevo
       , sum(distinct d.valor) over (partition by d.cod_cliente, d.formu_art_cod_art) as total_art
    from detalle d
         left join reserva_surtimiento r on d.pedido = r.pedido_nro and d.pedido_item = r.pedido_itm
   order by nuot_serie, nuot_tipoot_codigo, numero
