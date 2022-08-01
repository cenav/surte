select * from vw_ordenes_pedido_pendiente where pedido = 15026;

select pedido, numero, nuot_serie, nuot_tipoot_codigo, fecha, jaba, estado, art_cod_art, cant_formula, saldo
     , despachar, cod_lin, formu_art_cod_art, abre02, stock, tiene_stock, tiene_stock_ot, tiene_stock_item
  from vw_ordenes_pedido_pendiente

 where pedido = 12520;

select * from tmp_pedidos_30;

select * from v_ped_pend_tot;

select nvl(t.abreviada, 'OFICINA') as p_vende, nvl(e.zona, '00') as vende, to_char(e.fecha, 'YYYY') as p_ano
     , to_char(e.fecha, 'MM') as p_mes, e.numero, p.zona, p.abrevia, e.nombre, e.cod_cliente
     , pr_saldo_ped_tot(e.numero, e.fflete) as total
  from expedidos e
       join exclientes c on c.cod_cliente = e.cod_cliente
       left join expaises p on e.pais = p.pais
       left join extablas_expo t on t.codigo = nvl(e.zona, '00') and t.tipo = '13'
 where nvl(e.estado, '0') not in ('8', '9', '85', 'T')
   and pr_saldo_ped_tot(e.numero, e.fflete) > 0
 order by 1, 2, 3, 4, 5;

select * from view_prioridades_pendientes_38;

select *
  from pr_embarques_prioridad_orden
 where ano_embarque = 2022
   and mes_embarque = 5
 order by orden;

-- orden de prioridad
select p.*, o.orden
  from view_prioridades_pendientes_38 p
       join pr_embarques_prioridad_orden o
            on p.prioridad = o.prioridad
              and o.ano_embarque = 2022
              and o.mes_embarque = 5
 order by orden;

select *
  from view_pedidos_pendientes_38
 where prioridad = 6190;

-- pedidos a surtir
select distinct id_pedido
  from view_pedidos_pendientes_38
 where prioridad = 6129
 order by 1;

select * from vw_planprod_resumen_pza;

select * from planprod_pza;

select * from planprod_sao;

select *
  from expedido_d
 where numero = 14771;

select *
  from expedidos e
       join expedido_d d on e.numero = d.numero
 where e.fecha > to_date('01/01/2022', 'dd/mm/yyyy')
   and d.id = 'AN';


select distinct estado
  from pr_ot
 where nuot_tipoot_codigo = 'AR';


select *
  from vw_ordenes_pedido_pendiente
 where pedido = 12473;

select valor_art_desde, valor_art_hasta, maximo_piezas_faltantes, descripcion
  from pr_embarques_items_suman_plata
 order by maximo_piezas_faltantes;

-- TODOS LOS FALTANTES
-- ENTRE 500 Y 1000
-- ENTRE 1000 Y 3000
-- ENTRE 3000 Y 5000
-- DE 5000 A MAS

select nombre, numero, nro, valor_art, cod_pza, total_saos, total_blue, ranking, color_cod, numero_ot
  from vw_saos_porc_color;

select art_cod_art, count(*)
  from vw_ordenes_pedido_pendiente
 where pedido = 14987
--    and tiene_stock_ot = 'SI'
having count(*) > 1
 group by art_cod_art
 order by 2 desc;

select *
  from vw_ordenes_pedido_pendiente
 where pedido = 12473
   and formu_art_cod_art = 'V 95097 R';

-- 14987

select pedido, nuot_tipoot_codigo, nuot_serie, numero, fecha, formu_art_cod_art, jaba, estado, art_cod_art
     , valor, cant_formula, stock_inicial, cant_acum, stock_acumulado, tiene_stock, stock_saldo, faltante
     , tiene_stock_ot, tiene_stock_item
  from vw_surte_pedido
 where pedido = 14987;

select *
  from vw_surte_pedido
 where pedido = 14987
 order by art_cod_art;



