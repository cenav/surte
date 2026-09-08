-- valores por defecto actuales
begin
  surte.por_item(
      p_pais => null
    , p_vendedor => null
    , p_dias => null
    , p_empaque => null
    , p_es_juego => null
    , p_orden => 2 --> [1] items mayor valor [2] por artículos agrupados
    , p_es_nuevo => null
  );
end;

select *
  from vw_surte_jgo
 where ot_numero = 13555;

select *
  from pr_ot
 where nuot_tipoot_codigo = 'SA'
   and numero = 13555;

select *
  from pr_estados_sao
 order by estado;

