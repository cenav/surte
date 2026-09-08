select *
  from pr_ot_impresion
 where nuot_tipoot_codigo = 'AR'
   and numero = 1191261;

select *
  from pr_ot
 where nuot_tipoot_codigo = 'AR'
   and numero = 1191261;

select *
  from pr_ot_impresion
 where nuot_tipoot_codigo = 'AR'
   and numero = 1191261;


select *
  from pr_estados
 order by estado;


select d.cod_alm, d.cod_art
     , sum(decode(d.ing_sal, 'S', (d.cantidad * -1), d.cantidad)) as stock
  from kardex_d d
 where d.estado <> '9'
   and d.cod_alm = '03'
   and d.cod_art in ('200.2690')
having sum(decode(d.ing_sal, 'S', (d.cantidad * -1), d.cantidad)) > 0
 group by d.cod_alm, d.cod_art
 order by cod_alm, cod_art;


select *
  from articul
 where cod_art = 'KIT MH FS 1021-07 TG-0702436';


select *
  from pcformulas
 where cod_art = 'KIT MH FS 1021-07 TG-0702436'
   and cod_for = '200.2690';


select *
  from pcformulas
 where cod_art = 'KIT MH HS 1021-07 TG'
   and cod_for = '200.2690';


select *
  from vw_ordenes_impresas_piezas
 where nuot_tipoot_codigo = 'AR'
   and numero = 1191261;


  with impresion
    as (
      select nuot_tipoot_codigo, nuot_serie, numero, max(fecha) as fch_impresion
        from pr_ot_impresion
       where nuot_tipoot_codigo = 'AR'
       group by nuot_tipoot_codigo, nuot_serie, numero
      )
     , ordenes
    as (
      select h.abre01 as pedido, h.per_env as pedido_item, h.nuot_tipoot_codigo, h.nuot_serie
           , h.numero, h.fecha, h.estado, h.destino, h.formu_art_cod_art, h.cant_prog
           , case g.grupo when 1 then 1 else 0 end as es_juego, i.fch_impresion
           , round(sysdate - i.fch_impresion) as dias_impreso, d.art_cod_art, d.cant_formula
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
--          and h.estado = 1
      )
     , pedidos
    as ( -- exportacion
      select p.numero as pedido, d.nro as pedido_item, p.cod_cliente, p.nombre
           , p.fecha as fch_pedido, o.numero, o.nuot_serie, o.nuot_tipoot_codigo, o.fecha, o.estado
           , o.destino, o.cant_prog, o.dias_impreso, o.formu_art_cod_art, o.es_juego
           , o.fch_impresion, d.preuni, a.codigo_aux as pais, p.zona as vendedor, p.empaque
           , round(d.canti * d.preuni, 2) as valor, o.art_cod_art, o.cant_formula
        from expedidos p
             join expedido_d d on p.numero = d.numero
             join ordenes o
                  on o.pedido = p.numero
                    and o.pedido_item = d.nro
                    and o.destino = '1'
             left join expaises a on p.pais = a.pais
       union all
 -- nacional
      select p.numero as pedido, d.nro as pedido_item, p.cod_cliente, p.nombre
           , p.fecha as fch_pedido, o.numero, o.nuot_serie, o.nuot_tipoot_codigo, o.fecha, o.estado
           , o.destino, o.cant_prog, o.dias_impreso, o.formu_art_cod_art, o.es_juego
           , o.fch_impresion, d.preuni, p.pais, 'PE' as vendedor, p.empaque
           , round(d.canti * d.preuni, 2) as valor, o.art_cod_art, o.cant_formula
        from expednac p
             join expednac_d d on p.numero = d.numero
             join ordenes o
                  on o.pedido = p.numero
                    and o.pedido_item = d.nro
                    and o.destino = '2'
      )
     , detalle as (
      select nvl(gcc.cod_grupo, p.cod_cliente) as cod_cliente, nvl(gc.dsc_grupo, p.nombre) as nombre
           , p.fch_pedido, p.pedido, p.pedido_item, p.nuot_tipoot_codigo, p.nuot_serie, p.numero
           , p.fecha
           , p.cant_prog, p.estado, p.pais, p.vendedor, p.empaque, p.formu_art_cod_art, p.valor
           , p.dias_impreso, p.fch_impresion, p.es_juego
           , nvl(gc.es_prioritario, 0) as es_prioritario
           , p.art_cod_art, p.cant_formula
        from pedidos p
             left join grupo_cliente_cliente gcc
                       on p.cod_cliente = gcc.cod_cliente
             left join grupo_cliente gc on gc.cod_grupo = gcc.cod_grupo
       union
      select cod_cliente, nombre, fch_pedido, pedido, pedido_item, nuot_tipoot_codigo, nuot_serie
           , numero
           , fecha, cant_prog, estado, pais, vendedor, empaque, formu_art_cod_art, valor
           , dias_impreso
           , fch_impresion, es_juego, es_prioritario, art_cod_art, cant_formula
        from ordenes_piezas_impresas_saos
      )
select d.cod_cliente, d.nombre, d.fch_pedido, d.pedido, d.pedido_item, d.nuot_tipoot_codigo
     , d.nuot_serie, d.numero, d.fecha, d.cant_prog, d.estado, d.pais, d.vendedor, d.empaque
     , d.formu_art_cod_art, d.valor, d.dias_impreso, d.fch_impresion, d.es_juego, d.es_prioritario
     , d.art_cod_art, d.cant_formula
  from detalle d
 where d.nuot_tipoot_codigo = 'AR'
   and d.numero = 1191261;