select * from vw_surte_cliente where cod_cliente = '991503';

select * from exclientes where cod_cliente = '991503';

select * from tmp_ordenes_surtir;

select cod_cliente, nom_cliente, nro_pedido, fch_pedido, ot_tipo, ot_serie, ot_numero, formu_art
     , ot_estado, tiene_stock_ot, valor
  from tmp_ordenes_surtir
 group by cod_cliente, nom_cliente, nro_pedido, fch_pedido, ot_tipo, ot_serie, ot_numero, formu_art
        , ot_estado, tiene_stock_ot, valor
 order by valor desc;

select nombre, cod_cliente
  from exclientes
 order by nombre;

select * from exclientes;

select nro_pedido, fch_pedido, ot_tipo, ot_serie, ot_numero, formu_art, ot_estado, valor, tiene_stock_ot
     , cod_art, cantidad, saldo_stock, faltante, linea, tiene_stock_itm
  from tmp_ordenes_surtir
 order by valor desc;


select * from view_pedidos_pendientes_38 where cod_cliente = '991503';

select * from view_pedidos_pendientes_38 where cod_cliente = '991503' and prioridad = 6103;

select * from tmp_ordenes_surtir;

select *
  from vw_repuesto_otm
 where otm_tipo = 'MQ'
   and otm_serie = 3
   and otm_numero = 1588;

select *
  from capacitacion_empleado
 where id_capacitacion = 1446;

select *
  from capacitacion
 where id_capacitacion = 1446;

select codigo, descripcion
  from tablas_auxiliares
 where tipo = 72 and codigo <> '....'
   and codigo like decode(4, '13', '03',
                          '14', '03',
                          '%');

select *
  from tablas_auxiliares
 where tipo = 72
   and codigo <> '....';

select *
  from pr_ot
 where nuot_tipoot_codigo = 'AR'
   and numero = 704407;

select max(fecha)
  from pr_ot_impresion
 where nuot_tipoot_codigo = 'AR'
   and numero = 704407;

select nombre
  from expedidos
 where numero = 1224;

select *
  from vw_saos_porc_color
 where numero = 15029
   and cod_pza = 'SA MH88105-1';

select * from tmp_ordenes_surtir;

select cod_cliente, nom_cliente, sum(valor) as valor
  from tmp_ordenes_surtir
 group by cod_cliente, nom_cliente
 order by 3 desc;

select cod_cliente, nom_cliente, nro_pedido, fch_pedido, ot_tipo, ot_serie, ot_numero, formu_art, ot_estado
     , tiene_stock_ot, valor
  from tmp_ordenes_surtir
 group by cod_cliente, nom_cliente, nro_pedido, fch_pedido, ot_tipo, ot_serie, ot_numero, formu_art, ot_estado
        , tiene_stock_ot, valor;

  with detalle as (
    -- comsume stock segun valor de juego de mayor a menor
    select cod_cliente, nombre, pedido, fch_pedido, nuot_tipoot_codigo, nuot_serie, numero, fecha
         , formu_art_cod_art, jaba, estado, art_cod_art, valor, cant_formula, cod_lin, stock as stock_inicial
         , sum(cant_formula) over (partition by cod_cliente, art_cod_art order by valor desc) as cant_acum_val
         , stock -
           sum(cant_formula)
               over (partition by cod_cliente, art_cod_art order by valor desc) as stock_acumulado_val
         , sum(cant_formula) over (partition by cod_cliente, art_cod_art order by fch_pedido) as cant_acum_fch
         , stock -
           sum(cant_formula)
               over (partition by cod_cliente, art_cod_art order by fch_pedido) as stock_acumulado_fch
      from vw_ordenes_pedido_pendiente
     where exists(
               select 1
                 from view_pedidos_pendientes_38
                where view_pedidos_pendientes_38.cod_cliente = vw_ordenes_pedido_pendiente.cod_cliente
                  and view_pedidos_pendientes_38.id_pedido = vw_ordenes_pedido_pendiente.pedido
                  and exists(
                    select 1
                      from pr_embarques p
                           join pr_programa_embarques_id i
                                on p.ano_embarque = i.ano and p.mes_embarque = i.mes and i.estado = 1
                     where p.id_pedido = view_pedidos_pendientes_38.id_pedido
                  )
             )
    )
     , calculo as (
    select d.cod_cliente, d.nombre, pedido, d.fch_pedido, nuot_tipoot_codigo, nuot_serie, numero, fecha, jaba
         , d.formu_art_cod_art, estado, d.art_cod_art, d.valor, d.cant_formula, d.cod_lin, d.stock_inicial
         , d.cant_acum_val, d.stock_acumulado_val
         , d.cant_acum_fch, d.stock_acumulado_fch
         , case when d.stock_acumulado_val < 0 then abs(d.stock_acumulado_val) else 0 end as faltante_val
         , case when d.stock_acumulado_fch < 0 then abs(d.stock_acumulado_fch) else 0 end as faltante_fch
         , case when d.stock_acumulado_val >= 0 then 1 else 0 end as tiene_stock_val
         , case when d.stock_acumulado_fch >= 0 then 1 else 0 end as tiene_stock_fch
      from detalle d
    )
