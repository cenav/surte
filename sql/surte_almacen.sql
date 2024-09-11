select * from vw_ordenes_pedido_pendiente where pedido = 15026;

select pedido, numero, nuot_serie, nuot_tipoot_codigo, fecha, jaba, estado, art_cod_art
     , cant_formula, saldo
     , despachar, cod_lin, formu_art_cod_art, abre02, stock, tiene_stock, tiene_stock_ot
     , tiene_stock_item
  from vw_ordenes_pedido_pendiente
 where pedido = 12520;

select * from tmp_pedidos_30;

select * from v_ped_pend_tot;

select nvl(t.abreviada, 'OFICINA') as p_vende, nvl(e.zona, '00') as vende
     , to_char(e.fecha, 'YYYY') as p_ano
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

select nombre, numero, nro, valor_art, cod_pza, total_saos, total_blue, ranking, color_cod
     , numero_ot
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

select pedido, nuot_tipoot_codigo, nuot_serie, numero, fecha, formu_art_cod_art, jaba, estado
     , art_cod_art
     , valor, cant_formula, stock_inicial, cant_acum, stock_acumulado, tiene_stock, stock_saldo
     , faltante
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

select nro_pedido, fch_pedido, ot_tipo, ot_serie, ot_numero, formu_art, ot_estado, valor
     , tiene_stock_ot
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
 where nuot_tipoot_codigo = 'PR'
   and numero = 449402;

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

select cod_cliente, nom_cliente, nro_pedido, fch_pedido, ot_tipo, ot_serie, ot_numero, formu_art
     , ot_estado
     , tiene_stock_ot, valor
  from tmp_ordenes_surtir
 group by cod_cliente, nom_cliente, nro_pedido, fch_pedido, ot_tipo, ot_serie, ot_numero, formu_art
        , ot_estado
        , tiene_stock_ot, valor;

  with detalle as (
    -- comsume stock segun valor de juego de mayor a menor
    select cod_cliente, nombre, pedido, fch_pedido, nuot_tipoot_codigo, nuot_serie, numero, fecha
         , formu_art_cod_art, jaba, estado, art_cod_art, valor, cant_formula, cod_lin
         , stock as stock_inicial
         , sum(cant_formula)
               over (partition by cod_cliente, art_cod_art order by valor desc) as cant_acum_val
         , stock -
           sum(cant_formula)
               over (partition by cod_cliente, art_cod_art order by valor desc) as stock_acumulado_val
         , sum(cant_formula)
               over (partition by cod_cliente, art_cod_art order by fch_pedido) as cant_acum_fch
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
                      on p.ano_embarque = i.ano and p.mes_embarque = i.mes and
                         i.estado = 1
           where p.id_pedido = view_pedidos_pendientes_38.id_pedido
          )
       )
    )
     , calculo as (
    select d.cod_cliente, d.nombre, pedido, d.fch_pedido, nuot_tipoot_codigo, nuot_serie, numero
         , fecha, jaba
         , d.formu_art_cod_art, estado, d.art_cod_art, d.valor, d.cant_formula, d.cod_lin
         , d.stock_inicial
         , d.cant_acum_val, d.stock_acumulado_val
         , d.cant_acum_fch, d.stock_acumulado_fch
         , case
             when d.stock_acumulado_val < 0 then abs(d.stock_acumulado_val)
             else 0
           end as faltante_val
         , case
             when d.stock_acumulado_fch < 0 then abs(d.stock_acumulado_fch)
             else 0
           end as faltante_fch
         , case when d.stock_acumulado_val >= 0 then 1 else 0 end as tiene_stock_val
         , case when d.stock_acumulado_fch >= 0 then 1 else 0 end as tiene_stock_fch
      from detalle d
    )
