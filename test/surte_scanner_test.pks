create or replace package surte_scanner_test as
  -- %suite(rutinas que indican los casos para surtir stock)

  -- %test(stock completo de piezas)
  procedure analiza_completo;

  -- %test(juegos que se puden partir)
  procedure analiza_partir;

  -- %test(una de las piezas tiene stock cero, juego faltante)
  procedure analiza_faltante;

  -- %test(al menos una de las piezas tiene stock 0 y es importado)
  procedure analiza_importado;

  -- %test(stock completo con SAO para armar)
  procedure analiza_completo_sao;

  -- %test(stock incompleto por SAO faltante y no se puede armar)
  procedure analiza_faltante_sao;

  -- %test(stock incompleto por SAO faltante pero se pueden partir los SAOS por armar)
  procedure analiza_parte_sao;

  -- %test(stock casi completo con SAO faltante pero se puede armar las piezas del SAO)
  procedure analiza_arma_sao;

  -- %test(piezas se puden partir porque el stock suma el valor minimo)
  procedure analiza_no_quiere_partir;

  -- %test(suelto que no tiene stock completo ni se puede partir)
  procedure analiza_faltante_suelto;

  -- %test(piezas se puden partir porque el stock suma el valor minimo condicional)
  procedure puede_partirse_sin_stock_compl;

  -- %beforeall(inicializa parametros globales)
  procedure setup;

end surte_scanner_test;