select c.cod_cliente, c.nombre, pedido, c.fch_pedido, nuot_tipoot_codigo, nuot_serie, numero, fecha
     , c.formu_art_cod_art, jaba, estado, c.art_cod_art, c.valor, c.cant_formula, c.cod_lin, c.stock_inicial
     , c.cant_acum_val, c.stock_acumulado_val, c.tiene_stock_val, c.faltante_val
     , c.cant_acum_fch, c.stock_acumulado_fch, c.tiene_stock_fch, c.faltante_fch
     , case when c.stock_acumulado_val > 0 then c.stock_acumulado_val else 0 end as stock_saldo_val
     , case when c.stock_acumulado_fch > 0 then c.stock_acumulado_fch else 0 end as stock_saldo_fch
     , case min(c.tiene_stock_val) over (partition by c.nuot_tipoot_codigo, c.numero, c.nuot_serie)
         when 0 then 'NO'
         else 'SI'
       end as tiene_stock_ot_val
     , case min(c.tiene_stock_fch) over (partition by c.nuot_tipoot_codigo, c.numero, c.nuot_serie)
         when 0 then 'NO'
         else 'SI'
       end as tiene_stock_ot_fch
     , case c.tiene_stock_val when 0 then 'NO' else 'SI' end as tiene_stock_item_val
     , case c.tiene_stock_fch when 0 then 'NO' else 'SI' end as tiene_stock_item_fch
  from calculo c;

create or replace view vw_ordenes_surtir_cliente as
select cod_cliente, nom_cliente, sum(valor) as valor
     , sum(case tiene_stock_ot when 'SI' then valor else 0 end) as tiene_stock_valor4
  from vw_ordenes_surtir_pedido
 group by cod_cliente, nom_cliente;

create view vw_ordenes_surtir_pedido as
select cod_cliente, nom_cliente, nro_pedido, fch_pedido, ot_tipo, ot_serie, ot_numero, formu_art, ot_estado
     , tiene_stock_ot, valor
  from tmp_ordenes_surtir
 group by cod_cliente, nom_cliente, nro_pedido, fch_pedido, ot_tipo, ot_serie, ot_numero, formu_art, ot_estado
        , tiene_stock_ot, valor;

select * from vw_ordenes_surtir_cliente;

select * from vw_ordenes_surtir_pedido;

select nuot_tipoot_codigo, nuot_serie, numero, max(fecha) as fecha
  from pr_ot_impresion
