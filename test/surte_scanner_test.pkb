create or replace package body surte_scanner_test as
  g_param param_surte%rowtype;

  procedure analiza_completo is
    l_juego  surte_struct.juego_rt;
    l_stocks surte_stock.aat;
  begin
    surte_data_builder.completo(l_juego, l_stocks);
    surte_scanner.analiza(l_juego, l_stocks, g_param);
    ut3.ut.expect(l_juego.calculo.stock_completo).to_be_true();
    ut3.ut.expect(l_juego.calculo.falta_importado).to_be_false();
    ut3.ut.expect(l_juego.calculo.podria_partirse).to_be_false();
    ut3.ut.expect(l_juego.calculo.min_cant_partir).to_equal(470);
    ut3.ut.expect(l_juego.calculo.piezas_sin_stock).to_equal(0);
  end;

  procedure analiza_partir is
    l_juego  surte_struct.juego_rt;
    l_stocks surte_stock.aat;
  begin
    surte_data_builder.partir(l_juego, l_stocks);
    surte_scanner.analiza(l_juego, l_stocks, g_param);
    ut3.ut.expect(l_juego.calculo.stock_completo).to_be_false();
    ut3.ut.expect(l_juego.calculo.falta_importado).to_be_false();
    ut3.ut.expect(l_juego.calculo.podria_partirse).to_be_true();
    ut3.ut.expect(l_juego.calculo.min_cant_partir).to_equal(40);
    ut3.ut.expect(l_juego.calculo.piezas_sin_stock).to_equal(1);
  end;

  procedure analiza_faltante is
    l_juego  surte_struct.juego_rt;
    l_stocks surte_stock.aat;
  begin
    surte_data_builder.faltante(l_juego, l_stocks);
    surte_scanner.analiza(l_juego, l_stocks, g_param);
    ut3.ut.expect(l_juego.calculo.stock_completo).to_be_false();
    ut3.ut.expect(l_juego.calculo.falta_importado).to_be_false();
    ut3.ut.expect(l_juego.calculo.podria_partirse).to_be_false();
    ut3.ut.expect(l_juego.calculo.min_cant_partir).to_equal(0);
    ut3.ut.expect(l_juego.calculo.piezas_sin_stock).to_equal(2);
  end;

  procedure analiza_importado is
    l_juego  surte_struct.juego_rt;
    l_stocks surte_stock.aat;
  begin
    surte_data_builder.importado(l_juego, l_stocks);
    surte_scanner.analiza(l_juego, l_stocks, g_param);
    ut3.ut.expect(l_juego.calculo.stock_completo).to_be_false();
    ut3.ut.expect(l_juego.calculo.falta_importado).to_be_true();
    ut3.ut.expect(l_juego.calculo.podria_partirse).to_be_false();
    ut3.ut.expect(l_juego.calculo.min_cant_partir).to_equal(0);
    ut3.ut.expect(l_juego.calculo.piezas_sin_stock).to_equal(2);
  end;

  procedure analiza_completo_sao is
    l_juego  surte_struct.juego_rt;
    l_stocks surte_stock.aat;
  begin
    surte_data_builder.completo_arma_sao(l_juego, l_stocks);
    surte_scanner.analiza(l_juego, l_stocks, g_param);
    ut3.ut.expect(l_juego.calculo.stock_completo).to_be_true();
    ut3.ut.expect(l_juego.calculo.falta_importado).to_be_false();
    ut3.ut.expect(l_juego.calculo.podria_partirse).to_be_false();
    ut3.ut.expect(l_juego.calculo.min_cant_partir).to_equal(60);
    ut3.ut.expect(l_juego.calculo.piezas_sin_stock).to_equal(0);
  end;

  procedure analiza_faltante_sao is
    l_juego  surte_struct.juego_rt;
    l_stocks surte_stock.aat;
  begin
    surte_data_builder.faltante_arma_sao(l_juego, l_stocks);
    surte_scanner.analiza(l_juego, l_stocks, g_param);
    ut3.ut.expect(l_juego.calculo.stock_completo).to_be_false();
    ut3.ut.expect(l_juego.calculo.falta_importado).to_be_false();
    ut3.ut.expect(l_juego.calculo.podria_partirse).to_be_false();
    ut3.ut.expect(l_juego.calculo.min_cant_partir).to_equal(0);
    ut3.ut.expect(l_juego.calculo.piezas_sin_stock).to_equal(1);
  end;

  procedure analiza_parte_sao is
    l_juego  surte_struct.juego_rt;
    l_stocks surte_stock.aat;
  begin
    surte_data_builder.parte_arma_sao(l_juego, l_stocks);
    surte_scanner.analiza(l_juego, l_stocks, g_param);
    ut3.ut.expect(l_juego.calculo.stock_completo).to_be_false();
    ut3.ut.expect(l_juego.calculo.falta_importado).to_be_false();
    ut3.ut.expect(l_juego.calculo.podria_partirse).to_be_true();
    ut3.ut.expect(l_juego.calculo.min_cant_partir).to_equal(75);
    ut3.ut.expect(l_juego.calculo.piezas_sin_stock).to_equal(1);
  end;

  procedure analiza_arma_sao is
    l_juego  surte_struct.juego_rt;
    l_stocks surte_stock.aat;
  begin
    surte_data_builder.stock_incompleto_arma_sao(l_juego, l_stocks);
    surte_scanner.analiza(l_juego, l_stocks, g_param);
    ut3.ut.expect(l_juego.calculo.stock_completo).to_be_true();
    ut3.ut.expect(l_juego.calculo.falta_importado).to_be_false();
    ut3.ut.expect(l_juego.calculo.podria_partirse).to_be_false();
    ut3.ut.expect(l_juego.calculo.min_cant_partir).to_equal(10);
    ut3.ut.expect(l_juego.calculo.piezas_sin_stock).to_equal(0);
  end;

  procedure analiza_no_quiere_partir is
    l_juego  surte_struct.juego_rt;
    l_stocks surte_stock.aat;
  begin
    surte_data_builder.no_quiere_partir(l_juego, l_stocks);
    surte_scanner.analiza(l_juego, l_stocks, g_param);
    ut3.ut.expect(l_juego.calculo.stock_completo).to_be_false();
    ut3.ut.expect(l_juego.calculo.falta_importado).to_be_false();
    ut3.ut.expect(l_juego.calculo.podria_partirse).to_be_true();
    ut3.ut.expect(l_juego.calculo.min_cant_partir).to_equal(5);
    ut3.ut.expect(l_juego.calculo.piezas_sin_stock).to_equal(2);
  end;

  procedure analiza_faltante_suelto is
    l_juego  surte_struct.juego_rt;
    l_stocks surte_stock.aat;
  begin
    surte_data_builder.faltante_suelto(l_juego, l_stocks);
    surte_scanner.analiza(l_juego, l_stocks, g_param);
    ut3.ut.expect(l_juego.calculo.stock_completo).to_be_false();
    ut3.ut.expect(l_juego.calculo.falta_importado).to_be_false();
    ut3.ut.expect(l_juego.calculo.podria_partirse).to_be_false();
    ut3.ut.expect(l_juego.calculo.min_cant_partir).to_equal(0);
    ut3.ut.expect(l_juego.calculo.piezas_sin_stock).to_equal(1);
  end;

  procedure puede_partirse_sin_stock_compl is
    l_juego  surte_struct.juego_rt;
    l_stocks surte_stock.aat;
  begin
    surte_data_builder.no_quiere_partir(l_juego, l_stocks);
    surte_scanner.analiza(l_juego, l_stocks, g_param);
    ut3.ut.expect(l_juego.calculo.podria_partirse).to_be_true();
  end;

  procedure setup is
  begin
    g_param := api_param_surte.onerow();
  end;

end surte_scanner_test;