select c.cod_cliente, c.nombre, pedido, c.fch_pedido, nuot_tipoot_codigo, nuot_serie, numero, fecha
     , c.formu_art_cod_art, jaba, estado, c.art_cod_art, c.valor, c.cant_formula, c.cod_lin
     , c.stock_inicial
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
select cod_cliente, nom_cliente, nro_pedido, fch_pedido, ot_tipo, ot_serie, ot_numero, formu_art
     , ot_estado
     , tiene_stock_ot, valor
  from tmp_ordenes_surtir
 group by cod_cliente, nom_cliente, nro_pedido, fch_pedido, ot_tipo, ot_serie, ot_numero, formu_art
        , ot_estado
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
    select cod_cliente, nombre, pedido, pedido_item, fch_pedido, nuot_tipoot_codigo, nuot_serie
         , numero, fecha
         , formu_art_cod_art, jaba, estado, art_cod_art, valor, cant_formula, cod_lin
         , stock as stock_inicial
         , impreso, fch_impresion, es_juego
         , sum(cant_formula)
               over (partition by art_cod_art order by es_juego desc, valor desc) as cant_acum
         , stock -
           sum(cant_formula)
               over (partition by art_cod_art order by es_juego desc, valor desc) as stock_acum
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
                      on p.ano_embarque = i.ano and p.mes_embarque = i.mes and
                         i.estado = 1
           where p.id_pedido = view_pedidos_pendientes_38.id_pedido
          )
       )
    )
     , calculo as (
    select d.cod_cliente, d.nombre, pedido, d.pedido_item, d.fch_pedido, nuot_tipoot_codigo
         , nuot_serie
         , numero, fecha, jaba, d.formu_art_cod_art, estado, d.art_cod_art, d.valor, d.cant_formula
         , d.cod_lin
         , d.stock_inicial, d.impreso, d.fch_impresion, d.es_juego, d.cant_acum, d.stock_acum
         , case when d.stock_acum < 0 then abs(d.stock_acum) else 0 end as faltante
         , case when d.stock_acum >= 0 then 1 else 0 end as tiene_stock
      from detalle d
    )
select c.cod_cliente, c.nombre, pedido, c.pedido_item, c.fch_pedido, nuot_tipoot_codigo, nuot_serie
     , numero
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
select cod_cliente, nombre, fch_pedido, pedido, pedido_item, numero, nuot_serie, nuot_tipoot_codigo
     , fecha
     , jaba, estado, art_cod_art, cant_formula, saldo, despachar, cod_lin, formu_art_cod_art, abre02
     , valor
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

select t.pedido, t.nuot_tipoot_codigo, t.nuot_serie, t.numero, t.fecha, t.formu_art_cod_art, t.jaba
     , t.estado
     , t.art_cod_art, t.valor, t.cant_formula, t.stock_inicial, t.cant_acum, t.stock_acumulado
     , t.tiene_stock
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
select ranking, nom_cliente, nro_pedido, itm_pedido, ot_numero, formu_art, valor, es_juego
     , tiene_importado
     , tiene_stock_ot, count(*) as piezas_distintas
  from tmp_ordenes_surtir
 group by ranking, nom_cliente, nro_pedido, itm_pedido, ot_numero, formu_art, valor, es_juego
        , tiene_stock_ot
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
select ranking, nom_cliente, nro_pedido, itm_pedido, ot_numero, formu_art, valor, es_juego
     , tiene_importado
     , tiene_stock_ot, piezas_distintas
  from vw_surte_item
 group by ranking, nom_cliente, nro_pedido, itm_pedido, ot_numero, formu_art, valor, es_juego
        , tiene_stock_ot
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
select ranking, nom_cliente, nro_pedido, itm_pedido, ot_numero, formu_art, valor, valor_surtir
     , es_juego
     , partir_ot, tiene_stock_ot, cod_art, cantidad, rendimiento, stock_inicial, cant_final
     , saldo_stock
     , linea, es_importado, tiene_stock_itm
  from tmp_ordenes_surtir
--  where cod_art = '380.722'
 order by ranking;

select *
  from tmp_ordenes_surtir
 where partir_ot is null;

select pais, nombre, zona
  from expaises
 order by nombre;

select *
  from expedidos
 where numero = 12447;

select codigo, descripcion
  from tablas_auxiliares
 where tipo = 25
 order by descripcion;

select *
  from vw_ordenes_pedido_pendiente
 where pedido = 12273;

select *
  from expaises
 where pais = '51';

select codigo, descripcion
  from extablas_expo
 where tipo = '13'
   and codigo <> '....'
   and codigo in ('02', '05')
 order by 1;

begin
  dbms_output.put_line(multiplo.inferior(33, 5));