--  where nuot_tipoot_codigo = 'AR'
--    and numero = 797006
 group by nuot_tipoot_codigo, nuot_serie, numero;

select *
  from pr_ot_impresion
 where nuot_tipoot_codigo = 'AR'
   and numero = 704407;

select *
  from articul
 where cod_art = '303628A00 MLS';

select *
  from tab_lineas
 where linea in ('916', '1049', '919', '55');

select *
  from pr_prioridad_tmp_30
 where cod_eqi = '98362800 MLS';

select *
  from pr_prioridad_pza_30
 where cod_pza = '98362800 MLS';

select *
  from pr_prioridad_tmp_30
 where numero = 14832
   and nro = 43;

select *
  from pr_prioridad_pza_30
 where numero = 14832
   and nro = 43;

select *
  from vw_ordenes_pedido_pendiente
 where pedido = 14832
   and pedido_item = 43;

select *
  from vw_ordenes_pedido_pendiente
 where numero = 789560;

select *
  from pcarticul
 where cod_art = '98362800 MLS';

-- Tambien indicador de PC_ARTICUL

select *
  from pr_prioridad_pza_30 p
       join articul a on p.cod_pza = a.cod_art
 where a.indicador like 'I%'
   and p.color = 'M';

select *
  from pr_prioridad_pza_30
 where cod_pza = '400.1343'
 order by prioridad;

select nuot_tipoot_codigo, nuot_serie, numero from pr_ot;

select *
  from pr_ot
 where nuot_tipoot_codigo = 'AR'
   and numero = 801819;

select *
  from pr_ot_impresion
 where nuot_tipoot_codigo = 'AR'
   and numero in (816677, 804057, 804056);

select * from vw_surte_cliente;

select * from exlineas;

select * from tab_grupos;

select *
  from tab_lineas
 where linea = '82';

  with detalle as (
    -- comsume stock segun valor de juego de mayor a menor
    select cod_cliente, nombre, pedido, pedido_item, fch_pedido, nuot_tipoot_codigo, nuot_serie, numero, fecha
         , formu_art_cod_art, jaba, estado, art_cod_art, valor, cant_formula, cod_lin, stock as stock_inicial
         , impreso, fch_impresion, es_juego
         , sum(cant_formula) over (partition by art_cod_art order by es_juego desc, valor desc) as cant_acum
         , stock -
           sum(cant_formula) over (partition by art_cod_art order by es_juego desc, valor desc) as stock_acum
      from vw_ordenes_pedido_pendiente
     where exists(
             -- prioridades marcadas (que si se atienden)
               select 1
                 from view_pedidos_pendientes_38
                where view_pedidos_pendientes_38.cod_cliente = vw_ordenes_pedido_pendiente.cod_cliente
                  and view_pedidos_pendientes_38.id_pedido = vw_ordenes_pedido_pendiente.pedido
                  and exists(
                    select 1
                      from pr_embarques p
                           join pr_programa_embarques_id i
                                on p.ano_embarque = i.ano and p.mes_embarque = i.mes and i.estado = 1
                     where p.id_pedido = view_pedidos_pendientes_38.id_pedido
                  )
             )
    )
     , calculo as (
    select d.cod_cliente, d.nombre, pedido, d.pedido_item, d.fch_pedido, nuot_tipoot_codigo, nuot_serie
         , numero, fecha, jaba, d.formu_art_cod_art, estado, d.art_cod_art, d.valor, d.cant_formula, d.cod_lin
         , d.stock_inicial, d.impreso, d.fch_impresion, d.es_juego, d.cant_acum, d.stock_acum
         , case when d.stock_acum < 0 then abs(d.stock_acum) else 0 end as faltante
         , case when d.stock_acum >= 0 then 1 else 0 end as tiene_stock
      from detalle d
    )
