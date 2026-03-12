create or replace package surte_embalaje as

  type aat is table of boolean index by tab_lineas_tipo_linea.cod_linea%type;

  function lineas return aat;

end surte_embalaje;