end;

  with detalle as (
    select v.cod_cliente, v.nombre, v.fch_pedido, v.pedido, v.pedido_item, v.nuot_serie
         , v.nuot_tipoot_codigo, v.numero, v.fecha, v.formu_art_cod_art, v.estado, v.art_cod_art
         , v.cant_formula, v.rendimiento, v.saldo, v.despachar, v.cod_lin, v.abre02, v.preuni
         , v.valor
         , v.stock, v.tiene_stock, v.tiene_stock_ot, v.tiene_stock_item, v.tiene_importado
         , v.impreso
         , v.fch_impresion, v.es_juego, v.es_importado
         , case when lag(v.numero) over (order by null) = v.numero then null else v.numero end as oa
         , dense_rank() over (
      order by case when p.prioritario = 1 then v.es_prioritario end desc
        , case when trunc(sysdate) - v.fch_pedido > :p_dias then v.fch_pedido end
        , case when v.valor > p.valor_item then 1 else 0 end desc
        , v.es_juego
        , v.valor desc
      ) as ranking
      from vw_ordenes_pedido_pendiente v
           join param_surte p on p.id_param = 1
          --      where (v.pais = :p_pais or :p_pais is null)
--        and (v.vendedor = :p_vendedor or :p_vendedor is null)
          and (exists(
            select * from tmp_selecciona_cliente t where v.cod_cliente = t.cod_cliente
            ) or
               not exists(
                 select *
                   from tmp_selecciona_cliente
                 ))
--          where numero in (801975)
    )
select *
  from detalle
 order by ranking;

select * from param_surte;

select * from grupo_cliente;

select *
  from pr_formu
 where art_cod_art = '95037CS-1'
   and receta = 1;

select *
  from pr_ot
 where nuot_tipoot_codigo = 'AR'
   and nuot_serie = '3'
   and numero = 785221;

call surte_parte.parte_ot(p_tipo => 'AR', p_serie => '3', p_numero => 785207,
                          p_cant_partir => 4000);

select *
  from pr_ot_det
 where ot_nuot_tipoot_codigo = 'AR'
   and ot_nuot_serie = '3'
   and ot_numero = 785207
   and nvl(estado, '0') != '9';

select * from tmp_imprime_ot;

select *
  from vw_surte_item
 where impreso = 'NO'
   and (tiene_stock_ot = 'SI' or se_puede_partir = 'SI')
 order by ranking;

select user, ot_tipo, ot_serie, ot_numero
  from vw_surte_item
 where impreso = 'NO'
   and (tiene_stock_ot = 'SI' or se_puede_partir = 'SI');

select *
  from seccrus
 where co_usrusr = user;

select ot_numero, count(*)
  from vw_surte_item
 where se_puede_partir = 'SI'
having count(*) > 1
 group by ot_numero;

select *
  from pr_ot
 where nuot_tipoot_codigo = 'AR'
   and nuot_serie = 3
   and numero = 850461;

select *
  from pr_ot
 where nuot_tipoot_codigo = 'AR'
   and nuot_serie = 3
   and origen = 'PARTIDA'
   and trunc(fecha) = to_date('19/08/2022', 'dd/mm/yyyy');

select *
  from vw_surte_item
 where se_puede_partir = 'SI'
   and cant_partir > 0;


select *
  from pr_ot
 where nuot_tipoot_codigo = 'AR'
   and nuot_serie = 3
   and origen = 'PARTIDA'
   and trunc(fecha) = to_date('19/08/2022', 'dd/mm/yyyy')
   and cant_prog > 0
 order by observacion;


begin
  for r in (
    -- ordenes partidas por programa
    select nuot_tipoot_codigo, nuot_serie, numero, abre01, per_env, fecha
      from pr_ot
     where nuot_tipoot_codigo = 'AR'
       and nuot_serie = 3
       and origen = 'PARTIDA'
       and estado = '1'
       and trunc(fecha) = to_date('19/08/2022', 'dd/mm/yyyy')
       and cant_prog <= 0
    )
  loop
    delete
      from expedido_d
     where numero = r.abre01
       and nro = r.per_env;

    update pr_ot
       set estado = '9'
     where nuot_tipoot_codigo = r.nuot_tipoot_codigo
       and nuot_serie = r.nuot_serie
       and numero = r.numero;
  end loop;
end;

select *
  from expedido_d
 where numero = 15315
   and nro = 739;

select *
  from vw_ordenes_pedido_pendiente
 where nombre = 'PEVISA';

select *
  from expednac
 where numero = 403;

select *
  from extablas_expo
 where tipo = '13'
   and codigo <> '....'
 order by 2;

select codigo, descripcion
  from extablas_expo
 where tipo = '03'
   and codigo <> '....'
 order by descripcion;

