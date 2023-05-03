drop table pevisa.tmp_surte_faltante cascade constraints;

create global temporary table pevisa.tmp_surte_faltante (
  nro_pedido         number(8),
  itm_pedido         number(4),
  cod_pza            varchar2(30),
  requerida          number,
  faltante           number,
  ranking            number,
  cod_cliente        varchar2(100),
  nom_cliente        varchar2(100),
  valor              number,
  fch_pedido         date,
  dias_atraso        number,
  dsc_grupo          varchar2(100),
  cod_for            varchar2(100),
  cod_lin            varchar2(100),
  faltante_total     number,
  faltante_sin_stock number,
  cantidad_op        number,
  por_emitir         number,
  consumo_anual      number,
  stock              number,
  prioridad          varchar2(100),
  material           varchar2(4000),
  ribete             varchar2(4000),
  subpieza           varchar2(4000),
  ordenes            varchar2(4000),
  usado_en_sao       varchar2(100)
)
  on commit preserve rows
  nocache;

create index pevisa.idx_tmp_surte_faltante_pedido on pevisa.tmp_surte_faltante(nro_pedido);

create index pevisa.idx_tmp_surte_faltante_pza on pevisa.tmp_surte_faltante(cod_pza);

create index pevisa.idx_tmp_surte_faltante_grupo on pevisa.tmp_surte_faltante(dsc_grupo);

create index pevisa.idx_tmp_surte_faltante_cliente on pevisa.tmp_surte_faltante(cod_cliente);

create or replace public synonym tmp_surte_faltante for pevisa.tmp_surte_faltante;

grant delete, insert, select, update on pevisa.tmp_surte_faltante to sig_roles_invitado;
