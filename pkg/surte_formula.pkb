create or replace package body surte_formula as
  cursor saos_cr(p_codart pcformulas.cod_art%type) is
    -- SAO explosion
    select f.cod_art, f.cod_for, f.tipo, f.canti, f.neto, f.linea, f.tp_art, f.quiebre
      from vw_formula_saos f
     where f.cod_art like p_codart
     order by f.cod_art, f.quiebre;

  /* private routines */
  procedure master(
    p_master in out nocopy master_aat
  , p_formula              saos_cr%rowtype
  ) is
  begin
    p_master(p_formula.cod_art).cod_art := p_formula.cod_art;
  end;

  procedure detail(
    p_master in out nocopy master_aat
  , p_formula              saos_cr%rowtype
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
        master(l_explosion, formula);
        detail(l_explosion, formula);
      elsif formula.quiebre is null then
        detail(l_explosion, formula);
      end if;
    end loop;

    return l_explosion;
  end;

  function formula(
    p_explosion master_aat
  , p_codart    articul.cod_art%type
  ) return formulas_aat is
  begin
    return case when p_explosion.exists(p_codart) then p_explosion(p_codart).formulas end;
  end;
end surte_formula;