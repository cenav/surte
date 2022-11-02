alter table pevisa.color_surtimiento
  drop primary key cascade;

drop table pevisa.color_surtimiento cascade constraints;

create table pevisa.color_surtimiento (
  id_color   varchar2(1),
  dsc_color  varchar2(50) not null,
  nom_color  varchar2(50) not null,
  colorindex number(3)    not null,
  peso       number(3)    not null,
  orden      number(3)    not null
)
  tablespace pevisad;


create unique index pevisa.idx_color_surtimiento
  on pevisa.color_surtimiento(id_color)
  tablespace pevisax;


create or replace public synonym color_surtimiento for pevisa.color_surtimiento;


alter table pevisa.color_surtimiento
  add (
    constraint pk_color_surtimiento
      primary key (id_color)
        using index pevisa.idx_color_surtimiento
        enable validate
    );


grant delete, insert, select, update on pevisa.color_surtimiento to sig_roles_invitado;


insert into color_surtimiento values ('C', 'COMPLETO', 'BLUE', 5, 1, 7);
insert into color_surtimiento values ('A', 'ARMAR', 'YELLOW', 6, 1, 4);
insert into color_surtimiento values ('P', 'PARTIR', 'BLUE', 8, 2, 6);
insert into color_surtimiento values ('F', 'FALTANTE', 'RED', 3, 3, 1);
insert into color_surtimiento values ('I', 'IMPORTADO', 'MAGENTA', 7, 4, 2);
insert into color_surtimiento values ('D', 'DESARROLLO', 'GREEN', 4, 5, 3);
insert into color_surtimiento values ('R', 'RESERVA', 'BLACK', 4, 5, 5);
commit;


select * from color_surtimiento order by peso;