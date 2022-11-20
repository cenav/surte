create or replace package body surte_scanner as
  /*
   private routines
   */
  function en_rango_para_partir(
    p_min_cant_partir number
  , p_cant_prog       number
  ) return boolean is
  begin
    return p_min_cant_partir between 1 and (p_cant_prog - 1);
  end;

  procedure modifica_calculo(
    p_calc in out nocopy surte_struct.calc_header_rt
  , p_cant_jgo           number
  , p_cantidad           number
  , p_rendimiento        number
  , p_stock_listo        number
  , p_stock_armar        number
  , p_es_importado       number
  , p_es_sao             number
  , p_precio_unit        number
  , p_min_val_partir     number
  ) is
  begin
    p_calc.min_cant_partir := multiplo.inferior(
        least(p_calc.min_cant_partir,
              case
                when p_es_sao = 1 and multiplo.inferior(p_stock_listo, surte_util.gc_multiplo_partir) = 0 then
                  p_calc.min_cant_partir
                else
                  least(p_cant_jgo, greatest(p_stock_listo / p_rendimiento, p_stock_armar / p_rendimiento))
              end
          )
      , surte_util.gc_multiplo_partir
      );
    if p_stock_armar < p_cantidad and p_es_sao = 0 then
      p_calc.stock_completo := false;
      p_calc.piezas_sin_stock := p_calc.piezas_sin_stock + 1;
    end if;
    if p_es_importado = 1 and p_stock_armar < p_cantidad and p_es_sao = 0 then
      p_calc.falta_importado := true;
      p_calc.armar := false;
    end if;
    if multiplo.inferior(p_stock_armar, surte_util.gc_multiplo_partir) = 0 or
       p_calc.min_cant_partir * p_precio_unit < p_min_val_partir
    then
      p_calc.armar := false;
    end if;
  end;

  procedure analiza_sao(
    p_juego in out nocopy surte_struct.juego_rt
  , p_pieza in out nocopy surte_struct.pieza_rt
  , p_stocks              surte_stock.aat
  , p_param               param_surte%rowtype
  ) is
    c_tratalo_como_pieza constant number := 0;
    l_stock_listo                 number := 0;
    l_stock_armar                 number := 0;
  begin
    p_pieza.calculo.armar := case when p_pieza.saos.count > 0 then true else false end;
    for i in 1 .. p_pieza.saos.count loop
      l_stock_listo := surte_stock.actual(p_pieza.cod_art, p_stocks);
      l_stock_armar := surte_stock.actual(p_pieza.saos(i).cod_sao, p_stocks);
      modifica_calculo(
          p_calc => p_juego.calculo
        , p_cant_jgo => p_juego.cant_prog
        , p_cantidad => p_pieza.saos(i).cantidad
        , p_rendimiento => p_pieza.saos(i).rendimiento
        , p_stock_listo => l_stock_listo
        , p_stock_armar => l_stock_armar
        , p_es_importado => p_pieza.saos(i).es_importado
        , p_es_sao => c_tratalo_como_pieza
        , p_precio_unit => p_juego.preuni
        , p_min_val_partir => p_param.valor_partir
        );
      modifica_calculo(
          p_calc => p_pieza.calculo
        , p_cant_jgo => p_juego.cant_prog
        , p_cantidad => p_pieza.saos(i).cantidad
        , p_rendimiento => p_pieza.saos(i).rendimiento
        , p_stock_listo => l_stock_listo
        , p_stock_armar => l_stock_armar
        , p_es_importado => p_pieza.saos(i).es_importado
        , p_es_sao => c_tratalo_como_pieza
        , p_precio_unit => p_juego.preuni
        , p_min_val_partir => p_param.valor_partir
        );
    end loop;
  end;

  /*
   public routines
   */
  procedure analiza(
    p_juego in out nocopy surte_struct.juego_rt
  , p_stocks              surte_stock.aat
  , p_param               param_surte%rowtype
  ) is
  begin
    for i in 1 .. p_juego.piezas.count loop
      modifica_calculo(
          p_calc => p_juego.calculo
        , p_cant_jgo => p_juego.cant_prog
        , p_cantidad => p_juego.piezas(i).cantidad
        , p_rendimiento => p_juego.piezas(i).rendimiento
        , p_stock_listo => 0
        , p_stock_armar => surte_stock.actual(p_juego.piezas(i).cod_art, p_stocks)
        , p_es_importado => p_juego.piezas(i).es_importado
        , p_es_sao => p_juego.piezas(i).es_sao
        , p_precio_unit => p_juego.preuni
        , p_min_val_partir => p_param.valor_partir
        );
      if p_juego.piezas(i).es_sao = 1 then
        analiza_sao(p_juego, p_juego.piezas(i), p_stocks, p_param);
      end if;
    end loop;

    if en_rango_para_partir(p_juego.calculo.min_cant_partir, p_juego.cant_prog) then
      p_juego.calculo.podria_partirse := true;
    end if;

    if p_juego.calculo.piezas_sin_stock between 1 and p_param.max_faltante_reserva and
       p_juego.valor >= p_param.min_valor_reserva and
       p_juego.es_juego = surte_util.gc_true and
       not p_juego.calculo.podria_partirse
    then
      p_juego.calculo.reserva_stock := true;
      p_juego.calculo.urgente := true;
    end if;

    if p_juego.calculo.piezas_sin_stock between 1 and p_param.max_faltante_reserva and
       p_juego.valor >= p_param.min_valor_reserva and
       p_juego.es_juego = surte_util.gc_false and
       not p_juego.calculo.podria_partirse
    then
      p_juego.calculo.urgente := true;
    end if;

  end analiza;

end surte_scanner;
