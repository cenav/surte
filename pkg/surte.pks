create or replace package surte as
  procedure por_cliente(
    p_cliente varchar2
  , p_opcion  opcion_enum.t_opcion
  );

  procedure por_item(
    p_pais     varchar2 default null
  , p_vendedor varchar2 default null
  , p_dias     pls_integer default null
  );
end surte;
