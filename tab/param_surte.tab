create table pevisa.param_surte (
  id_param     number(3),
  valor_item   number(10, 2),
  valor_partir number(10, 2),
  prioritario  number(1)
)
  tablespace pevisad;


create unique index pevisa.idx_param_surte
  on pevisa.param_surte(id_param)
  tablespace pevisax;


create or replace public synonym param_surte for pevisa.param_surte;


alter table pevisa.param_surte
  add (
    constraint pk_param_surte
      primary key (id_param)
        using index pevisa.idx_param_surte
        enable validate
    );


grant delete, insert, select, update on pevisa.param_surte to sig_roles_invitado;

select * from param_surte;
