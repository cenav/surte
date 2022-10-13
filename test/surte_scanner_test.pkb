create or replace package body surte_scanner_test as
  g_juegos surte_struct.juegos_aat;
  g_stocks surte_stock.aat;
  g_explosion surte_formula.master_aat;

  procedure tiene_stock_completo is
  begin
    for i in 1 .. 3 loop
      surte_scanner.analiza(g_juegos(i), g_stocks);
      ut3.ut.expect(surte_scanner.tiene_stock_completo(g_juegos(i).calculo)).to_be_true();
    end loop;
    for i in 4 .. 6 loop
      surte_scanner.analiza(g_juegos(i), g_stocks);
      ut3.ut.expect(surte_scanner.tiene_stock_completo(g_juegos(i).calculo)).to_be_false();
    end loop;
  end;

  procedure analiza is
  begin
    -- stock completo una piezas
    surte_scanner.analiza(g_juegos(1), g_stocks);
    ut3.ut.expect(g_juegos(1).calculo.stock_completo).to_be_true();
    ut3.ut.expect(g_juegos(1).calculo.falta_importado).to_be_false();
    ut3.ut.expect(g_juegos(1).calculo.podria_partirse).to_be_true();
    ut3.ut.expect(g_juegos(1).calculo.min_cant_partir).to_equal(601);
    ut3.ut.expect(g_juegos(1).calculo.piezas_sin_stock).to_equal(0);
    -- stock completo mas de una pieza
    surte_scanner.analiza(g_juegos(2), g_stocks);
    ut3.ut.expect(g_juegos(2).calculo.stock_completo).to_be_true();
    ut3.ut.expect(g_juegos(2).calculo.falta_importado).to_be_false();
    ut3.ut.expect(g_juegos(2).calculo.podria_partirse).to_be_true();
    ut3.ut.expect(g_juegos(2).calculo.min_cant_partir).to_equal(275);
    ut3.ut.expect(g_juegos(2).calculo.piezas_sin_stock).to_equal(0);
    -- con saos completos
    surte_scanner.analiza(g_juegos(3), g_stocks);
    ut3.ut.expect(g_juegos(3).calculo.stock_completo).to_be_true();
    ut3.ut.expect(g_juegos(3).calculo.falta_importado).to_be_false();
    ut3.ut.expect(g_juegos(3).calculo.podria_partirse).to_be_true();
    ut3.ut.expect(g_juegos(3).calculo.min_cant_partir).to_equal(12);
    ut3.ut.expect(g_juegos(3).calculo.piezas_sin_stock).to_equal(0);
    -- stock incompleto, puede partirse
    surte_scanner.analiza(g_juegos(4), g_stocks);
    ut3.ut.expect(g_juegos(4).calculo.stock_completo).to_be_false();
    ut3.ut.expect(g_juegos(4).calculo.falta_importado).to_be_false();
    ut3.ut.expect(g_juegos(4).calculo.podria_partirse).to_be_true();
    ut3.ut.expect(g_juegos(4).calculo.min_cant_partir).to_equal(4);
    ut3.ut.expect(g_juegos(4).calculo.piezas_sin_stock).to_equal(2);
    -- stock incompleto, importado sin stock
    surte_scanner.analiza(g_juegos(5), g_stocks);
    ut3.ut.expect(g_juegos(5).calculo.stock_completo).to_be_false();
    ut3.ut.expect(g_juegos(5).calculo.falta_importado).to_be_true();
    ut3.ut.expect(g_juegos(5).calculo.podria_partirse).to_be_false();
    ut3.ut.expect(g_juegos(5).calculo.min_cant_partir).to_equal(0);
    ut3.ut.expect(g_juegos(5).calculo.piezas_sin_stock).to_equal(5);
    -- stock incompleto, no puede partirse
    surte_scanner.analiza(g_juegos(6), g_stocks);
    ut3.ut.expect(g_juegos(6).calculo.stock_completo).to_be_false();
    ut3.ut.expect(g_juegos(6).calculo.falta_importado).to_be_false();
    ut3.ut.expect(g_juegos(6).calculo.podria_partirse).to_be_false();
    ut3.ut.expect(g_juegos(6).calculo.min_cant_partir).to_equal(0);
    ut3.ut.expect(g_juegos(6).calculo.piezas_sin_stock).to_equal(1);
    -- sao incompleto
    surte_scanner.analiza(g_juegos(7), g_stocks);
    ut3.ut.expect(g_juegos(7).calculo.stock_completo).to_be_false();
    ut3.ut.expect(g_juegos(7).calculo.falta_importado).to_be_false();
    ut3.ut.expect(g_juegos(7).calculo.podria_partirse).to_be_false();
    ut3.ut.expect(g_juegos(7).calculo.min_cant_partir).to_equal(0);
    ut3.ut.expect(g_juegos(7).calculo.piezas_sin_stock).to_equal(12);
  end;

  procedure setup is
  begin
    delete from pedidos_test;
    -- stock completo
    insert into pedidos_test(numero, item) values (14779, 32);
    insert into pedidos_test(numero, item) values (14777, 81);
    insert into pedidos_test(numero, item) values (14659, 27);
    -- stock incompleto
    insert into pedidos_test(numero, item) values (14661, 35);
    insert into pedidos_test(numero, item) values (14784, 07);
    insert into pedidos_test(numero, item) values (14704, 06);
    -- sao incompleto
    insert into pedidos_test(numero, item) values (409, 283);
    g_juegos := surte_loader.crea_coleccion();
    g_stocks := surte_stock.carga();
    g_explosion := surte_formula.explosion();
    for i in 1 .. g_juegos.count loop
      --       dbms_output.put_line(g_juegos(i).formu_art);
      for j in 1 .. g_juegos(i).piezas.count loop
        --         dbms_output.put_line('      piezas ' || g_juegos(i).piezas(j).cod_art);
        surte_builder.crea_saos(
            g_juegos(i).piezas(j)
          , surte_formula.formula(g_explosion, g_juegos(i).piezas(j).cod_art)
          , g_stocks
          );
      end loop;
    end loop;
  end;

  procedure reinicia is
  begin
    for i in 1 .. g_juegos.count loop
      g_juegos(i).calculo.stock_completo := true;
      g_juegos(i).calculo.podria_partirse := true;
      g_juegos(i).calculo.es_partible := true;
      g_juegos(i).calculo.tiene_stock_ot := true;
      g_juegos(i).calculo.falta_importado := false;
      g_juegos(i).calculo.min_cant_partir := surte_util.gc_infinito;
      g_juegos(i).calculo.piezas_sin_stock := 0;
    end loop;
  end;

  procedure cleanup is
  begin
    delete from pedidos_test;
  end;

end surte_scanner_test;