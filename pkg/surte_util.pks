create or replace package surte_util as
  subtype t_string is varchar2(32672);
  subtype t_articulo is varchar2(30);
  subtype t_ranking is pls_integer;

  gc_infinito constant number := 9999999999;
  gc_multiplo_partir constant simple_integer := 5;
  gc_true constant signtype := 1;
  gc_false constant signtype := 0;

  function bool_to_logic(
    p_bool boolean
  ) return signtype;

  function material(
    p_formu_cod_art pr_for_ins.formu_art_cod_art%type
  ) return varchar2;

  function ribete(
    p_formu_cod_art pr_for_ins.formu_art_cod_art%type
  ) return varchar2;

  function subpieza(
    p_formu_cod_art pr_for_ins.formu_art_cod_art%type
  ) return varchar2;
end surte_util;
/
