select s.nom_color, j.ranking, j.nom_cliente, j.cod_cliente, j.nro_pedido, j.itm_pedido
     , j.fch_pedido, j.ot_numero, p.cantidad as ot_cantidad, j.cod_jgo as formula
     , j.valor, j.ot_estado, s.id_color, j.es_armar, j.es_urgente, j.es_prioritario
     , a1.dsc_grupo as grupo_1, p.cod_pza as articulo_1, a1.cod_lin as linea_1, a1.stock as stock_1
     , a2.dsc_grupo as grupo_2, s.cod_sao as articulo_2, a2.cod_lin as linea_2, a2.stock as stock_2
     , s.cantidad as cant_requerida
  from vw_surte_jgo j
       join vw_surte_pza p
            on j.nro_pedido = p.nro_pedido
              and j.itm_pedido = p.itm_pedido
       join vw_surte_sao s
            on p.nro_pedido = s.nro_pedido
              and p.itm_pedido = s.itm_pedido
              and p.cod_pza = s.cod_pza
       join vw_articulo a1 on s.cod_pza = a1.cod_art
       join vw_articulo a2 on s.cod_sao = a2.cod_art
 order by a1.dsc_grupo, ranking, cod_cliente
