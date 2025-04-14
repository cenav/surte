-- prioridad sin marcar se muestra en el módulo de planeamiento y
-- permite imprimir órdenes.

-- activar prioridad se trabaja al mes correcto
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
   );

select *
  from pr_programa_embarques_id
 where ano = 2025
   and mes in (2, 3);

-- original
/*
select *
  from pr_embarques
 where id_vendedor = :VIEW_PRIORIDADES_PENDIENTES.id_vendedor
   and ano_embarque = :BLOCK_FECHA.x_ano
   and mes_embarque = :BLOCK_FECHA.x_mes
   and id_pedido in (
   select distinct id_pedido
     from view_pedidos_pendientes_38
    where id_vendedor = :VIEW_PRIORIDADES_PENDIENTES.id_vendedor
      and prioridad = :VIEW_PRIORIDADES_PENDIENTES.prioridad
   );
*/


select *
  from pr_embarques
 where ano_embarque = :x_ano
   and mes_embarque = :x_mes
   and id_pedido in (
   select distinct id_pedido
     from view_pedidos_pendientes_38
    where id_vendedor = :id_vendedor
      and prioridad = :prioridad
   );

select *
  from pr_embarques
 where ano_embarque = 2025
   and mes_embarque = 2
   and id_pedido = 16341;

select *
  from view_pedidos_pendientes_38
 where id_pedido = 16341;
