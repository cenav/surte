create or replace view vw_surte_jgo as
select j.ranking, j.cod_cliente, j.nom_cliente, j.nro_pedido, j.itm_pedido, j.fch_pedido, j.ot_tipo
     , j.ot_serie, j.ot_numero, j.ot_estado, j.cod_jgo, j.valor, j.valor_surtir, j.valor_simulado
     , j.cant_partir, j.cant_prog, j.preuni
     , case j.partir_ot when 0 then 'NO' when 1 then 'SI' end as se_puede_partir
     , case j.es_juego when 0 then 'NO' when 1 then 'SI' end as es_juego
     , case j.tiene_importado when 0 then 'NO' when 1 then 'SI' end as tiene_importado
     , case j.es_prioritario when 0 then 'NO' when 1 then 'SI' end as es_prioritario
     , case j.es_urgente when 0 then 'NO' when 1 then 'SI' end as es_urgente
     , case j.es_reserva when 0 then 'NO' when 1 then 'SI' end as es_reservado
     , case j.es_simulacion when 0 then 'NO' when 1 then 'SI' end as es_simulacion
     , j.tiene_stock_ot, j.impreso, j.fch_impresion, j.id_color, c.dsc_color, c.nom_color, c.colorindex
     , g.id_grupo, g.dsc_grupo
  from tmp_surte_jgo j
       left join color_surtimiento c on j.id_color = c.id_color
       left join vw_articulo_grupo g on j.cod_jgo = g.cod_art
 order by j.ranking
/

create public synonym vw_surte_jgo for pevisa.vw_surte_jgo;
