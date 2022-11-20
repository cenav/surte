create or replace view vw_surte_pza as
select j.ranking, j.cod_cliente, j.nom_cliente, p.nro_pedido, p.itm_pedido, j.fch_pedido, j.ot_tipo
     , j.ot_serie, j.ot_numero, j.ot_estado, j.cod_jgo, j.valor, j.es_juego, j.tiene_importado
     , j.impreso, j.fch_impresion, j.tiene_stock_ot, p.cod_pza, p.cantidad, p.cant_final
     , p.stock_inicial, p.stock_actual, p.saldo_stock, p.sobrante, p.faltante, p.linea
     , p.rendimiento
     , case j.partir_ot when 0 then 'NO' when 1 then 'SI' end as se_puede_partir
     , case p.es_importado when 0 then 'NO' when 1 then 'SI' end as es_importado
     , case p.tiene_stock_itm when 0 then 'NO' when 1 then 'SI' end as tiene_stock_itm
     , case p.es_sao when 0 then 'NO' when 1 then 'SI' end as es_sao
     , case p.es_armado when 0 then 'NO' when 1 then 'SI' end as es_armado
     , p.id_color, c.dsc_color, c.nom_color, c.colorindex, c.orden
  from tmp_surte_jgo j
       join tmp_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
       left join color_surtimiento c on p.id_color = c.id_color;
/

create public synonym vw_surte_pza for pevisa.vw_surte_pza;
