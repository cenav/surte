alter table pevisa.tmp_surte_sao
  drop primary key cascade;

drop table pevisa.tmp_surte_sao cascade constraints;

create global temporary table pevisa.tmp_surte_sao (
  nro_pedido      number(8),
  itm_pedido      number(4),
  cod_pza         varchar2(30),
  cod_sao         varchar2(30),
  cantidad        number(12, 4),
  rendimiento     number(12, 4),
  stock_inicial   number(12, 4),
  stock_actual    number(12, 4),
  saldo_stock     number(12, 4),
  sobrante        number(12, 4),
  faltante        number(12, 4),
  cant_final      number(12, 4),
  es_importado    number(1),
  tiene_stock_itm number(1),
  id_color        varchar2(1)
)
  on commit preserve rows;

create or replace public synonym tmp_surte_sao for pevisa.tmp_surte_sao;

alter table pevisa.tmp_surte_sao
  add (
    constraint pk_tmp_surte_sao
      primary key (nro_pedido, itm_pedido, cod_pza, cod_sao)
        enable validate
    );

grant delete, insert, select, update on pevisa.tmp_surte_sao to sig_roles_invitado;
