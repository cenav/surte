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
     , case when lag(j.cod_cliente) over (order by null) = j.cod_cliente then null else j.cod_cliente end bk
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

select * from tmp_surte_jgo;

begin
  surte.por_item();
end;

