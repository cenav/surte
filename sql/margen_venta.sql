  with fechas as (
    select add_months(trunc(:p_fecha, 'MM') - 1, -24) + 1 as fch_ini
         , trunc(:p_fecha, 'MM') - 1 as fch_fin
      from dual
    )
     , utilidad as (
    select d.cod_cliente, c.nombre, i.cod_art, d.numero, d.fecha
         , case
             when d.estado = '9' then 0
             else case
                    when :p_moneda = 'D' then
                      case
                        when d.moneda = 'S' then i.imp_vvta / d.import_cam
                        else i.imp_vvta
                      end
                    else case
                           when d.moneda = 'D' then i.imp_vvta * d.import_cam
                           else i.imp_vvta
                         end
                  end
           end as venta
         , i.cantidad *
           case :p_moneda
             when 'D' then get_costos2(i.cod_art, '35', to_number(to_char(d.fecha, 'YYYY')),
                                       to_number(to_char(d.fecha, 'mm')))
             else get_costos2(i.cod_art, '35', to_number(to_char(d.fecha, 'YYYY')),
                              to_number(to_char(d.fecha, 'mm'))) * d.import_cam
           end as costo
         , f.fch_ini, f.fch_fin
      from docuvent d
           join tablas_auxiliares t
                on t.codigo = d.tipodoc
                  and t.tipo = 2
           join itemdocu i
                on d.tipodoc = i.tipodoc
                  and d.serie = i.serie
                  and d.numero = i.numero
           join exclientes c
                on to_number(d.cod_cliente) = c.cod_cliente
           cross join fechas f
     where d.fecha between f.fch_ini and f.fch_fin
       and nvl(d.origen, '0') = 'EXPO'
       and nvl(d.estado, '0') != '9'
--        and exists (
--        select 1 from pr_prioridad_htmp_30 t where t.cod_cliente = to_number(d.cod_cliente)
--        )
     order by d.tipodoc, d.serie, d.numero, d.fecha
    )
     , resumen as (
    select to_number(cod_cliente) as cliente, nombre, round(sum(venta)) as importe_venta
         , round(sum(costo)) as importe_costo, round(sum(venta) - sum(costo)) as importe_utilidad
      from utilidad
     group by to_number(cod_cliente), nombre
     order by importe_utilidad desc
    )
     , analytic_functions as (
    select d.cliente, d.nombre, d.importe_venta, d.importe_costo, d.importe_utilidad
         , sum(d.importe_utilidad) over (order by d.importe_utilidad desc) as acumula_utilidad
         , sum(d.importe_utilidad) over () as total_utilidad
      from resumen d
    )
select a.cliente, a.nombre
     , a.importe_venta
     , a.importe_costo
     , a.importe_utilidad
     , a.acumula_utilidad
     , round((a.acumula_utilidad / a.total_utilidad) * 100, 2) as acumula_porcentaje
  from analytic_functions a;

  select * from planprod_param;

-- 247172

  select * from pr_prioridad_htmp_30;