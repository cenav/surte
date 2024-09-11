-- pedido no se muestra en planeamiento
-- orden 1, los demas parámetros nulos
  with detalle as (
    select v.cod_cliente, v.nombre, v.fch_pedido, v.pedido, v.pedido_item, v.nuot_serie
         , v.nuot_tipoot_codigo, v.numero, v.fecha, v.formu_art_cod_art, v.estado, v.art_cod_art
         , v.cant_formula, v.rendimiento, v.saldo, v.despachar, v.cod_lin, v.abre02, v.preuni
         , v.valor
         , v.stock, v.tiene_stock, v.tiene_stock_ot, v.tiene_stock_item, v.tiene_importado
         , v.impreso
         , v.fch_impresion, v.es_juego, v.es_importado, v.es_prioritario, v.es_sao, v.cant_prog
         , v.es_reservado, v.es_simulacion
         , case when lag(v.numero) over (order by null) = v.numero then null else v.numero end as oa
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
       and pedido = 16417
--            and pedido_item = 135
    )
select *
  from detalle d
 order by ranking, oa;

select id_pedido
  from view_pedidos_pendientes_38
 where exists (
   select 1
     from pr_embarques p
          join pr_programa_embarques_id i
               on p.ano_embarque = i.ano
                 and p.mes_embarque = i.mes
                 and i.estado = 1
    where p.id_pedido =
          view_pedidos_pendientes_38.id_pedido
   )
   and id_pedido = 16500;

select *
  from pr_embarques
 where id_pedido = 16417;

select *
  from pr_programa_embarques_id
 where ano = 2024
   and mes = 8;

select *
  from view_pedidos_pendientes_38
 where id_pedido = 16500;

select * from grupo_cliente;

select * from grupo_cliente_cliente;

select *
  from expedidos
 where numero in (16417, 16446);