begin
  surte.por_item();
end;

-- valores por defecto actuales
begin
  surte.por_item(
      p_pais => null
    , p_vendedor => null
    , p_dias => null
    , p_empaque => null
    , p_es_juego => null
    , p_orden => 2 --> por artículos agrupados
    , p_es_nuevo => null
  );
end;

begin
  surte_reporte_faltante.guarda_detalle();
end;

select *
  from tmp_surte_pza
 where nro_pedido = 16356;

select *
  from expedidos
 where numero = 16356;

select * from color_surtimiento;

