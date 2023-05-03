select * from vw_surte_jgo;

-- faltante
select j.id_color, j.ranking, j.nom_cliente, j.nro_pedido, j.itm_pedido, j.cod_jgo, j.valor
     , p.id_color, p.cod_pza, p.cantidad, j.es_simulacion, j.es_urgente, j.cant_faltante
  from vw_surte_jgo j
       join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
 where j.id_color in ('R', 'F')
   and p.id_color = 'F'
   and ((j.cod_cliente = :cliente or :cliente is null) and
        (j.es_simulacion like :simulacion) and
        (j.es_urgente like :urgente) and
        (j.cant_faltante <= :p_faltante or :p_faltante is null))
 order by ranking;

select j.id_color, j.ranking, j.nom_cliente, j.nro_pedido, j.itm_pedido, j.cod_jgo
     , p.id_color, p.cod_pza, p.cantidad, j.es_simulacion, j.es_urgente
  from vw_surte_jgo j
       join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
 where j.id_color in ('R', 'F')
   and p.id_color = 'F';

select *
  from vw_surte_jgo
 where es_simulacion = 'SI'
   and es_urgente = 'NO';

-- resumen de piezas faltantes para produccion
select j.cod_cliente, j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, sum(p.cantidad) as cantidad
     , case
         when lag(j.cod_cliente) over (order by null) = j.cod_cliente then null
         else j.cod_cliente
       end bk
  from vw_surte_jgo j
       join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
       join vw_articulo a on p.cod_pza = a.cod_art
 where j.id_color in ('R', 'F')
   and p.id_color = 'F'
   and p.es_sao = 'NO'
   and ((j.cod_cliente = :cliente or :cliente is null) and
        (j.es_simulacion = :simulacion or :simulacion is null) and
        (j.es_urgente = :urgente or :urgente is null))
 group by j.cod_cliente, j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin
 order by cod_cliente, dsc_grupo, cod_pza;

select a.dsc_grupo, p.cod_pza, a.cod_lin
     , sum(p.cantidad) as cantidad
  from vw_surte_jgo j
       join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
       join vw_articulo a on p.cod_pza = a.cod_art
 where j.id_color in ('R', 'F')
   and p.id_color = 'F'
   and p.es_sao = 'NO'
   and ((j.es_simulacion like :p_simulacion) and
        (j.es_urgente like :p_urgente) and
        (j.cant_faltante = :p_faltante or :p_faltante is null))
 group by a.dsc_grupo, p.cod_pza, a.cod_lin
 order by dsc_grupo, cod_pza;

select *
  from vw_surte_jgo
 where cod_jgo = 'KIT MH FS 85207-1 TG';

select * from tmp_surte_jgo;

select * from tmp_surte_pza;

select *
  from exclientes
 where abreviada = 'CMOVIL';

select * from color_surtimiento;

-- VK 81200 R

-- select sum(cant_surtir)
--   from tmp_surte_jgo_manual
--  group by cod_jgo;

select * from vw_ordenes_pedido_pendiente;

select *
  from vw_surte_jgo
 where nro_pedido = 14890
   and itm_pedido = 24
 order by ranking;

select ranking, nom_cliente, nro_pedido, itm_pedido, fch_pedido, ot_numero, cod_jgo, cod_pza, valor
     , cantidad, stock_actual, stock_inicial, nom_color
  from vw_surte_pza
 where cod_pza = '300.506SR'
 order by ranking;

select case
         when lag(j.cod_cliente) over (order by null) = j.cod_cliente then null
         else j.cod_cliente
       end break
     , j.cod_cliente, j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op
     , sum(p.cantidad) as cantidad, a.cant_faltante, a.stock_requerida, a.saldo_op
     , a.consumo_anual, min(j.orden_prioridad) as min_orden_prioridad
  from vw_surte_jgo j
       join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
       join vw_articulo a on p.cod_pza = a.cod_art
 where j.id_color in ('R', 'F')
   and p.id_color = 'F'
   and p.es_sao = 'NO'
   and p.cod_pza = '300.506SR'
