create or replace package surte_scanner as

  procedure analiza(
    p_juego in out nocopy surte_struct.juego_rt
  , p_stocks              surte_stock.aat
  , p_param               param_surte%rowtype
  );

end surte_scanner;