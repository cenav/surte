create table orden_impresa_surtimiento (
  ot_tpo  varchar2(4) not null,
  ot_ser  varchar2(4) not null,
  ot_nro  number(8)   not null,
  usuario varchar2(30),
  fch_ins date,
  fch_upd date
)
/

create unique index idx_orden_impresa_surtimiento
  on orden_impresa_surtimiento(ot_tpo, ot_ser, ot_nro)
/

alter table orden_impresa_surtimiento
  add constraint pk_orden_impresa_surtimiento
    primary key (ot_tpo, ot_ser, ot_nro)
/