--    and ((j.cod_cliente = p_cliente or p_cliente is null) and
--         (j.es_simulacion like p_simulacion) and
--         (j.es_urgente like p_urgente) and
--         ((j.cant_faltante <= p_faltante or p_faltante is null) and
--          (j.valor <= p_valor or p_valor is null)))
 group by j.cod_cliente, j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op
        , a.cant_faltante, a.stock_requerida, a.saldo_op, a.consumo_anual
 order by cod_cliente, dsc_grupo, cod_pza;


select case
         when lag(j.cod_cliente) over (order by null) = j.cod_cliente then null
         else j.cod_cliente
       end break
     , j.cod_cliente, j.nom_cliente, a.id_grupo, a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op
     , sum(p.cantidad) as cantidad, a.cant_faltante, a.stock_requerida, a.saldo_op
     , a.consumo_anual, min(j.orden_prioridad) as min_orden_prioridad
  from vw_surte_jgo j
       join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
       join vw_articulo a on p.cod_pza = a.cod_art
 where j.id_color in ('R', 'F')
   and p.id_color = 'F'
   and p.es_sao = 'NO'
 group by j.cod_cliente, j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op
        , a.cant_faltante, a.stock_requerida, a.saldo_op, a.consumo_anual, a.id_grupo
 order by cod_cliente, dsc_grupo, cod_pza;

select f.art_cod_art
  from pr_for_ins f
       join articul a on f.art_cod_art = a.cod_art
 where f.formu_art_cod_art = '1179TG'
   and (a.cod_lin between '2004' and '2008'
   or a.cod_lin = '1601');


select cod_art
     , sum(saldo) as saldo_op
     , listagg(numero || '(' || estado || ', ' || cant_prog || ')', ' | ')
               within group ( order by estado, numero) as numero_op
  from vw_ordenes_curso
 where nuot_tipoot_codigo = 'PR'
 group by cod_art;


select *
  from vw_surte_jgo
 where dsc_grupo is not null;

select * from vw_surte_pza;

select *
  from articul
 where ((cod_lin between '1620' and '1634') or (cod_lin between '2010' and '2019'))
   and length(cod_lin) = 4;

select *
  from vw_articulo
 where cod_art = '380.760';

select case
         when lag(j.cod_cliente) over (order by null) = j.cod_cliente then null
         else j.cod_cliente
       end break
     , j.cod_cliente, j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op
     , sum(p.cantidad) as cantidad, a.cant_faltante, a.stock_requerida, a.saldo_op
     , a.consumo_anual, min(j.orden_prioridad) as min_orden_prioridad, a.stock
  from vw_surte_jgo j
       join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
       join vw_articulo a on p.cod_pza = a.cod_art
 where j.id_color in ('R', 'F')
   and p.id_color = 'F'
   and p.es_sao = 'NO'
   and cod_art = '380.760'
 group by j.cod_cliente, j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op
        , a.cant_faltante, a.stock_requerida, a.saldo_op, a.consumo_anual, a.stock
 order by cod_cliente, dsc_grupo, cod_pza;

select ranking, nom_cliente, nro_pedido, itm_pedido, fch_pedido, ot_numero, cod_jgo, cod_pza, valor
     , cantidad, rendimiento, stock_actual, cant_final, saldo_stock, stock_inicial, nom_color
  from vw_surte_pza
 where cod_pza = '380.503N'
 order by ranking;

select *
  from vw_surte_jgo
 where nro_pedido = 15484
   and itm_pedido = 84;

select *
  from vw_surte_pza
 where nro_pedido = 15484
   and itm_pedido = 84;

  with pedidos as (
    select nro_pedido, nom_cliente, to_char(fch_pedido, 'dd/mm/yyyy') as fch_pedido
         , min(ranking) as ranking
      from vw_surte_jgo
     group by nro_pedido, nom_cliente, fch_pedido, ranking
    )
select p.nro_pedido, p.nom_cliente, p.fch_pedido, p.ranking
  from pedidos p
 order by p.ranking;

select nro_pedido, nom_cliente, to_char(fch_pedido, 'dd/mm/yyyy') as fch_pedido
  from vw_surte_jgo
 group by nro_pedido, nom_cliente, fch_pedido, ranking
 order by nom_cliente;

select * from vw_surte_jgo;

select distinct cod_pza from vw_surte_pza order by cod_pza;

