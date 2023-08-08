create table pevisa.param_surte (
  id_param             number(3),
  valor_item           number(10, 2),
  valor_partir         number(10, 2),
  prioritario          number(1),
  dias_impreso_bien    number(5),
  dias_impreso_mal     number(6),
  max_faltante_reserva number(3),
  min_valor_reserva    number(10, 2)
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

insert into pevisa.param_surte ( id_param, valor_item, valor_partir, prioritario, dias_impreso_bien
                               , dias_impreso_mal, max_faltante_reserva, min_valor_reserva)
values (1, 1000.00, 50.00, 1, 3, 5, 2, 3000.00);
