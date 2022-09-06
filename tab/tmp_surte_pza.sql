create global temporary table pevisa.tmp_surte_pza (
  nro_pedido      number(8),
  itm_pedido      number(3),
  cod_pza         varchar2(30),
  cantidad        number(12, 4),
  rendimiento     number(12, 4),
  stock_inicial   number(12, 4),
  stock_actual    number(12, 4),
  saldo_stock     number(12, 4),
  sobrante        number(12, 4),
  faltante        number(12, 4),
  cant_final      number(12, 4),
  linea           varchar2(4),
  es_importado    number(1),
  tiene_stock_itm varchar2(2)
)
  on commit preserve rows;

create or replace public synonym tmp_surte_pza for pevisa.tmp_surte_pza;

alter table pevisa.tmp_surte_pza
  add (
    constraint pk_tmp_surte_pza
      primary key (nro_pedido, itm_pedido, cod_pza)
        enable validate
    );

grant delete, insert, select, update on pevisa.tmp_surte_pza to sig_roles_invitado;
