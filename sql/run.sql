begin
  surte.por_item();
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