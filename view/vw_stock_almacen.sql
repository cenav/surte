create or replace view vw_stock_almacen as
select cod_art, sum(stock) as stock
  from almacen
 where cod_alm in ('03', '05', '77', '16', '06')
 group by cod_art