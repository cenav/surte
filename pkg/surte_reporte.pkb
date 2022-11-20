create or replace package body surte_reporte as

  function faltante(
    p_cliente    varchar2 default null
  , p_simulacion varchar2 default '%'
  , p_urgente    varchar2 default '%'
  , p_faltante   number default null
  , p_valor      number default null
  ) return faltantes_aat is
    l_faltantes faltantes_aat;
    l_idx       binary_integer := 1;
  begin
    for r in (
      select case
               when lag(j.cod_cliente) over (order by null) = j.cod_cliente then null
               else j.cod_cliente
             end break
           , j.cod_cliente, j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op
           , sum(p.cantidad) as cantidad
        from vw_surte_jgo j
             join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
             join vw_articulo a on p.cod_pza = a.cod_art
       where j.id_color in ('R', 'F')
         and p.id_color = 'F'
         and p.es_sao = 'NO'
         and ((j.cod_cliente = p_cliente or p_cliente is null) and
              (j.es_simulacion like p_simulacion) and
              (j.es_urgente like p_urgente) and
              ((j.cant_faltante <= p_faltante or p_faltante is null) and
               (j.valor <= p_valor or p_valor is null)))
       group by j.cod_cliente, j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op
       order by cod_cliente, dsc_grupo, cod_pza
      )
    loop
      l_faltantes(l_idx).break := r.break;
      l_faltantes(l_idx).cod_cliente := r.cod_cliente;
      l_faltantes(l_idx).nom_cliente := r.nom_cliente;
      l_faltantes(l_idx).resumen.dsc_grupo := r.dsc_grupo;
      l_faltantes(l_idx).resumen.cod_pza := r.cod_pza;
      l_faltantes(l_idx).resumen.cod_lin := r.cod_lin;
      l_faltantes(l_idx).resumen.cantidad := r.cantidad;
      l_faltantes(l_idx).resumen.ordenes := r.numero_op;
      l_idx := l_idx + 1;
    end loop;
    return l_faltantes;
  end;

  function faltante_resumen(
    p_simulacion varchar2 default '%'
  , p_urgente    varchar2 default '%'
  , p_faltante   number default null
  , p_valor      number default null
  ) return faltantes_resumen_aat is
    l_faltantes faltantes_resumen_aat;
    l_idx       binary_integer := 1;
  begin
    for r in (
      select a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op, a.cant_faltante, a.stock_requerida
           , a.saldo_op, a.consumo_anual
           , sum(p.cantidad) as cantidad
        from vw_surte_jgo j
             join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
             join vw_articulo a on p.cod_pza = a.cod_art
       where j.id_color in ('R', 'F')
         and p.id_color = 'F'
         and p.es_sao = 'NO'
         and ((j.es_simulacion like p_simulacion) and
              (j.es_urgente like p_urgente) and
              ((j.cant_faltante <= p_faltante or p_faltante is null) and
               (j.valor <= p_valor or p_valor is null)))
       group by a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op, a.cant_faltante, a.stock_requerida
              , a.saldo_op, a.consumo_anual
       order by dsc_grupo, cod_pza
      )
    loop
      l_faltantes(l_idx).dsc_grupo := r.dsc_grupo;
      l_faltantes(l_idx).cod_pza := r.cod_pza;
      l_faltantes(l_idx).cod_lin := r.cod_lin;
      l_faltantes(l_idx).cantidad := r.cantidad;
      l_faltantes(l_idx).ordenes := r.numero_op;
      l_faltantes(l_idx).faltante_total := r.cant_faltante;
      l_faltantes(l_idx).faltante_sin_stock := r.cant_faltante - r.stock_requerida;
      l_faltantes(l_idx).cantidad_op := r.saldo_op;
      l_faltantes(l_idx).por_emitir := r.saldo_op - r.cant_faltante;
      l_faltantes(l_idx).consumo_anual := r.consumo_anual;
      l_faltantes(l_idx).material := null;
      l_idx := l_idx + 1;
    end loop;
    return l_faltantes;
  end;

end surte_reporte;