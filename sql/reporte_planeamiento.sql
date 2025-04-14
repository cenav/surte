begin
  surte.por_item();
end;


-- piezas
select p.ranking, p.nom_cliente, p.nro_pedido, to_char(p.fch_pedido, 'dd/mm/yyyy') as fch_pedido, p.ot_tipo
     , p.ot_serie, p.ot_numero, p.cod_jgo, p.ot_estado, p.valor, p.tiene_stock_ot, p.cod_pza, p.cantidad, cant_final
     , p.saldo_stock, p.faltante, p.linea, p.tiene_stock_itm, p.es_importado, p.impreso
     , a.dsc_grupo as grupo, stock_inicial, p.sobrante, j.nom_color, j.cant_prog
     , a.cant_faltante, a.saldo_op, a.numero_op, a.stock, a.stock_requerida, consumo_anual
     , surte_util.material(p.cod_pza) as material
     , surte_util.ribete(p.cod_pza) as  ribete
     , surte_util.subpieza(p.cod_pza) as subpieza
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