create or replace view vw_surte_sao as
select s.nro_pedido, s.itm_pedido, s.cod_pza, s.cod_sao, s.cantidad, s.rendimiento
     , s.stock_inicial, s.stock_actual, s.saldo_stock, s.sobrante, s.faltante, s.cant_final
     , case s.es_importado when 0 then 'NO' when 1 then 'SI' end as es_importado
     , case s.tiene_stock_itm when 0 then 'NO' when 1 then 'SI' end as tiene_stock_itm
     , s.id_color, c.dsc_color, c.nom_color, c.colorindex, c.orden
  from tmp_surte_sao s
       left join color_surtimiento c on s.id_color = c.id_color;

create public synonym vw_surte_sao for pevisa.vw_surte_sao;