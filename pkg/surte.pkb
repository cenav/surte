create or replace package body surte as
  gc_multiplo_partir constant simple_integer := 5;

  subtype string_t is varchar2(32672);
  subtype stock_t is number;
  subtype codart_t is articul.cod_art%type;
  subtype ranking_t is pls_integer;

  type calculo_rt is record (
    stock_actual number,
    rendimiento  number,
    faltante     number,
    cant_final   number
  );

  type detalle_rt is record (
    cod_art         tmp_ordenes_surtir.cod_art%type,
    cantidad        tmp_ordenes_surtir.cantidad%type,
    rendimiento     tmp_ordenes_surtir.rendimiento%type,
    stock_inicial   tmp_ordenes_surtir.stock_inicial%type,
    stock_actual    tmp_ordenes_surtir.stock_actual%type,
    saldo_stock     tmp_ordenes_surtir.saldo_stock%type,
    sobrante        tmp_ordenes_surtir.sobrante%type,
    faltante        tmp_ordenes_surtir.faltante%type,
    cant_final      tmp_ordenes_surtir.cant_final%type,
    linea           tmp_ordenes_surtir.linea%type,
    es_importado    tmp_ordenes_surtir.es_importado%type,
    tiene_stock_itm tmp_ordenes_surtir.tiene_stock_itm%type
  );

  type detalle_aat is table of detalle_rt index by pls_integer;

  type maestro_rt is record (
    ranking         tmp_ordenes_surtir.ranking%type,
    cod_cliente     tmp_ordenes_surtir.cod_cliente%type,
    nom_cliente     tmp_ordenes_surtir.nom_cliente%type,
    nro_pedido      tmp_ordenes_surtir.nro_pedido%type,
    itm_pedido      tmp_ordenes_surtir.itm_pedido%type,
    fch_pedido      tmp_ordenes_surtir.fch_pedido%type,
    ot_tipo         tmp_ordenes_surtir.ot_tipo%type,
    ot_serie        tmp_ordenes_surtir.ot_serie%type,
    ot_numero       tmp_ordenes_surtir.ot_numero%type,
    ot_estado       tmp_ordenes_surtir.ot_estado%type,
    formu_art       tmp_ordenes_surtir.formu_art%type,
    es_juego        tmp_ordenes_surtir.es_juego%type,
    tiene_importado tmp_ordenes_surtir.tiene_importado%type,
    preuni          tmp_ordenes_surtir.preuni%type,
    valor           tmp_ordenes_surtir.valor%type,
    valor_surtir    tmp_ordenes_surtir.valor_surtir%type,
    impreso         tmp_ordenes_surtir.impreso%type,
    fch_impresion   tmp_ordenes_surtir.fch_impresion%type,
    partir_ot       tmp_ordenes_surtir.partir_ot%type,
    cant_partir     tmp_ordenes_surtir.cant_partir%type,
    tiene_stock_ot  tmp_ordenes_surtir.tiene_stock_ot%type,
    detalle         detalle_aat
  );

  type stock_aat is table of stock_t index by codart_t;
  type pedidos_aat is table of maestro_rt index by ranking_t;
  type tmp_aat is table of tmp_ordenes_surtir%rowtype index by pls_integer;
  type calculo_aat is table of calculo_rt index by pls_integer;

  bulk_errors exception;
  pragma exception_init (bulk_errors, -24381);

  cursor pedidos_cur(p_pais varchar2, p_vendedor varchar2, p_dias pls_integer) is
    -- pedidos de clientes ordenados primero por juegos, luego de mayor a menor valor
      with detalle as (
        select v.cod_cliente, v.nombre, v.fch_pedido, v.pedido, v.pedido_item, v.nuot_serie
             , v.nuot_tipoot_codigo, v.numero, v.fecha, v.formu_art_cod_art, v.estado, v.art_cod_art
             , v.cant_formula, v.rendimiento, v.saldo, v.despachar, v.cod_lin, v.abre02, v.preuni, v.valor
             , v.stock, v.tiene_stock, v.tiene_stock_ot, v.tiene_stock_item, v.tiene_importado, v.impreso
             , v.fch_impresion, v.es_juego, v.es_importado
             , case when lag(v.numero) over (order by null) = v.numero then null else v.numero end oa
             , dense_rank() over (
          order by case when p.prioritario = 1 then v.es_prioritario end desc
            , case when trunc(sysdate) - v.fch_pedido > p_dias then 1 else 0 end desc
            , case when v.valor > p.valor_item then 1 else 0 end desc
            , v.es_juego
            , v.valor desc
          ) as ranking
          from vw_ordenes_pedido_pendiente v
               join param_surte p on p.id_param = 1
         where (v.pais = p_pais or p_pais is null)
           and (v.vendedor = p_vendedor or p_vendedor is null)
           and (exists(select * from tmp_selecciona_cliente t where v.cod_cliente = t.cod_cliente) or
                not exists(select * from tmp_selecciona_cliente))
--          where numero in (801975)
        )
    select *
      from detalle
     order by ranking;

  -- private routines
  function carga_stock return stock_aat is
    l_stocks stock_aat;
  begin
    for r in (select distinct art_cod_art, stock from vw_ordenes_pedido_pendiente) loop
      l_stocks(r.art_cod_art) := r.stock;
    end loop;

    return l_stocks;
  end;

  -- public routines
  procedure por_cliente(
    p_cliente varchar2
  , p_opcion  opcion_enum.t_opcion
  ) is
  begin
    delete tmp_ordenes_surtir;

    case p_opcion
      when opcion_enum.fecha then
        insert into tmp_ordenes_surtir( cod_cliente, nom_cliente, nro_pedido, itm_pedido, fch_pedido, ot_tipo
                                      , ot_serie, ot_numero, formu_art, ot_estado, tiene_stock_ot, valor
                                      , cod_art, cantidad, saldo_stock, faltante, linea, tiene_stock_itm
                                      , impreso, fch_impresion, stock_inicial)
        select cod_cliente, nombre, pedido, pedido_item, fch_pedido, nuot_tipoot_codigo, nuot_serie, numero
             , formu_art_cod_art, estado, tiene_stock_ot_fch, valor, art_cod_art, cant_formula
             , stock_saldo_fch, faltante_fch, cod_lin, tiene_stock_item_fch, impreso, fch_impresion
             , stock_inicial
          from vw_surte_cliente
         where cod_cliente like p_cliente
         order by fch_pedido;
      when opcion_enum.valor then
        insert into tmp_ordenes_surtir( cod_cliente, nom_cliente, nro_pedido, itm_pedido, fch_pedido, ot_tipo
                                      , ot_serie, ot_numero, formu_art, ot_estado, tiene_stock_ot, valor
                                      , cod_art, cantidad, saldo_stock, faltante, linea, tiene_stock_itm
                                      , impreso, fch_impresion, stock_inicial)
        select cod_cliente, nombre, pedido, pedido_item, fch_pedido, nuot_tipoot_codigo, nuot_serie, numero
             , formu_art_cod_art, estado, tiene_stock_ot_val, valor, art_cod_art, cant_formula
             , stock_saldo_val, faltante_val, cod_lin, tiene_stock_item_val, impreso, fch_impresion
             , stock_inicial
          from vw_surte_cliente
         where cod_cliente like p_cliente
         order by valor desc;
    end case;

    commit;
  end;

  procedure por_item(
    p_pais     varchar2 default null
  , p_vendedor varchar2 default null
  , p_dias     pls_integer default null
  ) is
    g_stocks  stock_aat;
    g_pedidos pedidos_aat;
    g_tmp     tmp_aat;
    g_param   param_surte%rowtype;

    procedure init is
    begin
      g_stocks := carga_stock();
      g_param := api_param_surte.onerow();
    end;

    function saldo_stock(
      p_codart articul.cod_art%type
    , p_cant   number
    ) return number is
    begin
      g_stocks(p_codart) := g_stocks(p_codart) - p_cant;
      return g_stocks(p_codart);
    end;

    procedure agrega_stock(
      p_codart articul.cod_art%type
    , p_cant   number
    ) is
    begin
      g_stocks(p_codart) := g_stocks(p_codart) + p_cant;
    end;

    function faltante(
      p_stock_actual number
    ) return number is
    begin
      return case when p_stock_actual < 0 then abs(p_stock_actual) else 0 end;
    end;

    procedure crea_maestro(
      r pedidos_cur%rowtype
    ) is
    begin
      g_pedidos(r.ranking).ranking := r.ranking;
      g_pedidos(r.ranking).cod_cliente := r.cod_cliente;
      g_pedidos(r.ranking).nom_cliente := r.nombre;
      g_pedidos(r.ranking).nro_pedido := r.pedido;
      g_pedidos(r.ranking).itm_pedido := r.pedido_item;
      g_pedidos(r.ranking).fch_pedido := r.fch_pedido;
      g_pedidos(r.ranking).preuni := r.preuni;
      g_pedidos(r.ranking).valor := r.valor;
      g_pedidos(r.ranking).ot_tipo := r.nuot_tipoot_codigo;
      g_pedidos(r.ranking).ot_serie := r.nuot_serie;
      g_pedidos(r.ranking).ot_numero := r.numero;
      g_pedidos(r.ranking).ot_estado := r.estado;
      g_pedidos(r.ranking).formu_art := r.formu_art_cod_art;
      g_pedidos(r.ranking).es_juego := r.es_juego;
      g_pedidos(r.ranking).tiene_importado := r.tiene_importado;
      g_pedidos(r.ranking).impreso := r.impreso;
      g_pedidos(r.ranking).fch_impresion := r.fch_impresion;
      g_pedidos(r.ranking).tiene_stock_ot := null;
    end;

    procedure crea_detalle(
      r pedidos_cur%rowtype
    ) is
      l_idx pls_integer := 0;
    begin
      l_idx := g_pedidos(r.ranking).detalle.count + 1;
      g_pedidos(r.ranking).detalle(l_idx).cod_art := r.art_cod_art;
      g_pedidos(r.ranking).detalle(l_idx).cantidad := r.cant_formula;
      g_pedidos(r.ranking).detalle(l_idx).stock_inicial := r.stock;
      g_pedidos(r.ranking).detalle(l_idx).saldo_stock := null;
      g_pedidos(r.ranking).detalle(l_idx).faltante := null;
      g_pedidos(r.ranking).detalle(l_idx).linea := r.cod_lin;
      g_pedidos(r.ranking).detalle(l_idx).es_importado := r.es_importado;
      g_pedidos(r.ranking).detalle(l_idx).rendimiento := r.rendimiento;
      g_pedidos(r.ranking).detalle(l_idx).tiene_stock_itm := null;
    end;

    procedure regresa_stock(
      p_idx pls_integer
    ) is
    begin
      g_pedidos(p_idx).tiene_stock_ot := 'NO';
      for j in 1 .. g_pedidos(p_idx).detalle.count loop
        agrega_stock(g_pedidos(p_idx).detalle(j).cod_art, g_pedidos(p_idx).detalle(j).cantidad);
        g_pedidos(p_idx).detalle(j).saldo_stock := null;
        g_pedidos(p_idx).detalle(j).sobrante := null;
        g_pedidos(p_idx).detalle(j).faltante := null;
      end loop;
    end;

    procedure actualiza_saldo(
      p_idx     pls_integer
    , p_calculo calculo_aat
    ) is
      l_codart codart_t;
    begin
      g_pedidos(p_idx).tiene_stock_ot := 'SI';
      g_pedidos(p_idx).valor_surtir := g_pedidos(p_idx).valor;
      g_pedidos(p_idx).partir_ot := 0;
      for j in 1 .. g_pedidos(p_idx).detalle.count loop
        l_codart := g_pedidos(p_idx).detalle(j).cod_art;
        g_pedidos(p_idx).detalle(j).stock_actual := p_calculo(j).stock_actual;
        g_pedidos(p_idx).detalle(j).saldo_stock := g_stocks(l_codart) - p_calculo(j).cant_final;
        g_pedidos(p_idx).detalle(j).cant_final := p_calculo(j).cant_final;
        g_stocks(g_pedidos(p_idx).detalle(j).cod_art) :=
              g_stocks(l_codart) - g_pedidos(p_idx).detalle(j).cant_final;
      end loop;
    end;

    function find_min(
      p_calculo calculo_aat
    ) return number is
      l_min number;
    begin
      l_min := p_calculo(1).cant_final;
      for i in 1 .. p_calculo.count loop
        if p_calculo(i).cant_final < l_min then
          l_min := p_calculo(i).cant_final;
        end if;
      end loop;
      return l_min;
    end;

    procedure prueba_partir(
      io_calculo in out calculo_aat
    , p_cant_partir     number
    , o_es_partible out boolean
    ) is
    begin
      o_es_partible := true;
      for i in 1 .. io_calculo.count loop
        if p_cant_partir * io_calculo(i).rendimiento <= io_calculo(i).cant_final then
          io_calculo(i).cant_final := p_cant_partir * io_calculo(i).rendimiento;
        else
          o_es_partible := false;
        end if;
      end loop;
    end;

    procedure parte_orden(
      p_idx             pls_integer
    , io_calculo in out calculo_aat
    ) is
      l_codart           codart_t;
      l_cant_partir      number;
      l_valor_surtir     number;
      l_es_partible      boolean;
      l_cumple_valor_min boolean;
    begin
      g_pedidos(p_idx).tiene_stock_ot := 'NO';
      l_cant_partir := multiplo.inferior(find_min(io_calculo), gc_multiplo_partir);
      prueba_partir(io_calculo, l_cant_partir, l_es_partible);
      l_valor_surtir := l_cant_partir * g_pedidos(p_idx).preuni;
      l_cumple_valor_min := l_valor_surtir >= g_param.valor_partir;
      if l_es_partible and l_cumple_valor_min then
        g_pedidos(p_idx).partir_ot := 1;
        g_pedidos(p_idx).cant_partir := l_cant_partir;
        g_pedidos(p_idx).valor_surtir := l_valor_surtir;
        for j in 1 .. g_pedidos(p_idx).detalle.count loop
          l_codart := g_pedidos(p_idx).detalle(j).cod_art;
          g_pedidos(p_idx).detalle(j).stock_actual := io_calculo(j).stock_actual;
          g_pedidos(p_idx).detalle(j).saldo_stock := g_stocks(l_codart) - io_calculo(j).cant_final;
          g_pedidos(p_idx).detalle(j).cant_final := io_calculo(j).cant_final;
          g_stocks(g_pedidos(p_idx).detalle(j).cod_art) :=
                g_stocks(l_codart) - g_pedidos(p_idx).detalle(j).cant_final;
        end loop;
      else
        g_pedidos(p_idx).partir_ot := 0;
      end if;
    end;

    -- por todos los items de pedidos, consume el stock
    -- progresivamente en el orden dado
    procedure consume_stock is
      l_calculo         calculo_aat;
      l_stock_actual    number  := 0;
      l_tiene_stock_ot  boolean := true;
      l_tiene_stock_itm boolean := true;
      l_puede_partirse  boolean := true;
    begin
      for i in 1 .. g_pedidos.count loop
        l_tiene_stock_ot := true;
        l_puede_partirse := true;
        l_calculo.delete();

        for j in 1 .. g_pedidos(i).detalle.count loop
          l_stock_actual := g_stocks(g_pedidos(i).detalle(j).cod_art);
          l_calculo(j).stock_actual := l_stock_actual;
          l_calculo(j).rendimiento := g_pedidos(i).detalle(j).rendimiento;
          l_tiene_stock_itm := l_stock_actual >= g_pedidos(i).detalle(j).cantidad;

          if l_tiene_stock_itm then
            l_calculo(j).cant_final := g_pedidos(i).detalle(j).cantidad;
          else
            l_tiene_stock_ot := false;
            -- busca partir la orden
            if l_stock_actual > 0 then
              l_calculo(j).cant_final := l_stock_actual;
            else
              l_puede_partirse := false;
              l_calculo(j).cant_final := 0;
            end if;
          end if;

          g_pedidos(i).detalle(j).stock_actual := l_stock_actual;
          g_pedidos(i).detalle(j).tiene_stock_itm := case when l_tiene_stock_itm then 'SI' else 'NO' end;
        end loop;

        case
          when l_tiene_stock_ot then
            actualiza_saldo(i, l_calculo);
          when l_puede_partirse then
            parte_orden(i, l_calculo);
          else
            g_pedidos(i).tiene_stock_ot := 'NO';
            g_pedidos(i).partir_ot := 0;
        end case;
      end loop;
    end;

    procedure carga_colecciones is
    begin
      for r in pedidos_cur(p_pais, p_vendedor, p_dias) loop
        -- para el primer quiebre de grupo (item pedido)
        -- normaliza la data
        if r.oa is not null then
          crea_maestro(r);
          crea_detalle(r);
        else
          crea_detalle(r);
        end if;
      end loop;
    end;

    -- porque Oracle tovadia no acepta forall con collecciones anidadas
    -- tampoco ocepta forall con colleciones indexadas por varchar2
    procedure desnormaliza is
    begin
      for i in 1 .. g_pedidos.count loop

        for j in 1 .. g_pedidos(i).detalle.count loop
          -- maestro
          g_tmp(g_tmp.count + 1).ranking := g_pedidos(i).ranking;
          g_tmp(g_tmp.count).cod_cliente := g_pedidos(i).cod_cliente;
          g_tmp(g_tmp.count).nom_cliente := g_pedidos(i).nom_cliente;
          g_tmp(g_tmp.count).nro_pedido := g_pedidos(i).nro_pedido;
          g_tmp(g_tmp.count).itm_pedido := g_pedidos(i).itm_pedido;
          g_tmp(g_tmp.count).fch_pedido := g_pedidos(i).fch_pedido;
          g_tmp(g_tmp.count).ot_tipo := g_pedidos(i).ot_tipo;
          g_tmp(g_tmp.count).ot_serie := g_pedidos(i).ot_serie;
          g_tmp(g_tmp.count).ot_numero := g_pedidos(i).ot_numero;
          g_tmp(g_tmp.count).formu_art := g_pedidos(i).formu_art;
          g_tmp(g_tmp.count).es_juego := g_pedidos(i).es_juego;
          g_tmp(g_tmp.count).tiene_importado := g_pedidos(i).tiene_importado;
          g_tmp(g_tmp.count).ot_estado := g_pedidos(i).ot_estado;
          g_tmp(g_tmp.count).tiene_stock_ot := g_pedidos(i).tiene_stock_ot;
          g_tmp(g_tmp.count).valor := g_pedidos(i).valor;
          g_tmp(g_tmp.count).valor_surtir := g_pedidos(i).valor_surtir;
          g_tmp(g_tmp.count).impreso := g_pedidos(i).impreso;
          g_tmp(g_tmp.count).fch_impresion := g_pedidos(i).fch_impresion;
          g_tmp(g_tmp.count).partir_ot := g_pedidos(i).partir_ot;
          g_tmp(g_tmp.count).cant_partir := g_pedidos(i).cant_partir;

          -- detalle
          g_tmp(g_tmp.count).cod_art := g_pedidos(i).detalle(j).cod_art;
          g_tmp(g_tmp.count).cantidad := g_pedidos(i).detalle(j).cantidad;
          g_tmp(g_tmp.count).rendimiento := g_pedidos(i).detalle(j).rendimiento;
          g_tmp(g_tmp.count).saldo_stock := g_pedidos(i).detalle(j).saldo_stock;
          g_tmp(g_tmp.count).sobrante := g_pedidos(i).detalle(j).sobrante;
          g_tmp(g_tmp.count).faltante := g_pedidos(i).detalle(j).faltante;
          g_tmp(g_tmp.count).linea := g_pedidos(i).detalle(j).linea;
          g_tmp(g_tmp.count).es_importado := g_pedidos(i).detalle(j).es_importado;
          g_tmp(g_tmp.count).tiene_stock_itm := g_pedidos(i).detalle(j).tiene_stock_itm;
          g_tmp(g_tmp.count).stock_inicial := g_pedidos(i).detalle(j).stock_inicial;
          g_tmp(g_tmp.count).cant_final := g_pedidos(i).detalle(j).cant_final;
        end loop;

      end loop;
    end;

    procedure guarda is
    begin
      delete from tmp_ordenes_surtir;

      forall i in 1 .. g_tmp.count save exceptions
        insert into tmp_ordenes_surtir values g_tmp(i);
    exception
      when bulk_errors then
        for i in 1 .. sql%bulk_exceptions.count loop
          logger.log(
                'OA: ' || g_tmp(sql%bulk_exceptions(i).error_index).ot_numero ||
                ' Articulo: ' || g_tmp(sql%bulk_exceptions(i).error_index).cod_art ||
                ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1)
            );
        end loop;

        commit;
    end;
  begin
    init();
    carga_colecciones();
    consume_stock();
    desnormaliza();
    guarda();
    commit;
  end;

  procedure parte_ot is
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
      p_numero      expedido_d.numero%type
    , p_item        expedido_d.nro%type
    , p_cant_partir expedido_d.canti%type
    , p_cant_sobra  expedido_d.canti%type
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

    procedure crea_item_pedido_nac(
      p_numero      expednac_d.numero%type
    , p_item        expednac_d.nro%type
    , p_cant_partir expedido_d.canti%type
    , p_cant_sobra  expedido_d.canti%type
    ) is
    begin
      null;
    end;

    procedure guarda_ot(
      p_ot         pr_ot%rowtype
    , p_item_ped   expedido_d%rowtype
    , p_cant_sobra number
    ) is
      l_nro pr_ot.numero%type;
    begin
      l_nro := nuevo_numero(p_ot.nuot_tipoot_codigo, p_ot.nuot_serie);

      insert into pr_ot
      values ( l_nro, sysdate, 1, p_cant_sobra, p_ot.nuot_serie
             , p_ot.nuot_tipoot_codigo, 'ORDEN :' || p_ot.numero, 0, null, null
             , null, 'S', 1, 0, p_ot.formu_art_cod_art
             , 1, p_ot.cdc_centro_costo, null, 0, 'S'
             , null, null, 0, p_ot.hora_fab, null
             , null, null, p_item_ped.nro, null, null
             , null, p_item_ped.numero, p_ot.abre02, null, p_ot.destino
             , p_ot.plazo, p_ot.fecha_plazo, p_ot.cod_eqi, p_ot.pais, p_ot.empaque
             , user, 'PARTIDA', p_ot.embalaje, p_ot.prioridad, 0
             , p_ot.fecha_prioridad, p_ot.cod_lin, 0, 0, 0);
    end;

    procedure crea_nueva_ot(
      r tmp_ordenes_surtir%rowtype
    ) is
      l_item_ped   expedido_d%rowtype;
      l_ot         pr_ot%rowtype;
      l_cant_sobra pr_ot.cant_prog%type;
    begin
      l_ot := api_pr_ot.onerow(r.ot_numero, r.ot_serie, r.ot_tipo);
      l_cant_sobra := l_ot.cant_prog - r.cant_partir;

      if l_ot.destino = '1' then
        l_item_ped := crea_item_pedido_exp(l_ot.abre01, l_ot.per_env, r.cant_partir, l_cant_sobra);
      else
        crea_item_pedido_nac(l_ot.abre01, l_ot.per_env, r.cant_partir, l_cant_sobra);
      end if;

      guarda_ot(l_ot, l_item_ped, l_cant_sobra);
    end;

  begin
    for r in (select * from tmp_ordenes_surtir where partir_ot = 1 order by ranking) loop
      crea_nueva_ot(r);
    end loop;
  end;
end surte;