select p.ranking, p.nom_cliente, p.nro_pedido, p.itm_pedido, p.fch_pedido, p.ot_numero, p.cod_jgo
     , p.cod_pza, p.valor, p.cantidad, p.rendimiento, p.stock_actual, p.cant_final, p.saldo_stock
     , p.stock_inicial, p.nom_color as color_pza, j.nom_color as color_jgo
  from vw_surte_jgo j
       join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
--  where cod_pza = :trazabilidad.cod_pza
 order by p.ranking;

select sum(cantidad)
  from vw_surte_pza
 where cod_pza = '290.3231ALR';

select *
  from vw_surte_jgo;

-- create view vw_surte_faltante as
  with faltantes as (
    select j.nro_pedido, j.itm_pedido, j.cod_cliente, j.nom_cliente, j.cod_jgo, a.dsc_grupo
         , p.cod_pza, a.cod_lin, a.numero_op, p.cantidad, a.cant_faltante, a.stock_requerida
         , a.saldo_op, a.consumo_anual, a.stock, j.valor, j.fch_pedido
         , min(j.orden_prioridad) as min_orden_prioridad, j.ranking
         , trunc(sysdate - j.fch_pedido) as dias_atraso
      from vw_surte_jgo j
           join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
           join tmp_surte_faltante f
                on p.nro_pedido = f.nro_pedido
                  and p.itm_pedido = f.itm_pedido
                  and p.cod_pza = f.cod_pza
           join vw_articulo a on p.cod_pza = a.cod_art
     group by j.cod_cliente, j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op
            , a.cant_faltante, a.stock_requerida, a.saldo_op, a.consumo_anual, j.nro_pedido
            , j.itm_pedido, j.cod_jgo, a.stock, j.valor, j.fch_pedido, j.ranking, p.cantidad
     order by dsc_grupo, ranking, cod_cliente, cod_pza
    )
     , sao as (
    select p.cod_cliente, p.nom_cliente, s.cod_sao
      from vw_surte_pza p
           join vw_surte_sao s
                on p.nro_pedido = s.nro_pedido
                  and p.itm_pedido = s.itm_pedido
                  and p.cod_pza = s.cod_pza
     group by p.cod_cliente, p.nom_cliente, s.cod_sao
    )
select f.nro_pedido, f.itm_pedido, f.cod_cliente, f.nom_cliente, f.cod_jgo, f.dsc_grupo
     , f.cod_pza, f.cod_lin, f.numero_op, f.cantidad, f.cant_faltante, f.stock_requerida
     , f.saldo_op, f.consumo_anual, p.dsc_prioridad, f.stock, f.valor, f.fch_pedido, f.ranking
     , case when s.cod_sao is not null then '*' end as usado_en_sao, f.dias_atraso
  from faltantes f
       left join prioridad_pedidos p on f.min_orden_prioridad = p.orden
       left join sao s on f.cod_cliente = s.cod_cliente and f.cod_pza = s.cod_sao
 where f.cod_cliente = 'G001';

-- select *
--   from vw_surte_faltante
--  where nro_pedido = 14732;

select nro_pedido, itm_pedido, cod_pza, faltante, ranking, cod_cliente, nom_cliente, valor
     , fch_pedido, dias_atraso, dsc_grupo, cod_for, cod_lin, faltante_total, faltante_sin_stock
     , cantidad_op, por_emitir, consumo_anual, stock, prioridad, material, ribete, subpieza, ordenes
     , usado_en_sao
  from tmp_surte_faltante;

select cod_cliente, nom_cliente, dsc_grupo, cod_pza, cod_lin
     , ordenes, faltante_total, faltante_sin_stock, cantidad_op
     , consumo_anual, material, ribete, subpieza, prioridad, stock
     , usado_en_sao
     , sum(faltante) as faltante
     , sum(por_emitir) as por_emitir
     , sum(valor) as valor
     , min(ranking) as ranking
  from tmp_surte_faltante
 group by cod_cliente, nom_cliente, dsc_grupo, cod_pza, cod_lin
        , ordenes, faltante_total, faltante_sin_stock, cantidad_op
        , consumo_anual, material, ribete, subpieza, prioridad, stock
        , usado_en_sao;

