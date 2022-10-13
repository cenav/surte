create or replace package surte_scanner_test as
  -- %suite(rutinas que indican los casos para surtir stock)

  -- %test(completo)
  procedure tiene_stock_completo;

  -- %test(analiza)
  procedure analiza;

  -- %beforeall
  procedure setup;

  -- %beforeeach
  procedure reinicia;

  -- %afterall
  procedure cleanup;

end surte_scanner_test;