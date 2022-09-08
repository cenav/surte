alter table pevisa.tmp_surte_jgo
  drop primary key cascade;

drop table pevisa.tmp_surte_jgo cascade constraints;

create global temporary table pevisa.tmp_surte_jgo (
  nro_pedido      number(8),
  itm_pedido      number(4),
  cod_cliente     varchar2(30),
  nom_cliente     varchar2(100),
  fch_pedido      date,
  ot_tipo         varchar2(2),
  ot_serie        varchar2(4),
  ot_numero       number(8),
  ot_estado       varchar2(2),
  cod_jgo         varchar2(30),
  preuni          number(10, 2),
  valor           number(10, 2),
  valor_surtir    number(10, 2),
  es_juego        number(1),
  tiene_importado number(1),
  impreso         varchar2(2),
  fch_impresion   date,
  partir_ot       number(1),
  cant_partir     number(16, 4),
  tiene_stock_ot  varchar2(2),
  es_prioritario  number(1),
  ranking         number(10)
)
  on commit preserve rows;

create or replace public synonym tmp_surte_jgo for pevisa.tmp_surte_jgo;

alter table pevisa.tmp_surte_jgo
  add (
    constraint pk_tmp_surte_jgo
      primary key (nro_pedido, itm_pedido)
        enable validate
    );


grant delete, insert, select, update on pevisa.tmp_surte_jgo to sig_roles_invitado;