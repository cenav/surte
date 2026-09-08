create table pevisa.pedido_prioridad_trabajo (
  id_pedido            number(8),
  id_prioridad_trabajo number(3)
)
  tablespace pevisad;


create unique index pevisa.idx_pedido_prioridad_trabajo
  on pevisa.pedido_prioridad_trabajo(id_pedido) tablespace pevisax;


create
  or replace public synonym pedido_prioridad_trabajo for pevisa.pedido_prioridad_trabajo;


alter table pevisa.pedido_prioridad_trabajo
  add (
    constraint pk_pedido_prioridad_trabajo
      primary key (id_pedido)
        using index pevisa.idx_pedido_prioridad_trabajo
        enable validate
    );

alter table pedido_prioridad_trabajo
  add constraint fk_pedido_prioridad_trabajo foreign key (id_prioridad_trabajo)
    references prioridad_trabajo(id_prioridad_trabajo);



grant delete, insert, select, update on pevisa.pedido_prioridad_trabajo to sig_roles_invitado;