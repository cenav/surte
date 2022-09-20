create or replace package surte_formula as
  type formula_rt is record (
    cod_for pcformulas.cod_art%type,
    canti   pcformulas.canti%type
  );

  type formulas_aat is table of formula_rt index by pls_integer;

  type master_rt is record (
    cod_art pcmasters.cod_art%type,
    formulas formulas_aat
  );

  type master_aat is table of master_rt index by surte_util.t_articulo;

  function explosion return master_aat;

  function explosion(
    p_codart articul.cod_art%type
  ) return master_aat;
end surte_formula;