select * from param_surte;


  with detalle as (
    select v.cod_cliente, v.nombre, v.fch_pedido, v.pedido, v.pedido_item, v.nuot_serie
         , v.nuot_tipoot_codigo, v.numero, v.fecha, v.formu_art_cod_art, v.estado, v.art_cod_art
         , v.cant_formula, v.rendimiento, v.saldo, v.despachar, v.cod_lin, v.abre02, v.preuni
         , v.valor
         , v.stock, v.tiene_stock, v.tiene_stock_ot, v.tiene_stock_item, v.tiene_importado
         , v.impreso
         , v.fch_impresion, v.es_juego, v.es_importado, v.pais, v.es_prioritario
         , case when lag(v.numero) over (order by null) = v.numero then null else v.numero end as oa
         , dense_rank() over (
      order by case when p.prioritario = 1 then v.es_prioritario end desc
--         , case when trunc(sysdate) - v.fch_pedido > :p_dias then 1 else 0 end desc
        , case when v.valor > p.valor_item then 1 else 0 end desc
        , v.es_juego
        , v.valor desc
        ,v.pedido
        ,v.pedido_item
      ) as ranking
      from vw_ordenes_pedido_pendiente v
           join param_surte p on p.id_param = 1
     where (v.es_prioritario = 1
       or ((v.pais = :p_pais or :p_pais is null)
         and (v.vendedor = :p_vendedor or :p_vendedor is null)
         and (v.empaque = :p_empaque or :p_empaque is null)
         and (trunc(sysdate) - v.fch_pedido > :p_dias or :p_dias is null)
         and (exists(
           select * from tmp_selecciona_cliente t where v.cod_cliente = t.cod_cliente
           ) or
              not exists(
                select *
                  from tmp_selecciona_cliente
                )))
       )
       and v.impreso = 'NO'
--        and pedido = 14660
--        and pedido_item = 135
       and exists(
       select *
         from pedidos_test t
        where v.pedido = t.numero
          and v.pedido_item = t.item
       )
    )
select *
  from detalle
 order by ranking, oa;

select * from vw_surte_item;

select *
  from vw_surte_item
 where se_puede_partir = 'SI'
   and (:p_prioritario = 1 or (:p_prioritario = 0 and es_prioritario = 'NO'))
 order by ranking;

select user, ot_tipo, ot_serie, ot_numero
  from vw_surte_item
 where impreso = 'NO'
   and (tiene_stock_ot = 'SI' or se_puede_partir = 'SI')
   and (:prioritario = 1 or (:prioritario = 0 and es_prioritario = 'NO'));

select t.ranking, t.nom_cliente, t.nro_pedido, to_char(t.fch_pedido, 'dd/mm/yyyy') as fch_pedido
     , t.ot_tipo
     , t.ot_serie, t.ot_numero, t.formu_art, t.ot_estado, t.valor, t.tiene_stock_ot, t.cod_art
     , t.cantidad
     , nvl(cant_final, 0) as cant_final, t.tiene_stock_itm
     , t.saldo_stock, t.linea, t.tiene_stock_itm, a.numero_op, t.es_importado, t.impreso
     , se_puede_partir
     , get_descripcion_grupo_pieza(t.cod_art) as grupo, stock_inicial, t.sobrante
  --, decode(se_puede_partir,'SI', t.cantidad - t.cant_final, cantidad) as faltante
     , t.cantidad - nvl(t.cant_final, 0) as faltante
  from vw_surte_pieza t
     , vw_articulo a
 where t.cod_art = a.cod_art
   and (tiene_stock_ot = 'NO' or se_puede_partir = 'SI')
   and t.tiene_stock_itm = 'NO'
   and t.es_importado = 'NO'
 order by ranking;


--  resumen de produccion
  with detalle as (
    select t.ranking, t.nom_cliente, t.nro_pedido, to_char(t.fch_pedido, 'dd/mm/yyyy') as fch_pedido
         , t.ot_tipo, t.ot_serie, t.ot_numero, t.formu_art, t.ot_estado, t.valor, t.tiene_stock_ot
         , t.cod_art
         , t.cantidad, nvl(cant_final, 0) as cant_final, t.tiene_stock_itm
         , t.saldo_stock, t.linea, t.tiene_stock_itm, t.es_importado, t.impreso, se_puede_partir
         , get_descripcion_grupo_pieza(t.cod_art) as grupo, stock_inicial, t.sobrante
         , t.cantidad - nvl(t.cant_final, 0) as faltante
      from vw_surte_pieza t
     where (tiene_stock_ot = 'NO' or se_puede_partir = 'SI')
       and t.tiene_stock_itm = 'NO'
       and t.es_importado = 'NO'
     order by ranking
    )
