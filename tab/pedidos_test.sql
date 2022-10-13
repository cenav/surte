create table pevisa.pedidos_test (
  numero number(8),
  item   number(4)
)
  tablespace pevisad;


create unique index pevisa.idx_pedidos_test
  on pevisa.pedidos_test(numero, item)
  tablespace pevisax;


alter table pevisa.pedidos_test
  add (
    constraint pk_pedidos_test
      primary key (numero, item)
        using index pevisa.idx_pedidos_test
        enable validate
    );


grant delete, insert, select, update on pevisa.pedidos_test to sig_roles_invitado;