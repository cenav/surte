create global temporary table pevisa.tmp_selecciona_articulo (
  cod_art varchar2(30 byte)
)
  on commit preserve rows
  nocache;


create or replace public synonym tmp_selecciona_articulo for pevisa.tmp_selecciona_articulo;

select * from pevisa.tmp_selecciona_articulo;