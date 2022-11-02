drop table reserva_surtimiento cascade constraints;

create table pevisa.reserva_surtimiento (
  pedido_nro number(8),
  pedido_itm number(4),
  ot_tpo     varchar2(2),
  ot_ser     varchar2(4),
  ot_nro     number(8),
  estado     number(1)
)
  tablespace pevisad;


create unique index pevisa.idx_reserva_surtimiento
  on pevisa.reserva_surtimiento(pedido_nro, pedido_itm)
  tablespace pevisax;

create index pevisa.idx_reserva_surtimiento_ot
  on pevisa.reserva_surtimiento(ot_tpo, ot_ser, ot_nro)
  tablespace pevisax;


create or replace public synonym reserva_surtimiento for pevisa.reserva_surtimiento;


alter table pevisa.reserva_surtimiento
  add (
    constraint pk_reserva_surtimiento
      primary key (pedido_nro, pedido_itm)
        using index pevisa.idx_reserva_surtimiento
        enable validate
    );


grant delete, insert, select, update on pevisa.reserva_surtimiento to sig_roles_invitado;
