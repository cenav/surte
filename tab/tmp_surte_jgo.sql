alter table pevisa.tmp_surte_jgo
  drop primary key cascade;

drop table pevisa.tmp_surte_jgo cascade constraints;

create global temporary table pevisa.tmp_surte_jgo (
  nro_pedido      number(8),
  itm_pedido      number(4),
  cod_cliente     varchar2(30 byte),
  nom_cliente     varchar2(100 byte),
  fch_pedido      date,
  ot_tipo         varchar2(2 byte),
  ot_serie        varchar2(4 byte),
  ot_numero       number(8),
  ot_estado       varchar2(2 byte),
  cod_jgo         varchar2(30 byte),
  cant_prog       number(10, 2),
  preuni          number(10, 2),
  valor           number(10, 2),
  valor_surtir    number(10, 2),
  valor_simulado  number(10, 2),
  es_juego        number(1),
  tiene_importado number(1),
  impreso         varchar2(2 byte),
  fch_impresion   date,
  partir_ot       number(1),
  cant_partir     number(16, 4),
  tiene_stock_ot  varchar2(2 byte),
  es_prioritario  number(1),
  es_reserva      number(1),
  es_urgente      number(1),
  es_simulacion   number(1),
  es_armar        number(1),
  cant_faltante   number(8),
  id_color        varchar2(1 byte),
  ranking         number(10),
  imprimir        number(1)
)
  on commit preserve rows
  nocache;


create unique index pevisa.pk_tmp_surte_jgo on pevisa.tmp_surte_jgo
  (nro_pedido, itm_pedido);

create or replace public synonym tmp_surte_jgo for pevisa.tmp_surte_jgo;


alter table pevisa.tmp_surte_jgo
  add (
    constraint pk_tmp_surte_jgo
      primary key
        (nro_pedido, itm_pedido)
        using index pevisa.pk_tmp_surte_jgo
        enable validate);

grant delete, insert, select, update on pevisa.tmp_surte_jgo to sig_roles_invitado;
