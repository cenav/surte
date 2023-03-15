-- alter table pevisa.tmp_surte_pza_manual
--   drop primary key cascade;
-- 
-- drop table pevisa.tmp_surte_pza_manual cascade constraints;
-- 
create global temporary table pevisa.tmp_surte_pza_manual (
  nro_pedido      number(8),
  itm_pedido      number(4),
  cod_pza         varchar2(30 byte),
  cantidad        number(12, 4),
  rendimiento     number(12, 4),
  stock_actual    number(12, 4),
  cant_final      number(12, 4),
  linea           varchar2(4 byte),
  es_importado    number(1),
  tiene_stock_itm number(1),
  es_sao          number(1),
  es_armado       number(1),
  es_reserva      number(1),
  id_color        varchar2(1 byte)
)
  on commit preserve rows
  nocache;


create unique index pevisa.pk_tmp_surte_pza_manual on pevisa.tmp_surte_pza_manual
  (nro_pedido, itm_pedido, cod_pza);

create or replace public synonym tmp_surte_pza_manual for pevisa.tmp_surte_pza_manual;


alter table pevisa.tmp_surte_pza_manual
  add (
    constraint pk_tmp_surte_pza_manual
      primary key
        (nro_pedido, itm_pedido, cod_pza)
        using index pevisa.pk_tmp_surte_pza_manual
        enable validate);

grant delete, insert, select, update on pevisa.tmp_surte_pza_manual to sig_roles_invitado;
