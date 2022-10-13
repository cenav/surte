create or replace package body surte_builder as

  function crea_sao(
    p_formula  surte_formula.formula_rt
  , p_cantidad number
  , p_stocks   surte_stock.aat
  ) return surte_struct.sao_rt is
    l_sao   surte_struct.sao_rt;
    l_stock number;
  begin
    l_stock := surte_stock.actual(p_formula.cod_for, p_stocks);
    l_sao.cod_sao := p_formula.cod_for;
    l_sao.rendimiento := p_formula.canti;
    l_sao.cantidad := p_formula.canti * p_cantidad;
    l_sao.stock_inicial := surte_stock.inicial(p_formula.cod_for, p_stocks);
    l_sao.stock_actual := surte_stock.actual(p_formula.cod_for, p_stocks);
--     l_sao.calculo := calc_sao(p_juego, p_pieza, l_sao, l_stock);
    return l_sao;
  end;

  function crea_saos(
    p_formulas surte_formula.formulas_aat
  , p_cantidad number
  , p_stocks   surte_stock.aat
  ) return surte_struct.saos_aat is
    l_saos surte_struct.saos_aat;
  begin
    for i in 1 .. p_formulas.count loop
      l_saos(i) := crea_sao(p_formulas(i), p_cantidad, p_stocks);
    end loop;
    return l_saos;
  end;

  procedure crea_saos(
    p_pieza in out surte_struct.pieza_rt
  , p_formulas     surte_formula.formulas_aat
  , p_stocks       surte_stock.aat
  ) is
  begin
    if p_pieza.es_sao = 1 and surte_stock.actual(p_pieza.cod_art, p_stocks) < p_pieza.cantidad then
      p_pieza.saos := crea_saos(p_formulas, p_pieza.cantidad, p_stocks);
    end if;
  end;
end surte_builder;