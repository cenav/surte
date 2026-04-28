-- valores por defecto actuales
begin
  surte.por_item(
      p_pais => null
    , p_vendedor => null
    , p_dias => null
    , p_empaque => null
    , p_es_juego => null
    , p_orden => 2 --> [1] items mayor valor [2] por artículos agrupados
    , p_es_nuevo => null
  );
end;

-- carga tablas
begin
  api_almacen.carga_stock('03,05');
  api_almacen.carga_stock_oa();
  surte_reporte.carga_embalaje();
end;


-- data stock
begin
    l_stock_03 := api_almacen.stock(r.cod_pza);
    l_stock_impreso := nvl(api_almacen.stock_oa(r.cod_pza), 0);
    l_embala := surte_reporte.embalaje(r.cod_jgo);
end;


select p.ranking, p.nom_cliente, p.nro_pedido, to_char(p.fch_pedido, 'dd/mm/yyyy') as fch_pedido, p.ot_tipo
     , p.ot_numero, j.cant_prog as ot_cant, p.cod_jgo, p.ot_estado, p.valor, p.tiene_stock_ot, p.cod_pza, p.cantidad, cant_final
     , p.saldo_stock, p.faltante, p.linea, p.tiene_stock_itm, p.es_importado, p.impreso
     , a.dsc_grupo as grupo, stock_inicial, p.sobrante, j.nom_color
     , a.cant_faltante, a.saldo_op, a.numero_op, a.stock, a.stock_requerida, consumo_anual
     , p.nom_color as nom_color_pza
     , api_almacen.stock(p.cod_pza) as stock_03
     , nvl(api_almacen.stock_oa(p.cod_pza), 0) as stock_impreso
     , greatest(api_almacen.stock(p.cod_pza) - nvl(api_almacen.stock_oa(p.cod_pza), 0), 0) as stock_sin_oa_impresa
--     ,surte_reporte.embalaje(p.cod_jgo).tipo_embalaje
--     ,surte_reporte.embalaje(p.cod_jgo).rendimiento
--     ,surte_reporte.embalaje(p.cod_jgo).stock_06
--     ,surte_reporte.embalaje(p.cod_jgo).stock_orden_impresa as stock_sin_orden_impresa
--     ,surte_reporte.embalaje(p.cod_jgo).stock_f0
--     ,surte_reporte.embalaje(p.cod_jgo).consumo_anual
  from vw_surte_jgo j
     , vw_surte_pza p
     , vw_articulo a
 where j.nro_pedido = p.nro_pedido
   and j.itm_pedido = p.itm_pedido
   and p.cod_pza = a.cod_art
   and ((:color_header = 'C' and :color_detail = 'C' and j.id_color = 'C' and j.es_armar = 'NO') or
        (:color_header = 'C' and :color_detail = 'P' and j.id_color = 'P' and j.es_armar = 'NO') or
        (:color_header = 'C' and :color_detail = 'A' and j.id_color in ('C', 'P') and j.es_armar = 'SI') or
        (:color_header = 'C' and :color_detail = 'CP' and j.id_color in ('C','P') and j.es_armar = 'NO') or
        (:color_header = 'C' and :color_detail is null and j.id_color in ('C', 'P')) or
        (:color_header = 'F' and :color_detail = 'R' and j.id_color = 'R') or
        (:color_header = 'F' and :color_detail = 'F' and j.id_color = 'F') or
        (:color_header = 'F' and :color_detail = 'U' and j.es_urgente = 'SI') or
        (:color_header = 'F' and :color_detail is null and j.id_color in ('R', 'F')) or
        (:color_header = 'I' and :color_detail is null and j.id_color = 'I') or
        (:color_header is null and :color_detail is null)) and
   (j.cod_cliente = :cliente or :cliente is null) and
   (j.nro_pedido = :pedido or :pedido is null) and
   (j.es_prioritario = :prioritario or :prioritario = 'SI')
 order by p.ranking;


