create or replace package body surte_parte as
  gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
  gc_multiplo_partir constant simple_integer := 5;

  procedure parte_ot(
    p_tipo        pr_ot.nuot_tipoot_codigo%type
  , p_serie       pr_ot.nuot_serie%type
  , p_numero      pr_ot.numero%type
  , p_cant_partir pr_ot.cant_prog%type
  ) is
    g_ot     pr_ot%rowtype;
    g_nro    pr_ot.numero%type;

    -- <editor-fold desc="logger">
    l_scope  logger_logs.scope%type := gc_scope_prefix || 'parte_ot';
    l_params logger.tab_param;
    -- </editor-fold>

    function nuevo_numero(
      p_tipo  pr_num_ot.tipoot_codigo%type
    , p_serie pr_num_ot.serie%type
    ) return pr_ot.numero%type is
      l_nro pr_ot.numero%type;
    begin
      select numero + 1
        into l_nro
        from pr_num_ot
       where tipoot_codigo = p_tipo
         and serie = p_serie
         for update of numero;

      update pr_num_ot
         set numero = l_nro
       where tipoot_codigo = p_tipo
         and serie = p_serie;

      return l_nro;
    end;

    function crea_item_pedido_exp(
      p_numero     expedido_d.numero%type
    , p_item       expedido_d.nro%type
    , p_cant_sobra expedido_d.canti%type
    ) return expedido_d%rowtype is
      l_old_item_ped expedido_d%rowtype;
      l_new_item_ped expedido_d%rowtype;

      function crea_nuevo(
        p_old_item_ped expedido_d%rowtype
      ) return expedido_d%rowtype is
        l_new expedido_d%rowtype;
      begin
        l_new := p_old_item_ped;
        l_new.nro := api_expedido_d.next_key(p_numero);
        l_new.canti := p_cant_sobra;
        l_new.totlin := p_cant_sobra * l_new.preuni;
        l_new.saldo_ot := p_cant_sobra;
        l_new.saldo_pk := p_cant_sobra;
        l_new.estado_pk := 'A1';
        l_new.indicador_armado := 'S';
        api_expedido_d.ins(l_new);
        return l_new;
      end;

      procedure actualiza_antiguo(
        p_old_item_ped expedido_d%rowtype
      ) is
        l_old expedido_d%rowtype;
      begin
        l_old := p_old_item_ped;
        l_old.canti := p_cant_partir;
        l_old.totlin := p_cant_partir * p_old_item_ped.preuni;
        l_old.saldo_pk := p_cant_partir;
        api_expedido_d.upd(l_old);
      end;
    begin
      l_old_item_ped := api_expedido_d.onerow(p_numero, p_item);
      l_new_item_ped := crea_nuevo(l_old_item_ped);
      actualiza_antiguo(l_old_item_ped);
      return l_new_item_ped;
    end;

    function crea_item_pedido_nac(
      p_numero     expednac_d.numero%type
    , p_item       expednac_d.nro%type
    , p_cant_sobra expednac_d.canti%type
    ) return expednac_d%rowtype is
      l_old_item_ped expednac_d%rowtype;
      l_new_item_ped expednac_d%rowtype;

      function crea_nuevo(
        p_old_item_ped expednac_d%rowtype
      ) return expednac_d%rowtype is
        l_new expednac_d%rowtype;
      begin
        l_new := p_old_item_ped;
        l_new.nro := api_expednac_d.next_key(p_numero);
        l_new.canti := p_cant_sobra;
        l_new.totlin := p_cant_sobra * l_new.preuni;
        l_new.saldo_ot := p_cant_sobra;
        l_new.saldo_pk := p_cant_sobra;
        l_new.estado_pk := 'A1';
        api_expednac_d.ins(l_new);
        return l_new;
      end;

      procedure actualiza_antiguo(
        p_old_item_ped expednac_d%rowtype
      ) is
        l_old expednac_d%rowtype;
      begin
        l_old := p_old_item_ped;
        l_old.canti := p_cant_partir;
        l_old.totlin := p_cant_partir * p_old_item_ped.preuni;
        l_old.saldo_pk := p_cant_partir;
        api_expednac_d.upd(l_old);
      end;
    begin
      l_old_item_ped := api_expednac_d.onerow(p_numero, p_item);
      l_new_item_ped := crea_nuevo(l_old_item_ped);
      actualiza_antiguo(l_old_item_ped);
      return l_new_item_ped;
    end;

    procedure guarda_ot(
      p_ot         pr_ot%rowtype
    , p_ped_nro    expedido_d.numero%type
    , p_ped_itm    expedido_d.nro%type
    , p_cant_sobra number
    ) is
    begin
      g_nro := nuevo_numero(p_ot.nuot_tipoot_codigo, p_ot.nuot_serie);

      insert into pr_ot
      values ( g_nro, sysdate, 1, p_cant_sobra, p_ot.nuot_serie
             , p_ot.nuot_tipoot_codigo, 'ORDEN :' || p_ot.numero, 0, null, null
             , null, 'S', 1, 0, p_ot.formu_art_cod_art
             , 1, p_ot.cdc_centro_costo, null, 0, 'S'
             , null, null, 0, p_ot.hora_fab, null
             , null, null, p_ped_itm, null, null
             , null, p_ped_nro, p_ot.abre02, null, p_ot.destino
             , p_ot.plazo, p_ot.fecha_plazo, p_ot.cod_eqi, p_ot.pais, p_ot.empaque
             , user, 'PARTIDA', p_ot.embalaje, p_ot.prioridad, 0
             , p_ot.fecha_prioridad, p_ot.cod_lin, 0, 0, 0);
    end;

    procedure crea_maestro_ot(
      p_cant_sobra number
    ) is
      l_ped_exp expedido_d%rowtype;
      l_ped_nac expednac_d%rowtype;
    begin
      if g_ot.destino = '1' then
        l_ped_exp := crea_item_pedido_exp(g_ot.abre01, g_ot.per_env, p_cant_sobra);
        guarda_ot(g_ot, l_ped_exp.numero, l_ped_exp.nro, p_cant_sobra);
      else
        l_ped_nac := crea_item_pedido_nac(g_ot.abre01, g_ot.per_env, p_cant_sobra);
        guarda_ot(g_ot, l_ped_nac.numero, l_ped_nac.nro, p_cant_sobra);
      end if;
    end;

    procedure crea_detalle_ot(
      p_cant_sobra number
    ) is
      l_articulo   articul%rowtype;
      l_formula    pr_formu%rowtype;
      l_cant_total number := 0;
    begin
      for r in (
        select *
          from pr_ot_det
         where ot_nuot_tipoot_codigo = p_tipo
           and ot_nuot_serie = p_serie
           and ot_numero = p_numero
           and nvl(estado, '0') != '9'
        )
      loop
        l_articulo := api_articul.onerow(r.art_cod_art);
        l_formula := api_pr_formu.onerow(r.art_cod_art, 1);
        l_cant_total := round((p_cant_sobra * r.rendimiento) / nvl(l_formula.lote, 1), 2);

        insert into pr_ot_det
        values ( l_cant_total, r.cant_usada, r.cost_formula, r.cost_usada, r.almacen
               , g_nro, g_ot.nuot_serie, g_ot.nuot_tipoot_codigo, r.art_cod_art, r.cant_despachada
               , r.rendimiento, l_articulo.cod_lin, r.pr_secuencia, r.flag_kardex, 1
               , r.prioridad, r.fecha_prioridad, 0, 0);
      end loop;
    end;

    procedure crea_nueva_ot(
      p_cant_sobra number
    ) is
    begin
      crea_maestro_ot(p_cant_sobra);
      crea_detalle_ot(p_cant_sobra);
    end;

    procedure actualiza_maestro(
      p_cant_parte number
    ) is
      l_old pr_ot%rowtype;
    begin
      l_old := g_ot;
      l_old.cant_prog := p_cant_parte;
      l_old.saldo_pk := p_cant_parte;
      api_pr_ot.upd(l_old);
    end;

    procedure actualiza_detalle(
      p_cant_parte number
    ) is
      l_old     pr_ot_det%rowtype;
      l_formula pr_formu%rowtype;
    begin
      for r in (
        select *
          from pr_ot_det
         where ot_nuot_tipoot_codigo = p_tipo
           and ot_nuot_serie = p_serie
           and ot_numero = p_numero
           and nvl(estado, '0') != '9'
        )
      loop
        l_old := r;
        l_formula := api_pr_formu.onerow(r.art_cod_art, 1);
        l_old.cant_formula := round((p_cant_parte * r.rendimiento) / nvl(l_formula.lote, 1), 2);
        api_pr_ot_det.upd(l_old);
      end loop;
    end;

    procedure actualiza_antigua_ot(
      p_cant_parte number
    ) is
    begin
      actualiza_maestro(p_cant_parte);
      actualiza_detalle(p_cant_parte);
    end;
  begin
    -- <editor-fold desc="logger">
    logger.append_param(l_params, 'p_tipo', p_tipo);
    logger.append_param(l_params, 'p_serie', p_serie);
    logger.append_param(l_params, 'p_numero', p_numero);
    logger.append_param(l_params, 'p_cant_partir', p_cant_partir);
    -- </editor-fold>
    declare
      l_cant_sobra pr_ot.cant_prog%type;
    begin
      g_ot := api_pr_ot.onerow(p_numero, p_serie, p_tipo);
      l_cant_sobra := g_ot.cant_prog - p_cant_partir;
      crea_nueva_ot(l_cant_sobra);
      actualiza_antigua_ot(p_cant_partir);
    end;
  exception
    when others then
      -- <editor-fold desc="logger">
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- </editor-fold>
      raise;
  end;


  procedure ot_masivo is
  begin
    for r in (
      select *
        from vw_surte_jgo j
       where j.id_color = surte_color.gc_partir
         and exists(
           select 1
             from tmp_imprime_ot t
            where j.ot_tipo = t.tpo_ot
              and j.ot_serie = t.ser_ot
              and j.ot_numero = t.nro_ot
         )
       order by ranking
      )
    loop
      parte_ot(r.ot_tipo, r.ot_serie, r.ot_numero, r.cant_partir);
    end loop;
  end;

  procedure ot_masivo(
    p_prioritario pls_integer
  ) is
  begin
    for r in (
      select *
        from vw_surte_jgo
       where se_puede_partir = 'SI'
         and (p_prioritario = 1 or (p_prioritario = 0 and es_prioritario = 'NO'))
       order by ranking
      )
    loop
      parte_ot(r.ot_tipo, r.ot_serie, r.ot_numero, r.cant_partir);
    end loop;
  end;
end surte_parte;