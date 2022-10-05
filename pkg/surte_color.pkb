create or replace package body surte_color as
  function all_rows return aat is
    l_colores aat;
  begin
    for r in (select * from color_surtimiento) loop
      l_colores(r.id_color) := r;
    end loop;
    return l_colores;
  end;

  function peso_mayor(
    p_old_peso number
  , p_new_peso number
  ) return boolean is
  begin
    return p_new_peso > nvl(p_old_peso, 0);
  end;
end surte_color;