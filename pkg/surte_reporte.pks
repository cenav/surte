create or replace package surte_reporte as

  type resumen_t is record (
    dsc_grupo          surte_util.t_string,
    cod_pza            surte_util.t_string,
    cod_lin            surte_util.t_string,
    cantidad           number,
    faltante_total     number,
    faltante_sin_stock number,
    cantidad_op        number,
    por_emitir         number,
    consumo_anual      number,
    material           surte_util.t_string,
    ordenes            surte_util.t_string
  );

  type faltante_t is record (
    break       surte_util.t_string,
    cod_cliente surte_util.t_string,
    nom_cliente surte_util.t_string,
    resumen     resumen_t
  );

  type faltantes_aat is table of faltante_t index by binary_integer;
  type faltantes_resumen_aat is table of resumen_t index by binary_integer;

  function faltante(
    p_cliente    varchar2 default null
  , p_simulacion varchar2 default '%'
  , p_urgente    varchar2 default '%'
  , p_faltante   number default null
  , p_valor      number default null
  ) return faltantes_aat;

  function faltante_resumen(
    p_simulacion varchar2 default '%'
  , p_urgente    varchar2 default '%'
  , p_faltante   number default null
  , p_valor      number default null
  ) return faltantes_resumen_aat;

end surte_reporte;