select *
  from detalle d
       join vw_articulo a on d.cod_art = a.cod_art;

select *
  from pr_ot_impresion
 where nuot_tipoot_codigo = 'AR'
   and numero = 819650;

select cod_cliente, nombre, fch_pedido, pedido, pedido_item, numero, estado, pais, vendedor, empaque
     , formu_art_cod_art, valor, dias_impreso, fch_impresion, es_juego, es_prioritario, cant_prog
     , color
  from vw_ordenes_impresas_pendientes
 order by dias_impreso desc, valor desc;

select descripcion, color from vw_rango_dias_impreso order by id;

select * from pr_prioridad_htmp_30;

select * from pr_prioridad_tmp_30;

select * from pr_prioridad_pza_30;

select * from pr_prioridad_sao_30;

select * from tmp_surte_jgo;

select *
  from tmp_surte_pza
 where nro_pedido = 14743
   and itm_pedido = 45;

select *
  from vw_surte_pza
 where nro_pedido = 14743
   and itm_pedido = 45;

select *
  from articul
 where cod_art = 'SA SB95353-4'
   and tp_art = 'A';

select *
  from pcmasters
 where cod_art = 'TO450.735PA-I';

-- SAO explosion
select f.cod_art, f.cod_for, f.tipo, f.canti, f.neto, f.linea, a.tp_art
  from pcformulas f
       join articul a on f.cod_for = a.cod_art
 where f.cod_art = 'SA SB95353-4'
   and a.tp_art = 'P';


declare
  type formula_t is record (
    cod_for pcformulas.cod_art%type,
    canti   pcformulas.canti%type
  );

  type formulas_aat is table of formula_t index by pls_integer;

  type master_t is record (
    cod_art pcmasters.cod_art%type,
    formula formulas_aat
  );

  type master_aat is table of master_t index by varchar2(30);

  l_idx    varchar2(30);
  l_start  pls_integer;
  l_master master_aat;

  cursor formulas_cr is
    -- SAO explosion
    select f.cod_art, f.cod_for, f.tipo, f.canti, f.neto, f.linea, a.tp_art
         , case
             when lag(f.cod_art) over (order by null) = f.cod_art then null
             else f.cod_art
           end as quiebre
      from pcformulas f
           join articul m on f.cod_art = m.cod_art
           join articul a on f.cod_for = a.cod_art
     where m.tp_art = 'A'
       and a.tp_art = 'P'
     order by f.cod_art;

  procedure master(
    p_formula formulas_cr%rowtype
  ) is
  begin
    l_master(p_formula.cod_art).cod_art := p_formula.cod_art;
  end;

  procedure detail(
    p_formula formulas_cr%rowtype
  ) is
    l_idx pls_integer;
  begin
    l_idx := l_master(p_formula.cod_art).formula.count + 1;
    l_master(p_formula.cod_art).formula(l_idx).cod_for := p_formula.cod_for;
  end;

  procedure show_elapsed(
    name_in in varchar2
  ) is
  begin
    dbms_output.put_line(
        name_in
          || ' elapsed CPU time: '
          || to_char(dbms_utility.get_cpu_time - l_start));
  end show_elapsed;
begin
  l_start := dbms_utility.get_cpu_time;

  for formula in formulas_cr loop
    if formula.quiebre is not null then
      master(formula);
      detail(formula);
    elsif formula.quiebre is null then
      detail(formula);
    end if;
  end loop;

  show_elapsed('Procedure');
  dbms_output.put_line('Total registros ' || l_master.count);

  l_idx := 'SA SB95353-4';
  for i in l_master(l_idx).formula.first .. l_master(l_idx).formula.last loop
    dbms_output.put_line(l_master(l_idx).formula(i).cod_for);
  end loop;
end;


declare
  l_explosion surte_formula.master_aat;
  l_idx       surte_util.t_articulo;
begin
  l_idx := 'SA SB95353-4';
  l_explosion := surte_formula.explosion(l_idx);
  for i in l_explosion(l_idx).formulas.first .. l_explosion(l_idx).formulas.last loop
    dbms_output.put_line(l_explosion(l_idx).formulas(i).cod_for);
  end loop;
