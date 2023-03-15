-- alter table pevisa.tmp_surte_jgo_manual
--   drop primary key cascade;
--
-- drop table pevisa.tmp_surte_jgo_manual cascade constraints;
--
create global temporary table pevisa.tmp_surte_jgo_manual (
  nro_pedido   number(8),
  itm_pedido   number(4),
  cod_cliente  varchar2(30 byte),
  nom_cliente  varchar2(100 byte),
  fch_pedido   date,
  ot_tipo      varchar2(2 byte),
  ot_serie     varchar2(4 byte),
  ot_numero    number(8),
  cod_jgo      varchar2(30 byte),
  cant_prog    number(10, 2),
  cant_surtir  number(16, 4),
  valor        number(10, 2),
  valor_surtir number(10, 2),
  id_color     varchar2(1 byte),
  ranking      number(10)
)
  on commit preserve rows
  nocache;


create unique index pevisa.pk_tmp_surte_jgo_manual on pevisa.tmp_surte_jgo_manual
  (nro_pedido, itm_pedido);

create or replace public synonym tmp_surte_jgo_manual for pevisa.tmp_surte_jgo_manual;


alter table pevisa.tmp_surte_jgo_manual
  add (
    constraint pk_tmp_surte_jgo_manual
      primary key
        (nro_pedido, itm_pedido)
        using index pevisa.pk_tmp_surte_jgo_manual
        enable validate);

grant delete, insert, select, update on pevisa.tmp_surte_jgo_manual to sig_roles_invitado;
