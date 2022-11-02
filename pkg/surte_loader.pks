create or replace package surte_loader as

  function crea_coleccion(
    p_pais     varchar2 default null
  , p_vendedor varchar2 default null
  , p_dias     pls_integer default null
  , p_empaque  varchar2 default null
  , p_es_juego pls_integer default null
  , p_orden    pls_integer default 1
  ) return surte_struct.juegos_aat;

end surte_loader;