select *
  from pr_embarques
 where ano_embarque = 2026
   and mes_embarque = 8;

select * from pr_programa_embarques_id;

select *
  from pr_ot
 where nuot_tipoot_codigo = 'AR'
   and abre01 = '17147';

select *
  from pr_consul
 where pedido = 17147;

select *
  from expedidos
 where numero in (17364, 17356);

-- solo para prueba
select *
  from expedido_d
 where numero in (17364, 17356);

select * from prioridad_trabajo;

select id_pedido, id_prioridad_trabajo from pedido_prioridad_trabajo;

  with prueba as (
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
     union
-- se trabaja pero no se surte
    select id_pedido
      from pedido_prioridad_trabajo
    )
select *
  from prueba
 where id_pedido = 17356;


select nro_pedido, itm_pedido, cod_cliente, nom_cliente, fch_pedido, ot_tipo, ot_serie, ot_numero
     , ot_estado, cod_jgo, cant_prog, preuni, valor, valor_surtir, valor_simulado, es_juego
     , tiene_importado, impreso, fch_impresion, partir_ot, cant_partir, tiene_stock_ot
     , es_prioritario, es_reserva, es_urgente, es_simulacion, es_armar, cant_faltante, id_color
     , ranking, imprimir
  from tmp_surte_jgo;

select t.nro_pedido
     , t.itm_pedido
     , t.imprimir
  from tmp_surte_jgo t
 where exists (
   select 1
     from pedido_prioridad_trabajo p
    where p.id_pedido = t.nro_pedido
      and p.id_prioridad_trabajo = 3
   );


update tmp_surte_jgo t
   set t.imprimir = 0
 where exists (
   select 1
     from pedido_prioridad_trabajo p
    where p.id_pedido = t.nro_pedido
      and p.id_prioridad_trabajo = 3
   );


select *
  from exproformas
 where numero = 20847;


select *
  from exproformas_expedidos
 where numero_proforma = 20847;


select *
  from pedido_prioridad_trabajo
 where id_pedido = 17401
   and id_prioridad_trabajo = 3;

select *
  from pr_prioridad_clientes
 order by prioridad desc;

select *
  from pr_prioridad_clientes
 where cod_cliente = '992073';


select length('x_si_trabaja_no_surte') from dual;

select owner, name, type, line, text
  from all_source
 where upper(text) like 'PR_PRIORIDAD_CLIENTES'
 order by owner, type, name, line;

select name, type, line, text
  from user_source
 where upper(text) like 'PR_PRIORIDAD_CLIENTES'
 order by type, name, line;

select name, type, referenced_name, referenced_type
  from user_dependencies
 where referenced_name = 'PR_PRIORIDAD_CLIENTES'
 order by type, name;


-- prioridad si trabaja
select min(prioridad)
  from pr_prioridad_clientes
 where prioridad between 6000 and 6999
   and estado = 0
   and cod_cliente is null;

-- prioridad no trabaja
select 7000 + (:p_ultimo_prioridad - 6000)
  from dual;


select 8000 + (:p_ultimo_prioridad - 6000)
  from dual;

select *
  from pr_prioridad_clientes
 where prioridad >= 8000;


select *
  from pr_prioridad_clientes
 where cod_cliente = '992073';

select *
  from pr_prioridad_clientes
 where prioridad = 8148;


--  insert into pevisa.pr_prioridad_clientes
--    (prioridad, cod_cliente, accion, estado)
--  select 8000 + level, null, null, '0'
--    from dual
-- connect by level <= 999;


-- prioridad si trabaja
select count(*)
  from pr_prioridad_clientes
 where prioridad between 8000 and 8999
   and estado = 0
   and cod_cliente is null;

