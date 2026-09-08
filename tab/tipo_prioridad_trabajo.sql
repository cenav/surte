create table pevisa.prioridad_trabajo (
  id_prioridad_trabajo  number(3),
  dsc_prioridad_trabajo varchar2(50) not null
)
  tablespace pevisad;


create unique index pevisa.idx_prioridad_trabajo
  on pevisa.prioridad_trabajo(id_prioridad_trabajo) tablespace pevisax;


create or replace public synonym prioridad_trabajo for pevisa.prioridad_trabajo;


alter table pevisa.prioridad_trabajo
  add (
    constraint pk_prioridad_trabajo
      primary key (id_prioridad_trabajo)
        using index pevisa.idx_prioridad_trabajo
        enable validate
    );


grant delete, insert, select, update on pevisa.prioridad_trabajo to sig_roles_invitado;
