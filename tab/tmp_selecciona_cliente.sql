create global temporary table pevisa.tmp_selecciona_cliente (
  cod_cliente varchar2(30 byte)
)
  on commit preserve rows
  nocache;


create or replace public synonym tmp_selecciona_cliente for pevisa.tmp_selecciona_cliente;

select * from tmp_selecciona_cliente;


select *
  from vw_ordenes_pedido_pendiente v
 where (exists(select * from tmp_selecciona_cliente t where v.cod_cliente = t.cod_cliente)
   and (
         select count(cod_cliente) over ( )
           from tmp_selecciona_cliente
         ) > 0);

select *
  from vw_ordenes_pedido_pendiente v
 where (exists(select * from tmp_selecciona_cliente t where v.cod_cliente = t.cod_cliente) or
        not exists(select * from tmp_selecciona_cliente));

select cod_cliente, nombre
  from exclientes
 where estado = '0'
 union
select cod_grupo, dsc_grupo
  from grupo_cliente
 order by 2;

select distinct estado from exclientes;