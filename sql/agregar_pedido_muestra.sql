  with pedidos as (
    select id_pedido
      from view_pedidos_pendientes_38
     where exists (
       select 1
         from pr_embarques p
              join pr_programa_embarques_id i
             --condicion para que tome tambien desmarcados
             --ON     p.ano_embarque = i.ano
             --  AND p.mes_embarque = i.mes
                   on i.estado = 1
        where p.id_pedido =
              view_pedidos_pendientes_38.id_pedido
       )
       --PRIORIDAD EVITAR LOS 7...
       and prioridad not like '7%'
     union
    select id_pedido
      from view_pedidos_pendientes_38
     where cod_cliente in (
       select gcc.cod_cliente
         from grupo_cliente gc
              join grupo_cliente_cliente gcc
                   on gc.cod_grupo = gcc.cod_grupo
        where gc.es_simulacion = 1
       )
     union
-- Pedido excepcional
    select numero as id_pedido
      from expedidos
     where numero = 17366
    )
select *
  from pedidos
 where id_pedido = 17366;

  -- Pedido excepcional
  select *
    from vw_ordenes_pedido_pendiente
   where pedido = 17366;


  select numero as id_pedido
    from expedidos
   where numero = 17366;