select dsc_grupo, cod_pza, cod_lin, ordenes, faltante_total, faltante_sin_stock, cantidad_op
     , consumo_anual, material, ribete, subpieza, prioridad, stock, usado_en_sao
     , sum(faltante) as faltante
     , sum(por_emitir) as por_emitir
     , sum(valor) as valor
     , min(ranking) as ranking
  from tmp_surte_faltante
 group by dsc_grupo, cod_pza, cod_lin, ordenes, faltante_total, faltante_sin_stock, cantidad_op
        , consumo_anual, material, ribete, subpieza, prioridad, stock, usado_en_sao;

select distinct dsc_grupo
  from tmp_surte_faltante
 where dsc_grupo is not null
 order by 1;

select cod_cliente, nom_cliente, entre_90_180_dias, entre_180_360_dias, mas_360_dias
     , menos_90_dias, total, ranking
  from vw_surte_faltante_atraso;

select * from vw_surte_jgo;

select pedido, pedido_item, pais, vendedor
  from vw_ordenes_pedido_pendiente
 group by pedido, pedido_item, pais, vendedor;

select *
  from expaises
 where pais = '05';

select *
  from tablas_auxiliares
 where codigo = '....';

select *
  from tablas_auxiliares
 where tipo = 25
 order by codigo;

select *
  from extablas_expo
 where tipo = 13;

select *
  from vw_surte_jgo
 where nro_pedido = 15526;


select *
  from expedidos
 where numero = 15526;

select *
  from expedido_d
 where numero = 15526
   and nro = 30;

select *
  from pr_ot
 where abre01 = '15526'
   and numero = 890929;

select *
  from pr_ot_det
 where ot_nuot_tipoot_codigo = 'AR'
   and ot_numero = 890929
   and cant_formula - nvl(saldo, 0) > 0;

select *
  from pr_ot_impresion
 where nuot_tipoot_codigo = 'AR'
   and numero = 890929;

select *
  from pr_ot_impresion
 where numero = 890929;

select * from view_pedidos_pendientes_38;

select *
  from vw_surte_jgo
 where ((es_prioritario = :p_prioritario and :p_prioritario = 'SI')
   or ((cod_cliente = :p_cliente or :p_cliente is null) and
       (nro_pedido = :p_pedido or :p_pedido is null)));

select nro_pedido, nom_cliente
  from vw_surte_jgo
 group by nro_pedido, nom_cliente
 order by nom_cliente, nro_pedido;

select * from tmp_surte_pza;

select cantidad, faltante
  from tmp_surte_pza
 where faltante is not null;

select cod_cliente, nom_cliente, dsc_grupo, cod_pza, cod_lin
     , ordenes, faltante_total, faltante_sin_stock, cantidad_op
     , consumo_anual, material, ribete, subpieza, prioridad, stock
     , usado_en_sao
     , sum(requerida) as requerida
     , sum(faltante) as faltante
     , sum(por_emitir) as por_emitir
     , sum(valor) as valor
     , min(ranking) as ranking
  from tmp_surte_faltante
 group by cod_cliente, nom_cliente, dsc_grupo, cod_pza, cod_lin
        , ordenes, faltante_total, faltante_sin_stock, cantidad_op
        , consumo_anual, material, ribete, subpieza, prioridad, stock
        , usado_en_sao;

select *
  from vw_surte_pza
 where cod_pza = '450.216'
   and nro_pedido = 15678
   and cod_jgo = 'KIT AUT FS 3688 MX5 GR';

select *
  from tmp_surte_pza
 where cod_pza = '450.216'
   and nro_pedido = 15678;

select *
  from tmp_surte_jgo
 where nom_cliente = 'EyE';

select *
  from exclientes
 where cod_cliente = '990655';

select *
  from pr_ot_impresion
 where nuot_tipoot_codigo = 'AR'
   and numero = 823061;

select *
  from pr_ot
 where nuot_tipoot_codigo = 'PP'
   and numero = 71538205;

select *
  from vw_articulo
 where cod_art = '400.1741VIT';

select cod_art, cant_faltante, stock_requerida, stock, consumo_anual, saldo_op, numero_op
  from vw_articulo
 where cod_art = '180.654FIB';
