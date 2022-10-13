create or replace package body surte_scanner as
  /*
   private routines
   */
  procedure modifica_calculo(
    p_calc in out nocopy surte_struct.calc_header_rt
  , p_cantidad           number
  , p_stock_actual       number
  , p_es_importado       number
  ) is
  begin
    p_calc.min_cant_partir :=
        multiplo.inferior(least(p_calc.min_cant_partir, p_stock_actual), surte_util.gc_multiplo_partir);
    if p_stock_actual < p_cantidad then
      p_calc.stock_completo := false;
      p_calc.piezas_sin_stock := p_calc.piezas_sin_stock + 1;
    end if;
    if p_es_importado = 1 and p_stock_actual = 0 then
      p_calc.falta_importado := true;
      p_calc.armar := false;
    end if;
    if p_stock_actual = 0 then
      p_calc.podria_partirse := false;
      p_calc.armar := false;
    end if;
  end;

  function prueba_partir(
    p_juego       surte_struct.juego_rt
  , p_stocks      surte_stock.aat
  , p_cant_partir number
  ) return boolean is
    l_es_partible  boolean := true;
    l_stock_actual number  := 0;
  begin
    for i in 1 .. p_juego.piezas.count loop
      l_stock_actual := surte_stock.actual(p_juego.piezas(i).cod_art, p_stocks);
      if p_cant_partir * p_juego.piezas(i).rendimiento > l_stock_actual then
        l_es_partible := false;
      end if;
      for j in 1 .. p_juego.piezas(i).saos.count loop
        l_stock_actual := surte_stock.actual(p_juego.piezas(i).saos(j).cod_sao, p_stocks);
        if p_cant_partir * p_juego.piezas(i).saos(j).rendimiento > l_stock_actual then
          l_es_partible := false;
        end if;
      end loop;
    end loop;
    return l_es_partible;
  end;

  function formula_minimo_ok(
    p_juego in out nocopy surte_struct.juego_rt
  , p_stocks              surte_stock.aat
  , p_valor_partir        number
  ) return boolean is
--     l_cant_partir      number;
    l_valor_surtir     number;
    l_cumple_valor_min boolean;
  begin
    --     l_cant_partir := multiplo.inferior(p_juego.calculo.min_cant_partir, surte_util.gc_multiplo_partir);
    l_valor_surtir := p_juego.calculo.min_cant_partir * p_juego.preuni;
    l_cumple_valor_min := l_valor_surtir >= p_valor_partir;
    return l_cumple_valor_min and prueba_partir(p_juego, p_stocks, p_juego.calculo.min_cant_partir);
  end;

  /*
   public routines
   */
  function tiene_stock_completo(
    p_calculo surte_struct.calc_header_rt
  ) return boolean is
    l_stock number := 0;
  begin
    return p_calculo.stock_completo;
  end;

  function puede_partirse(
    p_juego in out nocopy surte_struct.juego_rt
  , p_stocks              surte_stock.aat
  , p_valor_partir        number
  ) return boolean is
    l_stock number := 0;
  begin
    return p_juego.calculo.podria_partirse and formula_minimo_ok(p_juego, p_stocks, p_valor_partir);
  end;

  procedure analiza_sao(
    p_juego in out nocopy surte_struct.juego_rt
  , p_pieza in out nocopy surte_struct.pieza_rt
  , p_stocks              surte_stock.aat
  ) is
    l_stock_actual number := 0;
  begin
    for i in 1 .. p_pieza.saos.count loop
      l_stock_actual := surte_stock.actual(p_pieza.saos(i).cod_sao, p_stocks);
      modifica_calculo(
          p_juego.calculo
        , p_pieza.saos(i).cantidad
        , l_stock_actual
        , p_pieza.saos(i).es_importado
        );
      modifica_calculo(
          p_pieza.calculo
        , p_pieza.saos(i).cantidad
        , l_stock_actual
        , p_pieza.saos(i).es_importado
        );
    end loop;
  end;

  procedure analiza(
    p_juego in out surte_struct.juego_rt
  , p_stocks       surte_stock.aat
  ) is
    l_stock_actual number := 0;
  begin
    --     dbms_output.put_line(p_juego.formu_art || ' ==> ' || p_juego.calculo.piezas_sin_stock);
    for i in 1 .. p_juego.piezas.count loop
      if p_juego.piezas(i).es_sao = 0 then
        l_stock_actual := surte_stock.actual(p_juego.piezas(i).cod_art, p_stocks);
        modifica_calculo(
            p_juego.calculo
          , p_juego.piezas(i).cantidad
          , l_stock_actual
          , p_juego.piezas(i).es_importado
          );
--         dbms_output.put_line('     ' || p_juego.calculo.piezas_sin_stock || ' ==> ' || p_juego.piezas(i).cod_art);
      else
        analiza_sao(p_juego, p_juego.piezas(i), p_stocks);
      end if;
    end loop;
  end;

end surte_scanner;