end;

declare
  l_explosion surte_formula.master_aat;
  l_idx       surte_util.t_articulo;
begin
  l_idx := 'SA SB95353-4';
  l_explosion := surte_formula.explosion(l_idx);
  if l_explosion.exists(l_idx
    ) then
    dbms_output.put_line('SI');
  else
    dbms_output.put_line('NO');
  end if;
  dbms_output.put_line(l_explosion.count);
end;

delete from tmp_surte_jgo;
delete from tmp_surte_pza;
delete from tmp_surte_sao;

select * from tmp_surte_jgo;
select * from tmp_surte_pza;
select * from tmp_surte_sao;


select *
  from tmp_surte_pza
 where stock_inicial != stock_actual;

-- 180.761FB

select *
  from logger_logs
 order by id desc;

select sysdate from dual;

select * from vw_surte_sao;

select * from color_surtimiento;

select *
  from pcformulas
 where cod_art = 'SA 3540MX3-1';

select *
  from tmp_surte_jgo
 where tiene_stock_ot = 'NO'
    or partir_ot = 0;

select *
  from all_arguments
 where package_name = 'SURTE';

select * from color_surtimiento order by peso;

select * from vw_surte_jgo;

select * from tmp_surte_pza;

select *
  from vw_surte_jgo
 order by ranking;

select nvl(sum(valor_surtir), 0) as color, count(*)
  from vw_surte_jgo
 where id_color in ('B', 'C');

select nvl(sum(valor_surtir), 0) as color, count(*)
  from vw_surte_jgo
 where tiene_stock_ot = 'SI' or se_puede_partir = 'SI'
   and id_color in ('B', 'C');

select *
  from vw_surte_jgo
 where tiene_stock_ot = 'SI' or se_puede_partir = 'SI'
   and id_color not in ('B', 'C');

select *
  from vw_ordenes_pedido_pendiente
 where pedido = 14660
   and pedido_item = 19;

select *
  from vw_surte_jgo
 where nro_pedido = 14660
   and itm_pedido = 135;

select dsc_color, id_color from color_surtimiento order by peso;



-- (id_estado = :busca.estado or :busca.estado is null) and
-- (ot_nro = :busca.ot_nro or :busca.ot_nro is null) and
-- (usuario = user or :global.supermaestro = 'SI') and
-- (TRUNC(fch_solicitud) between :busca.fecha_del and :busca.fecha_al) and
-- (ot_tpo in (select c.ot_tipo from tipo_cambio_ot c where c.id_tipo = :global.tipo))

select * from solicita_cambio_ot;

select * from solicita_cambio_ot_det;

select * from motivo_cambio_ot;

select * from estado_cambio_ot;

select * from vw_solicita_cambio_ot;

select * from kardex_g;

select * from tmp_surte_jgo;

select * from tmp_surte_pza;

begin
  surte.por_item();
end;

select *
  from vw_ordenes_pedido_pendiente
 where art_cod_art = '290.3087';

  with saos as (
    select f.cod_for
      from vw_formula_saos f
     group by f.cod_for
    )
select a.cod_for, nvl(s.stock, 0) as stock
  from saos a
       left join vw_stock_almacen s on a.cod_for = s.cod_art
 where a.cod_for = '290.3087';

select f.cod_for
  from vw_formula_saos f
 where f.cod_for = '290.3087';

select *
  from vw_stock_almacen
 where cod_art = '290.3087';

select * from grupo_cliente;

select * from grupo_cliente_cliente;

select 'COMPLETO' as dsc, 'C' as id from dual union select 'PARTIR' as dsc, 'P' as id from dual;


select 'RESERVA' as dsc, 'P' as id
  from dual
 union
select 'FALTANTE' as dsc, 'F' as id
  from dual
 union
select 'URGENTE' as dsc, 'U' as id
  from dual;

select *
  from exclientes
 where abreviada = 'OEGER';

-- ((:busca.stock = 1 and (tiene_stock_ot = 'SI' or se_puede_partir = 'SI')) or
--   (:busca.stock = 2 and tiene_stock_ot = 'SI') or
--   (:busca.stock = 3 and se_puede_partir = 'SI') or
--   (:busca.stock = 9)) and
-- (cod_cliente = :busca.cliente or :busca.cliente is null) and
-- (id_color = :busca.colores or :busca.colores is null) and
-- (:global.prioritario = 1 or (:global.prioritario = 0 and es_prioritario != 'SI'))
--

