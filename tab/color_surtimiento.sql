create table pevisa.color_surtimiento (
  id_color   varchar2(1),
  dsc_color  varchar2(50) not null,
  nom_color  varchar2(50) not null,
  colorindex number(3) not null
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


insert into color_surtimiento(id_color, dsc_color, nom_color, colorindex) values ('B', 'COMPLETO', 'BLUE', 5);
insert into color_surtimiento(id_color, dsc_color, nom_color, colorindex) values ('C', 'PARTIR', 'CYAN', 8);
insert into color_surtimiento(id_color, dsc_color, nom_color, colorindex) values ('R', 'FALTANTE', 'RED', 3);
insert into color_surtimiento(id_color, dsc_color, nom_color, colorindex) values ('M', 'IMPORTADO', 'MAGENTA', 7);
insert into color_surtimiento(id_color, dsc_color, nom_color, colorindex) values ('G', 'DESARROLLO', 'GREEN', 4);
insert into color_surtimiento(id_color, dsc_color, nom_color, colorindex) values ('Y', 'REPARACION', 'YELLOW', 6);
commit;