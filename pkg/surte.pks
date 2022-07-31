create or replace package surte as
  procedure por_cliente(
    p_cliente varchar2
  , p_opcion  opcion_enum.t_opcion
  );

  procedure por_item;
end surte;
