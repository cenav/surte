create or replace view vw_ordenes_impresas_pendientes as
select cod_cliente, nombre, fch_pedido, pedido, pedido_item, numero, estado, pais, vendedor, empaque
     , formu_art_cod_art, valor, dias_impreso, fch_impresion, es_juego, es_prioritario
  from vw_ordenes_impresas_piezas
 group by cod_cliente, nombre, fch_pedido, pedido, pedido_item, numero, estado, pais, vendedor, empaque
        , formu_art_cod_art, valor, dias_impreso, fch_impresion, es_juego, es_prioritario
 order by dias_impreso desc, valor desc;

create public synonym vw_ordenes_impresas_pendientes for pevisa.vw_ordenes_impresas_pendientes;