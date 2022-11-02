create or replace package surte as
  procedure por_item(
    p_pais     varchar2 default null
  , p_vendedor varchar2 default null
  , p_dias     pls_integer default null
  , p_empaque  varchar2 default null
  , p_es_juego pls_integer default null
  , p_orden    pls_integer default 1
  );

  function total_imprimir return number;

  function total_simulado return number;

  function total_impreso return number;

  function total_surtir return number;

end surte;
