create or replace package surte_data_builder as

  procedure completo(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  );

  procedure partir(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  );


  procedure faltante(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  );

  procedure importado(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  );

  procedure completo_arma_sao(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  );

  procedure faltante_arma_sao(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  );

  procedure parte_arma_sao(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  );

  procedure stock_incompleto_arma_sao(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  );

  procedure no_quiere_partir(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  );

  procedure faltante_suelto(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  );

end surte_data_builder;