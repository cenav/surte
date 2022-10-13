create or replace package surte_scanner as

  function tiene_stock_completo(
    p_calculo surte_struct.calc_header_rt
  ) return boolean;

  procedure analiza(
    p_juego in out surte_struct.juego_rt
  , p_stocks       surte_stock.aat
  );

  function puede_partirse(
    p_juego in out nocopy surte_struct.juego_rt
  , p_stocks              surte_stock.aat
  , p_valor_partir        number
  ) return boolean;

end surte_scanner;