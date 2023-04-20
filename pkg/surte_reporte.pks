create or replace package pevisa.surte_reporte as

  type resumen_t is record (
    dsc_grupo          surte_util.t_string,
    cod_for            surte_util.t_string,
    cod_pza            surte_util.t_string,
    cod_lin            surte_util.t_string,
    valor              number,
    cantidad           number,
    faltante_total     number,
    faltante_sin_stock number,
    cantidad_op        number,
    por_emitir         number,
    consumo_anual      number,
    stock              number,
    ranking            number,
    prioridad          surte_util.t_string,
    material           surte_util.t_string,
    ribete             surte_util.t_string,
    subpieza           surte_util.t_string,
    ordenes            surte_util.t_string,
    usado_en_sao       surte_util.t_string
  );

  type cliente_t is record (
    break       surte_util.t_string,
    cod_cliente surte_util.t_string,
    nom_cliente surte_util.t_string,
    resumen     resumen_t
  );

  type detalle_t is record (
    nro_pedido  number,
    itm_pedido  number,
    valor       number,
    fch_pedido  date,
    dias_atraso number,
    ranking     number,
    cliente     cliente_t
  );

  type dias_t is record (
    cod_cliente        surte_util.t_string,
    nom_cliente        surte_util.t_string,
    entre_90_180_dias  number,
    entre_180_360_dias number,
    mas_360_dias       number,
    mas_90_dias        number,
    menos_90_dias      number,
    total              number,
    ranking            number
  );

  type resumen_aat is table of resumen_t index by binary_integer;
  type cliente_aat is table of cliente_t index by binary_integer;
  type detalle_aat is table of detalle_t index by binary_integer;
  type dias_aat is table of dias_t index by binary_integer;

  function faltante(
    p_cliente    varchar2
  , p_simulacion varchar2
  , p_urgente    varchar2
  , p_faltante   number
  , p_valor      number
  , p_dias       number
  ) return cliente_aat;

  function faltante_resumen(
    p_cliente    varchar2
  , p_simulacion varchar2
  , p_urgente    varchar2
  , p_faltante   number
  , p_valor      number
  , p_dias       number
  ) return resumen_aat;

  function faltante_detalle(
    p_cliente    varchar2
  , p_simulacion varchar2
  , p_urgente    varchar2
  , p_faltante   number
  , p_valor      number
  , p_dias       number
  ) return detalle_aat;

  function faltante_resumen_sao(
    p_cliente    varchar2
  , p_simulacion varchar2
  , p_urgente    varchar2
  , p_faltante   number
  , p_valor      number
  , p_dias       number
  ) return resumen_aat;

  function faltante_importe_atraso(
    p_cliente    varchar2
  , p_simulacion varchar2
  , p_urgente    varchar2
  , p_faltante   number
  , p_valor      number
  , p_dias       number
  ) return dias_aat;
end surte_reporte;
/