select c.cod_cliente, c.nombre, pedido, c.pedido_item, c.fch_pedido, nuot_tipoot_codigo, nuot_serie, numero
     , fecha, c.formu_art_cod_art, jaba, estado, c.art_cod_art, c.valor, c.cant_formula, c.cod_lin
     , c.stock_inicial, c.impreso, c.fch_impresion, c.es_juego
     , c.cant_acum, c.stock_acum, c.tiene_stock, c.faltante
     , case when c.stock_acum > 0 then c.stock_acum else 0 end as stock_saldo
     , case min(c.tiene_stock) over (partition by c.nuot_tipoot_codigo, c.numero, c.nuot_serie)
         when 0 then 'NO'
         else 'SI'
       end as tiene_stock_ot
     , case c.tiene_stock when 0 then 'NO' else 'SI' end as tiene_stock_item
  from calculo c
 order by es_juego desc, valor desc;


-- recur
  with count_up(n) as (
    select 1 as n
      from dual
     union all
    select n + 1
      from count_up
     where n < 3
    )
select *
  from count_up;


-- Items de pedidos que se van a atender, prioridad a los que son juegos y mas suman
select cod_cliente, nombre, fch_pedido, pedido, pedido_item, numero, nuot_serie, nuot_tipoot_codigo, fecha
     , jaba, estado, art_cod_art, cant_formula, saldo, despachar, cod_lin, formu_art_cod_art, abre02, valor
     , stock, tiene_stock, tiene_stock_ot, tiene_stock_item, impreso, fch_impresion, es_juego
  from vw_ordenes_pedido_pendiente
 where exists(
         -- prioridades marcadas (que si se atienden)
           select 1
             from view_pedidos_pendientes_38
            where view_pedidos_pendientes_38.cod_cliente = vw_ordenes_pedido_pendiente.cod_cliente
              and view_pedidos_pendientes_38.id_pedido = vw_ordenes_pedido_pendiente.pedido
              and exists(
                select 1
                  from pr_embarques p
                       join pr_programa_embarques_id i
                            on p.ano_embarque = i.ano and p.mes_embarque = i.mes and i.estado = 1
                 where p.id_pedido = view_pedidos_pendientes_38.id_pedido
              )
         )
 order by es_juego desc, valor desc;

-- orden inicial para consumo de stock
select nombre, pedido, pedido_item, formu_art_cod_art, valor, es_juego
  from vw_ordenes_pedido_pendiente
 where exists(
         -- prioridades marcadas (que si se atienden)
           select 1
             from view_pedidos_pendientes_38
            where view_pedidos_pendientes_38.cod_cliente = vw_ordenes_pedido_pendiente.cod_cliente
              and view_pedidos_pendientes_38.id_pedido = vw_ordenes_pedido_pendiente.pedido
              and exists(
                select 1
                  from pr_embarques p
                       join pr_programa_embarques_id i
                            on p.ano_embarque = i.ano and p.mes_embarque = i.mes and i.estado = 1
                 where p.id_pedido = view_pedidos_pendientes_38.id_pedido
              )
         )
 group by pedido, pedido_item, formu_art_cod_art, valor, nombre, es_juego
 order by es_juego desc, valor desc;

select * from vw_ordenes_pedido_pendiente;

select t.pedido, t.nuot_tipoot_codigo, t.nuot_serie, t.numero, t.fecha, t.formu_art_cod_art, t.jaba, t.estado
     , t.art_cod_art, t.valor, t.cant_formula, t.stock_inicial, t.cant_acum, t.stock_acumulado, t.tiene_stock
     , t.stock_saldo, t.faltante, t.tiene_stock_ot, t.tiene_stock_item, t.cod_lin
  from vw_surte_pedido t
 where pedido = :pedido;

select *
  from vw_ordenes_pedido_pendiente
 where pedido = 410;

select *
  from vw_surte_pedido
 where pedido = 410;

select *
  from vw_surte_pedido
 where art_cod_art = 'SAHS4811W2N';

select * from tmp_ordenes_surtir;

