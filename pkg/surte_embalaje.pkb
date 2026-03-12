create or replace package body surte_embalaje as

  function lineas return aat is
    l_lineas aat;
  begin
    for r in (
      select cod_linea
        from tab_lineas_tipo_linea
       where cod_tipo = 3 --> cajas
       order by cod_linea
      )
    loop
      l_lineas(r.cod_linea) := false; --> valor de referencia booleano, no se usa
    end loop;
    return l_lineas;
  end;

end surte_embalaje;
