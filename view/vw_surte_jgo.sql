create or replace view vw_surte_jgo as
select j.ranking, j.cod_cliente, j.nom_cliente, j.nro_pedido, j.itm_pedido, j.fch_pedido, j.ot_tipo
     , j.ot_serie, j.ot_numero, j.ot_estado, j.cod_jgo, j.valor, j.valor_surtir, j.cant_partir
     , case j.partir_ot when 0 then 'NO' when 1 then 'SI' end as se_puede_partir
     , case j.es_juego when 0 then 'NO' when 1 then 'SI' end as es_juego
     , case j.tiene_importado when 0 then 'NO' when 1 then 'SI' end as tiene_importado
     , case j.es_prioritario when 0 then 'NO' when 1 then 'SI' end as es_prioritario, j.tiene_stock_ot
     , j.impreso, j.fch_impresion
     , count(*) as piezas_distintas
  from tmp_surte_jgo j
 group by j.ranking, j.cod_cliente, j.nom_cliente, j.nro_pedido, j.itm_pedido
        , j.ot_tipo, j.ot_serie, j.ot_numero, j.ot_estado, j.cod_jgo
        , j.valor, j.es_juego, j.tiene_importado, j.tiene_stock_ot, j.impreso
        , j.fch_impresion, j.fch_pedido, j.valor_surtir, j.partir_ot, j.cant_partir, j.es_prioritario
 order by j.ranking
/