select *
  from vw_ordenes_pedido_pendiente
 where pedido = 15265;

select * from vw_ordenes_pedido_pendiente;

select distinct art_cod_art, stock from vw_ordenes_pedido_pendiente;

select nombre, pedido, pedido_item, formu_art_cod_art, valor, es_juego
  from vw_ordenes_pedido_pendiente
 group by pedido, pedido_item, formu_art_cod_art, valor, nombre, es_juego
 order by es_juego desc, valor desc;

select *
  from view_pedidos_pendientes_38
 where exists(
           select 1
             from pr_embarques p
                  join pr_programa_embarques_id i
                       on p.ano_embarque = i.ano and p.mes_embarque = i.mes and i.estado = 1
            where p.id_pedido = view_pedidos_pendientes_38.id_pedido
         );

select * from view_prioridades_pendientes_38;
select * from view_pedidos_pendientes_38;

select distinct p.id_pedido
  from pr_embarques p
       join pr_programa_embarques_id i
            on p.ano_embarque = i.ano and p.mes_embarque = i.mes and i.estado = 1;


-- agrupado por juegos
select ranking, nom_cliente, nro_pedido, itm_pedido, ot_numero, formu_art, valor, es_juego, tiene_importado
     , tiene_stock_ot, count(*) as piezas_distintas
  from tmp_ordenes_surtir
 group by ranking, nom_cliente, nro_pedido, itm_pedido, ot_numero, formu_art, valor, es_juego, tiene_stock_ot
        , tiene_importado
 order by ranking;

select *
  from tmp_ordenes_surtir
 where cod_art = '300.151VMI'
 order by ranking;

-- solo lo que tiene stock y se pude facturar
  with detalle as (
    select nom_cliente, nro_pedido, itm_pedido, valor
      from tmp_ordenes_surtir
     where tiene_stock_ot = 'SI'
     group by nom_cliente, nro_pedido, itm_pedido, valor
    )
select sum(d.valor)
  from detalle d;

-- lo que en teoria se podria facturar
  with detalle as (
    select nom_cliente, nro_pedido, itm_pedido, valor
      from tmp_ordenes_surtir
     where valor > 5000
       and tiene_importado = 0
     group by nom_cliente, nro_pedido, itm_pedido, valor
    )
select sum(d.valor)
  from detalle d;


select * from grupo_cliente;

select * from grupo_cliente_cliente;

select * from vw_surte_item order by ranking;

select * from vw_surte_pieza order by ranking;

select max(ranking) from vw_surte_pieza;

-- agrupado por juegos
select ranking, nom_cliente, nro_pedido, itm_pedido, ot_numero, formu_art, valor, es_juego, tiene_importado
     , tiene_stock_ot, piezas_distintas
  from vw_surte_item
 group by ranking, nom_cliente, nro_pedido, itm_pedido, ot_numero, formu_art, valor, es_juego, tiene_stock_ot
        , tiene_importado, piezas_distintas
 order by ranking;

select cod_cliente, nom_cliente
  from vw_surte_item
 group by cod_cliente, nom_cliente
 order by nom_cliente;

select *
  from tmp_ordenes_surtir
 order by ranking;

select *
  from tmp_ordenes_surtir
 where tiene_stock_ot = 'SI';

select *
  from tmp_ordenes_surtir
 where partir_ot = 1;

select * from param_surte;

call surte.por_item();

-- detalle piezas
select ranking, nom_cliente, nro_pedido, itm_pedido, ot_numero, formu_art, valor, valor_surtir, es_juego
     , partir_ot, tiene_stock_ot, cod_art, cantidad, rendimiento, stock_inicial, cant_final, saldo_stock
     , linea, es_importado, tiene_stock_itm
  from tmp_ordenes_surtir
--  where cod_art = '380.722'
 order by ranking;

select *
  from tmp_ordenes_surtir
 where partir_ot is null;