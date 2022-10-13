create or replace package surte_builder as
  function crea_saos(
    p_formulas surte_formula.formulas_aat
  , p_cantidad number
  , p_stocks   surte_stock.aat
  ) return surte_struct.saos_aat;


  procedure crea_saos(
    p_pieza in out surte_struct.pieza_rt
  , p_formulas     surte_formula.formulas_aat
  , p_stocks       surte_stock.aat
  );
end surte_builder;