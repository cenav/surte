create or replace package body surte_formula as
  cursor saos_cr(p_codart pcformulas.cod_art%type) is
    -- SAO explosion
    select f.cod_art, f.cod_for, f.tipo, f.canti, f.neto, f.linea, f.tp_art, f.quiebre
      from vw_formula_saos f
     where f.cod_art like p_codart
     order by f.cod_art;

  /* private routines */
  procedure master(
    p_formula              saos_cr%rowtype
  , p_master in out nocopy master_aat
  ) is
  begin
    p_master(p_formula.cod_art).cod_art := p_formula.cod_art;
  end;

  procedure detail(
    p_formula              saos_cr%rowtype
  , p_master in out nocopy master_aat
  ) is
    l_idx pls_integer;
  begin
    l_idx := p_master(p_formula.cod_art).formulas.count + 1;
    p_master(p_formula.cod_art).formulas(l_idx).cod_for := p_formula.cod_for;
    p_master(p_formula.cod_art).formulas(l_idx).canti := p_formula.canti;
  end;

  /* public routines */
  function explosion return master_aat is
  begin
    return explosion('%');
  end;

  function explosion(
    p_codart articul.cod_art%type
  ) return master_aat is
    l_explosion master_aat;
  begin
    for formula in saos_cr(p_codart) loop
      if formula.quiebre is not null then
        master(formula, l_explosion);
        detail(formula, l_explosion);
      elsif formula.quiebre is null then
        detail(formula, l_explosion);
      end if;
    end loop;

    return l_explosion;
  end;
end surte_formula;