select * from param_surte;

select * from reserva_surtimiento;

select *
  from reserva_surtimiento
 where pedido_nro = 15080
   and pedido_itm = 51;

select *
  from vw_ordenes_pedido_pendiente
 where es_reservado = 1;

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
     where (v.es_prioritario = 1
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
         and
           (exists(
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
  from vw_surte_jgo
 order by ranking;

select * from tmp_surte_jgo;

select j.id_color, j.ranking, j.nom_cliente, j.nro_pedido, j.itm_pedido, j.cod_jgo
     , p.id_color, p.cod_pza, p.cantidad, j.es_urgente
  from vw_surte_jgo j
       join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
 where j.cod_cliente in ('G002')
   and j.id_color in ('R', 'F')
   and p.id_color = 'F'
 order by ranking;

select j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, sum(p.cantidad) as cantidad
  from vw_surte_jgo j
       join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
       join vw_articulo a on p.cod_pza = a.cod_art
 where j.cod_cliente = 'G002'
   and j.id_color in ('R', 'F')
   and p.id_color = 'F'
 group by j.nom_cliente, p.cod_pza, a.dsc_grupo, a.cod_lin
 order by 2;

-- importados
select j.id_color, j.ranking, j.nom_cliente, j.nro_pedido, j.itm_pedido, j.cod_jgo
     , p.id_color, p.cod_pza, p.cantidad, j.es_urgente
  from vw_surte_jgo j
       join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
 where j.cod_cliente in ('G002')
   and j.id_color in ('I')
   and p.id_color = 'I'
 order by ranking;

select j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, sum(p.cantidad) as cantidad
  from vw_surte_jgo j
       join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
       join vw_articulo a on p.cod_pza = a.cod_art
 where j.cod_cliente = 'G002'
   and j.id_color in ('I')
   and p.id_color = 'I'
 group by j.nom_cliente, p.cod_pza, a.dsc_grupo, a.cod_lin
 order by 2;

select * from grupo_cliente;

select * from grupo_cliente_cliente;

select * from tmp_surte_jgo;

select * from tmp_surte_pza;

select 'COMPLETO' as dsc, 'C' as id, 1 as orden
  from dual
 union
select 'ARMAR' as dsc, 'A' as id, 2 as orden
  from dual
 union
select 'PARTIR' as dsc, 'P' as id, 3 as orden
  from dual
 order by orden;

select 'COMPLETO' as dsc, 'C' as id
  from dual
 union
select 'ARMAR' as dsc, 'A' as id
  from dual
 union
select 'PARTIR' as dsc, 'P' as id
  from dual;


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
       and pedido = 16500
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
 where id_pedido = 16500;

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
  from exclientes
 where cod_cliente in (
                       '990937', '996057'
   );

select * from color_surtimiento;

select * from tmp_surte_pza;

  with prueba as (
    select id_pedido
      from view_pedidos_pendientes_38
     where exists(
       select 1
         from pr_embarques p
              join pr_programa_embarques_id i
                   on p.ano_embarque = i.ano and p.mes_embarque = i.mes and i.estado = 1
        where p.id_pedido = view_pedidos_pendientes_38.id_pedido
       )
     union
    select id_pedido
      from view_pedidos_pendientes_38
     where cod_cliente in (
       select gcc.cod_cliente
         from grupo_cliente gc
              join grupo_cliente_cliente gcc on gc.cod_grupo = gcc.cod_grupo
        where gc.es_simulacion = 1
       )
    )
select *
  from prueba
 where id_pedido in (16417, 16446);

select *
  from view_pedidos_pendientes_38
 where id_pedido in (16417, 16446);

select *
  from view_pedidos_pendientes_38
 where cod_cliente = '998121';

select id_pedido
  from view_pedidos_pendientes_38
 where cod_cliente in (
   select gcc.cod_cliente
     from grupo_cliente gc
          join grupo_cliente_cliente gcc on gc.cod_grupo = gcc.cod_grupo
    where gc.es_simulacion = 1
   );

select *
  from grupo_cliente gc
       join grupo_cliente_cliente gcc on gc.cod_grupo = gcc.cod_grupo
 where gc.es_simulacion = 1;