create or replace package body pevisa.surte_reporte as
  /*
   Private routines
   */
  function cant_emitir(
    p_faltante number
  , p_saldo    number
  ) return number is
    l_emitir number := 0;
  begin
    l_emitir := greatest(p_faltante - nvl(p_saldo, 0), 0);
    return case
             when l_emitir >= 300 then
               multiplo.superior(l_emitir, 50)
             else
               multiplo.superior(l_emitir, 10)
           end;
  end;

/*
 Public routines
 */
  function faltante(
    p_cliente    varchar2
  , p_simulacion varchar2
  , p_urgente    varchar2
  , p_faltante   number
  , p_valor      number
  , p_dias       number
  ) return cliente_aat is
    l_clientes cliente_aat;
    l_idx      binary_integer := 1;
  begin
    for r in (
        with faltantes as (
          select case
                   when lag(j.cod_cliente) over (order by null) = j.cod_cliente then null
                   else j.cod_cliente
                 end as break
               , j.cod_cliente, j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op
               , sum(p.cantidad) as cantidad, a.cant_faltante, a.stock_requerida, a.saldo_op
               , a.consumo_anual, min(j.orden_prioridad) as min_orden_prioridad, a.stock
               , sum(j.valor) as valor, min(j.ranking) as ranking
            from vw_surte_jgo j
                 join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
                 join vw_articulo a on p.cod_pza = a.cod_art
           where j.id_color in ('R', 'F')
             and p.id_color = 'F'
             and p.es_sao = 'NO'
             and ((j.cod_cliente = p_cliente or p_cliente is null) and
                  (j.es_simulacion like p_simulacion) and
                  (j.es_urgente like p_urgente) and
                  (sysdate - j.fch_pedido > p_dias or p_dias is null) and
                  ((j.cant_faltante <= p_faltante or p_faltante is null) and
                   (j.valor >= p_valor or p_valor is null)))
           group by j.cod_cliente, j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op
                  , a.cant_faltante, a.stock_requerida, a.saldo_op, a.consumo_anual, a.stock
           order by cod_cliente, dsc_grupo, ranking, cod_pza
          )
           , sao as (
          select p.cod_cliente, p.nom_cliente, s.cod_sao
            from vw_surte_pza p
                 join vw_surte_sao s
                      on p.nro_pedido = s.nro_pedido
                        and p.itm_pedido = s.itm_pedido
                        and p.cod_pza = s.cod_pza
           group by p.cod_cliente, p.nom_cliente, s.cod_sao
          )
      select f.break, f.cod_cliente, f.nom_cliente, f.dsc_grupo, f.cod_pza, f.cod_lin, f.numero_op
           , f.cantidad, f.cant_faltante, f.stock_requerida, f.saldo_op, f.consumo_anual, f.stock
           , p.dsc_prioridad, case when s.cod_sao is not null then '*' end as usado_en_sao, f.valor
           , f.ranking
        from faltantes f
             left join prioridad_pedidos p on f.min_orden_prioridad = p.orden
             left join sao s on f.cod_cliente = s.cod_cliente and f.cod_pza = s.cod_sao
      )
    loop
      l_clientes(l_idx).break := r.break;
      l_clientes(l_idx).cod_cliente := r.cod_cliente;
      l_clientes(l_idx).nom_cliente := r.nom_cliente;
      l_clientes(l_idx).resumen.dsc_grupo := r.dsc_grupo;
      l_clientes(l_idx).resumen.cod_pza := r.cod_pza;
      l_clientes(l_idx).resumen.cod_lin := r.cod_lin;
      l_clientes(l_idx).resumen.cantidad := r.cantidad;
      l_clientes(l_idx).resumen.ordenes := r.numero_op;
      l_clientes(l_idx).resumen.faltante_total := r.cant_faltante;
      l_clientes(l_idx).resumen.faltante_sin_stock := r.cant_faltante - r.stock_requerida;
      l_clientes(l_idx).resumen.cantidad_op := r.saldo_op;
      l_clientes(l_idx).resumen.por_emitir := cant_emitir(r.cant_faltante, r.saldo_op);
      l_clientes(l_idx).resumen.consumo_anual := r.consumo_anual;
      l_clientes(l_idx).resumen.material := surte_util.material(r.cod_pza);
      l_clientes(l_idx).resumen.ribete := surte_util.ribete(r.cod_pza);
      l_clientes(l_idx).resumen.subpieza := surte_util.subpieza(r.cod_pza);
      l_clientes(l_idx).resumen.prioridad := r.dsc_prioridad;
      l_clientes(l_idx).resumen.usado_en_sao := r.usado_en_sao;
      l_clientes(l_idx).resumen.stock := r.stock;
      l_clientes(l_idx).resumen.valor := r.valor;
      l_clientes(l_idx).resumen.ranking := r.ranking;
      l_idx := l_idx + 1;
    end loop;
    return l_clientes;
  end;

  function faltante_resumen(
    p_cliente    varchar2
  , p_simulacion varchar2
  , p_urgente    varchar2
  , p_faltante   number
  , p_valor      number
  , p_dias       number
  ) return resumen_aat is
    l_resumen resumen_aat;
    l_idx     binary_integer := 1;
  begin
    for r in (
        with faltantes as (
          select a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op, a.cant_faltante, a.stock_requerida
               , a.saldo_op, a.consumo_anual, min(j.orden_prioridad) as min_orden_prioridad
               , sum(p.cantidad) as cantidad, a.stock, sum(j.valor) as valor
               , min(j.ranking) as ranking
            from vw_surte_jgo j
                 join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
                 join vw_articulo a on p.cod_pza = a.cod_art
           where j.id_color in ('R', 'F')
             and p.id_color = 'F'
             and p.es_sao = 'NO'
             and ((j.cod_cliente = p_cliente or p_cliente is null) and
                  (j.es_simulacion like p_simulacion) and
                  (j.es_urgente like p_urgente) and
                  (sysdate - j.fch_pedido > p_dias or p_dias is null) and
                  ((j.cant_faltante <= p_faltante or p_faltante is null) and
                   (j.valor >= p_valor or p_valor is null)))
           group by a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op, a.cant_faltante
                  , a.stock_requerida, a.saldo_op, a.consumo_anual, a.stock
           order by ranking, dsc_grupo, cod_pza
          )
           , sao as (
          select s.cod_sao
            from vw_surte_pza p
                 join vw_surte_sao s
                      on p.nro_pedido = s.nro_pedido
                        and p.itm_pedido = s.itm_pedido
                        and p.cod_pza = s.cod_pza
           group by s.cod_sao
          )
      select f.dsc_grupo, f.cod_pza, f.cod_lin, f.numero_op, f.cant_faltante, f.stock_requerida
           , f.saldo_op, f.consumo_anual, f.min_orden_prioridad, f.cantidad, p.dsc_prioridad
           , case when s.cod_sao is not null then '*' end as usado_en_sao, f.stock, f.valor
           , f.ranking
        from faltantes f
             left join prioridad_pedidos p on f.min_orden_prioridad = p.orden
             left join sao s on f.cod_pza = s.cod_sao
      )
    loop
      l_resumen(l_idx).dsc_grupo := r.dsc_grupo;
      l_resumen(l_idx).cod_pza := r.cod_pza;
      l_resumen(l_idx).cod_lin := r.cod_lin;
      l_resumen(l_idx).cantidad := r.cantidad;
      l_resumen(l_idx).ordenes := r.numero_op;
      l_resumen(l_idx).faltante_total := r.cant_faltante;
      l_resumen(l_idx).faltante_sin_stock := r.cant_faltante - r.stock_requerida;
      l_resumen(l_idx).cantidad_op := r.saldo_op;
      l_resumen(l_idx).por_emitir := cant_emitir(r.cant_faltante, r.saldo_op);
      l_resumen(l_idx).consumo_anual := r.consumo_anual;
      l_resumen(l_idx).material := surte_util.material(r.cod_pza);
      l_resumen(l_idx).ribete := surte_util.ribete(r.cod_pza);
      l_resumen(l_idx).subpieza := surte_util.subpieza(r.cod_pza);
      l_resumen(l_idx).prioridad := r.dsc_prioridad;
      l_resumen(l_idx).usado_en_sao := r.usado_en_sao;
      l_resumen(l_idx).stock := r.stock;
      l_resumen(l_idx).valor := r.valor;
      l_resumen(l_idx).ranking := r.ranking;
      l_idx := l_idx + 1;
    end loop;
    return l_resumen;
  end;

  function faltante_resumen_sao(
    p_cliente    varchar2
  , p_simulacion varchar2
  , p_urgente    varchar2
  , p_faltante   number
  , p_valor      number
  , p_dias       number
  ) return resumen_aat is
    l_resumen resumen_aat;
    l_idx     binary_integer := 1;
  begin
    for r in (
      select a.dsc_grupo, p.cod_pza, s.cod_sao, a.cod_lin, a.numero_op, a.cant_faltante
           , a.stock_requerida, a.saldo_op, a.consumo_anual
           , sum(s.cantidad) as cantidad
        from vw_surte_jgo j
             join vw_surte_pza p
                  on j.nro_pedido = p.nro_pedido
                    and j.itm_pedido = p.itm_pedido
             join vw_surte_sao s
                  on p.nro_pedido = s.nro_pedido
                    and p.itm_pedido = s.itm_pedido
                    and p.cod_pza = s.cod_pza
             join vw_articulo a on s.cod_pza = a.cod_art
       where p.id_color = 'F'
         and s.id_color = 'F'
         and p.es_sao = 'SI'
         and ((j.cod_cliente = p_cliente or p_cliente is null) and
              (j.es_simulacion like p_simulacion) and
              (j.es_urgente like p_urgente) and
              (sysdate - j.fch_pedido > p_dias or p_dias is null) and
              ((j.cant_faltante <= p_faltante or p_faltante is null) and
               (j.valor >= p_valor or p_valor is null)))
       group by a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op, a.cant_faltante, a.stock_requerida
              , a.saldo_op, a.consumo_anual, s.cod_sao
       order by dsc_grupo, cod_pza
      )
    loop
      l_resumen(l_idx).dsc_grupo := r.dsc_grupo;
      l_resumen(l_idx).cod_for := r.cod_pza;
      l_resumen(l_idx).cod_pza := r.cod_sao;
      l_resumen(l_idx).cod_lin := r.cod_lin;
      l_resumen(l_idx).cantidad := r.cantidad;
      l_resumen(l_idx).ordenes := r.numero_op;
      l_resumen(l_idx).faltante_total := r.cant_faltante;
      l_resumen(l_idx).faltante_sin_stock := r.cant_faltante - r.stock_requerida;
      l_resumen(l_idx).cantidad_op := r.saldo_op;
      l_resumen(l_idx).por_emitir := cant_emitir(r.cant_faltante, r.saldo_op);
      l_resumen(l_idx).consumo_anual := r.consumo_anual;
      l_resumen(l_idx).material := surte_util.material(r.cod_pza);
      l_resumen(l_idx).ribete := surte_util.ribete(r.cod_pza);
      l_resumen(l_idx).subpieza := surte_util.subpieza(r.cod_pza);
      l_idx := l_idx + 1;
    end loop;
    return l_resumen;
  end;

  function faltante_detalle(
    p_cliente    varchar2
  , p_simulacion varchar2
  , p_urgente    varchar2
  , p_faltante   number
  , p_valor      number
  , p_dias       number
  ) return detalle_aat is
    l_detalle detalle_aat;
    l_idx     binary_integer := 1;
  begin
    for r in (
        with faltantes as (
          select j.nro_pedido, j.itm_pedido, j.cod_cliente, j.nom_cliente, j.cod_jgo, a.dsc_grupo
               , p.cod_pza, a.cod_lin, a.numero_op, sum(p.cantidad) as cantidad, a.cant_faltante
               , a.stock_requerida, a.saldo_op, a.consumo_anual, a.stock, j.valor, j.fch_pedido
               , min(j.orden_prioridad) as min_orden_prioridad, j.ranking
               , trunc(sysdate - j.fch_pedido) as dias_atraso
            from vw_surte_jgo j
                 join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
                 join vw_articulo a on p.cod_pza = a.cod_art
           where j.id_color in ('R', 'F')
             and p.id_color = 'F'
             and p.es_sao = 'NO'
             and ((j.cod_cliente = p_cliente or p_cliente is null) and
                  (j.es_simulacion like p_simulacion) and
                  (j.es_urgente like p_urgente) and
                  (sysdate - j.fch_pedido > p_dias or p_dias is null) and
                  ((j.cant_faltante <= p_faltante or p_faltante is null) and
                   (j.valor >= p_valor or p_valor is null)))
           group by j.cod_cliente, j.nom_cliente, a.dsc_grupo, p.cod_pza, a.cod_lin, a.numero_op
                  , a.cant_faltante, a.stock_requerida, a.saldo_op, a.consumo_anual, j.nro_pedido
                  , j.itm_pedido, j.cod_jgo, a.stock, j.valor, j.fch_pedido, j.ranking
           order by dsc_grupo, ranking, cod_cliente, cod_pza
          )
           , sao as (
          select p.cod_cliente, p.nom_cliente, s.cod_sao
            from vw_surte_pza p
                 join vw_surte_sao s
                      on p.nro_pedido = s.nro_pedido
                        and p.itm_pedido = s.itm_pedido
                        and p.cod_pza = s.cod_pza
           group by p.cod_cliente, p.nom_cliente, s.cod_sao
          )
      select f.nro_pedido, f.itm_pedido, f.cod_cliente, f.nom_cliente, f.cod_jgo, f.dsc_grupo
           , f.cod_pza, f.cod_lin, f.numero_op, f.cantidad, f.cant_faltante, f.stock_requerida
           , f.saldo_op, f.consumo_anual, p.dsc_prioridad, f.stock, f.valor, f.fch_pedido, f.ranking
           , case when s.cod_sao is not null then '*' end as usado_en_sao, f.dias_atraso
        from faltantes f
             left join prioridad_pedidos p on f.min_orden_prioridad = p.orden
             left join sao s on f.cod_cliente = s.cod_cliente and f.cod_pza = s.cod_sao
      )
    loop
      l_detalle(l_idx).nro_pedido := r.nro_pedido;
      l_detalle(l_idx).itm_pedido := r.itm_pedido;
      l_detalle(l_idx).valor := r.valor;
      l_detalle(l_idx).fch_pedido := r.fch_pedido;
      l_detalle(l_idx).dias_atraso := r.dias_atraso;
      l_detalle(l_idx).ranking := r.ranking;
      l_detalle(l_idx).cliente.cod_cliente := r.cod_cliente;
      l_detalle(l_idx).cliente.nom_cliente := r.nom_cliente;
      l_detalle(l_idx).cliente.resumen.dsc_grupo := r.dsc_grupo;
      l_detalle(l_idx).cliente.resumen.cod_for := r.cod_jgo;
      l_detalle(l_idx).cliente.resumen.cod_pza := r.cod_pza;
      l_detalle(l_idx).cliente.resumen.cod_lin := r.cod_lin;
      l_detalle(l_idx).cliente.resumen.cantidad := r.cantidad;
      l_detalle(l_idx).cliente.resumen.ordenes := r.numero_op;
      l_detalle(l_idx).cliente.resumen.faltante_total := r.cant_faltante;
      l_detalle(l_idx).cliente.resumen.faltante_sin_stock := r.cant_faltante - r.stock_requerida;
      l_detalle(l_idx).cliente.resumen.cantidad_op := r.saldo_op;
      l_detalle(l_idx).cliente.resumen.por_emitir := cant_emitir(r.cant_faltante, r.saldo_op);
      l_detalle(l_idx).cliente.resumen.consumo_anual := r.consumo_anual;
      l_detalle(l_idx).cliente.resumen.material := surte_util.material(r.cod_pza);
      l_detalle(l_idx).cliente.resumen.ribete := surte_util.ribete(r.cod_pza);
      l_detalle(l_idx).cliente.resumen.subpieza := surte_util.subpieza(r.cod_pza);
      l_detalle(l_idx).cliente.resumen.prioridad := r.dsc_prioridad;
      l_detalle(l_idx).cliente.resumen.stock := r.stock;
      l_detalle(l_idx).cliente.resumen.usado_en_sao := r.usado_en_sao;
      l_idx := l_idx + 1;
    end loop;
    return l_detalle;
  end;

  function faltante_importe_atraso(
    p_cliente    varchar2
  , p_simulacion varchar2
  , p_urgente    varchar2
  , p_faltante   number
  , p_valor      number
  , p_dias       number
  ) return dias_aat is
    l_atraso dias_aat;
    l_idx    binary_integer := 1;
  begin
    for r in (
        with pedidos as (
          select j.cod_cliente, j.nom_cliente, j.nro_pedido, j.itm_pedido, j.valor, j.fch_pedido
               , j.ranking, trunc(sysdate) - j.fch_pedido as dias
            from vw_surte_jgo j
                 join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
                 join vw_articulo a on p.cod_pza = a.cod_art
           where j.id_color in ('R', 'F')
             and p.id_color = 'F'
             and p.es_sao = 'NO'
             and ((j.cod_cliente = p_cliente or p_cliente is null) and
                  (j.es_simulacion like p_simulacion) and
                  (j.es_urgente like p_urgente) and
                  (sysdate - j.fch_pedido > p_dias or p_dias is null) and
                  ((j.cant_faltante <= p_faltante or p_faltante is null) and
                   (j.valor >= p_valor or p_valor is null)))
           group by j.cod_cliente, j.nom_cliente, j.nro_pedido, j.itm_pedido, j.valor, j.fch_pedido
                  , j.ranking
          )
      select p.cod_cliente, p.nom_cliente
           , sum(case when dias >= 90 and dias < 180 then valor else 0 end) as entre_90_180_dias
           , sum(case when dias >= 180 and dias < 360 then valor else 0 end) as entre_180_360_dias
           , sum(case when dias >= 360 then valor else 0 end) as mas_360_dias
           , sum(case when dias >= 90 then valor else 0 end) as mas_90_dias
           , sum(case when dias < 90 then valor else 0 end) as menos_90_dias
           , sum(valor) as total
           , min(p.ranking) as ranking
        from pedidos p
       group by p.cod_cliente, p.nom_cliente
       order by ranking
      )
    loop
      l_atraso(l_idx).cod_cliente := r.cod_cliente;
      l_atraso(l_idx).nom_cliente := r.nom_cliente;
      l_atraso(l_idx).entre_90_180_dias := r.entre_90_180_dias;
      l_atraso(l_idx).entre_180_360_dias := r.entre_180_360_dias;
      l_atraso(l_idx).mas_360_dias := r.mas_360_dias;
      l_atraso(l_idx).mas_90_dias := r.mas_90_dias;
      l_atraso(l_idx).menos_90_dias := r.menos_90_dias;
      l_atraso(l_idx).total := r.total;
      l_atraso(l_idx).ranking := r.ranking;
      l_idx := l_idx + 1;
    end loop;
    return l_atraso;
  end;
end surte_reporte;
/
