begin
  surte.por_item();
end;

begin
  surte_reporte_faltante.guarda_detalle();
end;

select * from tmp_selecciona_articulo;

select * from tmp_surte_jgo;