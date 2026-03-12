begin
  surte.por_item();
end;

-- valores por defecto actuales
begin
  surte.por_item(
      p_pais => null
    , p_vendedor => null
    , p_dias => null
    , p_empaque => null
    , p_es_juego => null
    , p_orden => 2 --> por artículos agrupados
    , p_es_nuevo => null
  );
end;

begin
  surte_reporte_faltante.guarda_detalle();
end;

select *
  from tmp_surte_pza
 where nro_pedido = 16356;

select *
  from expedidos
 where numero = 16356;

select *
  from color_surtimiento
 order by orden;

select *
  from almacenes
 where cod_alm = '06';

select *
  from vw_surte_jgo
 where nro_pedido = 17103
   and itm_pedido = 8;

select *
  from vw_surte_pza
 where nro_pedido = 17045
   and itm_pedido = 156;

select * from tmp_surte_pza;

select *
  from pevisa.vw_surte_jgo
 where id_color = 'E';

select *
  from pevisa.vw_surte_pza
 where id_color = 'E';


select p.ranking, p.nom_cliente, p.nro_pedido, p.itm_pedido, p.fch_pedido, p.ot_numero, p.cod_jgo
     , p.cod_pza, p.valor, p.cantidad, p.rendimiento, p.stock_actual, p.cant_final, p.saldo_stock
     , p.stock_inicial, p.nom_color as color_pza, j.nom_color as color_jgo, p.colorindex
  from vw_surte_jgo j
     , vw_surte_pza p
 where j.nro_pedido = p.nro_pedido
   and j.itm_pedido = p.itm_pedido
   and cod_pza = 'DUR 300.570'
 order by p.ranking;


select *
  from color_surtimiento
 where nom_color = 'ORANGE';


select *
  from vw_surte_pza
 where cod_pza = 'DUR 300.570';