create or replace package surte as
  procedure por_cliente(
    p_cliente varchar2
  , p_opcion  opcion_enum.t_opcion
  );

  procedure por_item(
    p_pais     varchar2 default null
  , p_vendedor varchar2 default null
  , p_dias     pls_integer default null
  , p_empaque  varchar2 default null
  );

  function total_imprimir return number;

  function total_impreso return number;

  function total_surtir return number;
end surte;
