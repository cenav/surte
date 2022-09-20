create or replace package body surte as
  gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
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

  type calculo_aat is table of calculo_rt index by pls_integer;

  type sao_rt is record (
    cod_sao         tmp_surte_sao.cod_sao%type,
    cantidad        tmp_surte_sao.cantidad%type,
    id_color        tmp_surte_sao.id_color%type,
    rendimiento     tmp_surte_sao.rendimiento%type,
    stock_inicial   tmp_surte_sao.stock_inicial%type,
    saldo_stock     tmp_surte_sao.saldo_stock%type,
    sobrante        tmp_surte_sao.sobrante%type,
    faltante        tmp_surte_sao.faltante%type,
    cant_final      tmp_surte_sao.cant_final%type,
    es_importado    tmp_surte_sao.es_importado%type,
    tiene_stock_itm tmp_surte_sao.tiene_stock_itm%type
  );

  type saos_aat is table of sao_rt index by pls_integer;

  type pieza_rt is record (
    cod_art         tmp_surte_pza.cod_pza%type,
    cantidad        tmp_surte_pza.cantidad%type,
    rendimiento     tmp_surte_pza.rendimiento%type,
    stock_inicial   tmp_surte_pza.stock_inicial%type,
    stock_actual    tmp_surte_pza.stock_actual%type,
    saldo_stock     tmp_surte_pza.saldo_stock%type,
    sobrante        tmp_surte_pza.sobrante%type,
    faltante        tmp_surte_pza.faltante%type,
    cant_final      tmp_surte_pza.cant_final%type,
    linea           tmp_surte_pza.linea%type,
    es_importado    tmp_surte_pza.es_importado%type,
    tiene_stock_itm tmp_surte_pza.tiene_stock_itm%type,
    saos            saos_aat
  );

  type piezas_aat is table of pieza_rt index by pls_integer;

  type juego_rt is record (
    ranking         tmp_surte_jgo.ranking%type,
    cod_cliente     tmp_surte_jgo.cod_cliente%type,
    nom_cliente     tmp_surte_jgo.nom_cliente%type,
    nro_pedido      tmp_surte_jgo.nro_pedido%type,
    itm_pedido      tmp_surte_jgo.itm_pedido%type,
    fch_pedido      tmp_surte_jgo.fch_pedido%type,
    ot_tipo         tmp_surte_jgo.ot_tipo%type,
    ot_serie        tmp_surte_jgo.ot_serie%type,
    ot_numero       tmp_surte_jgo.ot_numero%type,
    ot_estado       tmp_surte_jgo.ot_estado%type,
    formu_art       tmp_surte_jgo.cod_jgo%type,
    es_juego        tmp_surte_jgo.es_juego%type,
    tiene_importado tmp_surte_jgo.tiene_importado%type,
    preuni          tmp_surte_jgo.preuni%type,
    valor           tmp_surte_jgo.valor%type,
    valor_surtir    tmp_surte_jgo.valor_surtir%type,
    impreso         tmp_surte_jgo.impreso%type,
    fch_impresion   tmp_surte_jgo.fch_impresion%type,
    partir_ot       tmp_surte_jgo.partir_ot%type,
    cant_partir     tmp_surte_jgo.cant_partir%type,
    tiene_stock_ot  tmp_surte_jgo.tiene_stock_ot%type,
    es_prioritario  tmp_surte_jgo.es_prioritario%type,
    piezas          piezas_aat
  );

  type juegos_aat is table of juego_rt index by ranking_t;

  type stock_aat is table of stock_t index by codart_t;
  type tmp_aat is table of tmp_ordenes_surtir%rowtype index by pls_integer;

  type tmp_jgo_aat is table of tmp_surte_jgo%rowtype index by pls_integer;
  type tmp_pza_aat is table of tmp_surte_pza%rowtype index by pls_integer;
  type tmp_sao_aat is table of tmp_surte_sao%rowtype index by pls_integer;

  bulk_errors exception;
  pragma exception_init (bulk_errors, -24381);

  cursor pedidos_cur(p_pais varchar2, p_vendedor varchar2, p_dias pls_integer, p_empaque varchar2) is
    -- pedidos de clientes ordenados primero por juegos, luego de mayor a menor valor
      with detalle as (
        select v.cod_cliente, v.nombre, v.fch_pedido, v.pedido, v.pedido_item, v.nuot_serie
             , v.nuot_tipoot_codigo, v.numero, v.fecha, v.formu_art_cod_art, v.estado, v.art_cod_art
             , v.cant_formula, v.rendimiento, v.saldo, v.despachar, v.cod_lin, v.abre02, v.preuni, v.valor
             , v.stock, v.tiene_stock, v.tiene_stock_ot, v.tiene_stock_item, v.tiene_importado, v.impreso
             , v.fch_impresion, v.es_juego, v.es_importado, v.es_prioritario, v.es_sao
             , case when lag(v.numero) over (order by null) = v.numero then null else v.numero end oa
             , dense_rank() over (
          order by case when p.prioritario = 1 then v.es_prioritario end desc
--             , case when trunc(sysdate) - v.fch_pedido > p_dias then 1 else 0 end desc --> 25/08/22 solo filtre mayores a fecha
            , case when v.valor > p.valor_item then 1 else 0 end desc
            , v.es_juego
            , v.valor desc
          ) as ranking
          from vw_ordenes_pedido_pendiente v
               join param_surte p on p.id_param = 1
         where (v.es_prioritario = 1
           or ((v.pais = p_pais or p_pais is null)
             and (v.vendedor = p_vendedor or p_vendedor is null)
             and (v.empaque = p_empaque or p_empaque is null)
             and (trunc(sysdate) - v.fch_pedido > p_dias or p_dias is null)
             and (exists(select * from tmp_selecciona_cliente t where v.cod_cliente = t.cod_cliente) or
                  not exists(select * from tmp_selecciona_cliente)))
           )
           and v.impreso = 'NO'
        )
    select *
      from detalle
     order by ranking;

  -- private routines
  function carga_stock return stock_aat is
    l_stocks stock_aat;

    procedure piezas(
      p_stocks in out nocopy stock_aat
    ) is
    begin
      for r in (
        -- resta ordenes que estan impresas al stock actual de las piezas
          with impresas as (
            select o.art_cod_art, sum(o.cant_formula) as impreso
              from vw_ordenes_impresas_piezas o
                   join param_surte p on p.id_param = 1
             where o.dias_impreso <= p.dias_impreso_bien
             group by o.art_cod_art
            )
             , stock as (
            select distinct art_cod_art, stock
              from vw_ordenes_pedido_pendiente
            )
        select s.art_cod_art, greatest(s.stock - nvl(i.impreso, 0), 0) as stock
          from stock s
               left join impresas i on s.art_cod_art = i.art_cod_art
        )
      loop
        p_stocks(r.art_cod_art) := r.stock;
      end loop;
    end;

    procedure saos(
      p_stocks in out nocopy stock_aat
    ) is
    begin
      for r in (
          with saos as (
            select f.cod_for
              from vw_formula_saos f
             group by f.cod_for
            )
        select a.cod_for, s.stock
          from saos a
               join vw_stock_almacen s on a.cod_for = s.cod_art
        )
      loop
        p_stocks(r.cod_for) := r.stock;
      end loop;
    end;
  begin
    piezas(l_stocks);
    saos(l_stocks);
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
  , p_empaque  varchar2 default null
  ) is
    g_stocks    stock_aat;
    g_explosion surte_formula.master_aat;
    g_param     param_surte%rowtype;

    procedure init is
    begin
      g_stocks := carga_stock();
      g_explosion := surte_formula.explosion();
      g_param := api_param_surte.onerow();
    end;

    function get_stock(
      p_codart codart_t
    ) return number is
    begin
      return case when g_stocks.exists(p_codart) then g_stocks(p_codart) else 0 end;
    end;

    procedure crea_maestro(
      p_pedido in     pedidos_cur%rowtype
    , p_juegos in out juegos_aat
    ) is
    begin
      p_juegos(p_pedido.ranking).ranking := p_pedido.ranking;
      p_juegos(p_pedido.ranking).cod_cliente := p_pedido.cod_cliente;
      p_juegos(p_pedido.ranking).nom_cliente := p_pedido.nombre;
      p_juegos(p_pedido.ranking).nro_pedido := p_pedido.pedido;
      p_juegos(p_pedido.ranking).itm_pedido := p_pedido.pedido_item;
      p_juegos(p_pedido.ranking).fch_pedido := p_pedido.fch_pedido;
      p_juegos(p_pedido.ranking).preuni := p_pedido.preuni;
      p_juegos(p_pedido.ranking).valor := p_pedido.valor;
      p_juegos(p_pedido.ranking).ot_tipo := p_pedido.nuot_tipoot_codigo;
      p_juegos(p_pedido.ranking).ot_serie := p_pedido.nuot_serie;
      p_juegos(p_pedido.ranking).ot_numero := p_pedido.numero;
      p_juegos(p_pedido.ranking).ot_estado := p_pedido.estado;
      p_juegos(p_pedido.ranking).formu_art := p_pedido.formu_art_cod_art;
      p_juegos(p_pedido.ranking).es_juego := p_pedido.es_juego;
      p_juegos(p_pedido.ranking).tiene_importado := p_pedido.tiene_importado;
      p_juegos(p_pedido.ranking).impreso := p_pedido.impreso;
      p_juegos(p_pedido.ranking).fch_impresion := p_pedido.fch_impresion;
      p_juegos(p_pedido.ranking).tiene_stock_ot := null;
      p_juegos(p_pedido.ranking).es_prioritario := p_pedido.es_prioritario;
    end;

    function crea_sao(
      p_formula  surte_formula.formula_rt
    , p_cantidad number
    ) return sao_rt is
      l_sao sao_rt;
    begin
      l_sao.cod_sao := p_formula.cod_for;
      l_sao.rendimiento := p_formula.canti;
      l_sao.cantidad := p_formula.canti * p_cantidad;
      l_sao.stock_inicial := get_stock(p_formula.cod_for);
      return l_sao;
    end;

    function crea_saos(
      p_formulas surte_formula.formulas_aat
    , p_cantidad number
    ) return saos_aat is
      l_saos saos_aat;
    begin
      for i in 1 .. p_formulas.count loop
        l_saos(i) := crea_sao(p_formulas(i), p_cantidad);
      end loop;
      return l_saos;
    end;

    procedure crea_detalle(
      p_pedido in            pedidos_cur%rowtype
    , p_juegos in out nocopy juegos_aat
    ) is
      l_idx pls_integer := 0;
    begin
      l_idx := p_juegos(p_pedido.ranking).piezas.count + 1;
      p_juegos(p_pedido.ranking).piezas(l_idx).cod_art := p_pedido.art_cod_art;
      p_juegos(p_pedido.ranking).piezas(l_idx).cantidad := p_pedido.cant_formula;
      p_juegos(p_pedido.ranking).piezas(l_idx).stock_inicial := p_pedido.stock;
      p_juegos(p_pedido.ranking).piezas(l_idx).saldo_stock := null;
      p_juegos(p_pedido.ranking).piezas(l_idx).faltante := null;
      p_juegos(p_pedido.ranking).piezas(l_idx).linea := p_pedido.cod_lin;
      p_juegos(p_pedido.ranking).piezas(l_idx).es_importado := p_pedido.es_importado;
      p_juegos(p_pedido.ranking).piezas(l_idx).rendimiento := p_pedido.rendimiento;
      p_juegos(p_pedido.ranking).piezas(l_idx).tiene_stock_itm := null;

      if p_pedido.es_sao = 1 and g_explosion.exists(p_pedido.art_cod_art) then
        p_juegos(p_pedido.ranking).piezas(l_idx).saos :=
            crea_saos(g_explosion(p_pedido.art_cod_art).formulas, p_pedido.cant_formula);
      end if;
    end;

    procedure actualiza_saldo(
      p_idx                  pls_integer
    , p_calculo              calculo_aat
    , p_juegos in out nocopy juegos_aat
    ) is
      l_codart codart_t;
    begin
      p_juegos(p_idx).tiene_stock_ot := 'SI';
      p_juegos(p_idx).valor_surtir := p_juegos(p_idx).valor;
      p_juegos(p_idx).partir_ot := 0;
      for j in 1 .. p_juegos(p_idx).piezas.count loop
        l_codart := p_juegos(p_idx).piezas(j).cod_art;
        p_juegos(p_idx).piezas(j).stock_actual := p_calculo(j).stock_actual;
        p_juegos(p_idx).piezas(j).saldo_stock := g_stocks(l_codart) - p_calculo(j).cant_final;
        p_juegos(p_idx).piezas(j).cant_final := p_calculo(j).cant_final;
        g_stocks(p_juegos(p_idx).piezas(j).cod_art) :=
              g_stocks(l_codart) - p_juegos(p_idx).piezas(j).cant_final;
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
      p_calculo in out  calculo_aat
    , p_cant_partir     number
    , p_es_partible out boolean
    ) is
    begin
      p_es_partible := true;
      for i in 1 .. p_calculo.count loop
        if p_cant_partir * p_calculo(i).rendimiento <= p_calculo(i).cant_final then
          p_calculo(i).cant_final := p_cant_partir * p_calculo(i).rendimiento;
        else
          p_es_partible := false;
        end if;
      end loop;
    end;

    procedure parte_orden(
      p_idx                   pls_integer
    , p_calculo in out nocopy calculo_aat
    , p_juegos in out nocopy  juegos_aat
    ) is
      l_codart           codart_t;
      l_cant_partir      number;
      l_valor_surtir     number;
      l_es_partible      boolean;
      l_cumple_valor_min boolean;
    begin
      p_juegos(p_idx).tiene_stock_ot := 'NO';
      l_cant_partir := multiplo.inferior(find_min(p_calculo), gc_multiplo_partir);
      prueba_partir(p_calculo, l_cant_partir, l_es_partible);
      l_valor_surtir := l_cant_partir * p_juegos(p_idx).preuni;
      l_cumple_valor_min := l_valor_surtir >= g_param.valor_partir;
      if l_es_partible and l_cumple_valor_min then
        p_juegos(p_idx).partir_ot := 1;
        p_juegos(p_idx).cant_partir := l_cant_partir;
        p_juegos(p_idx).valor_surtir := l_valor_surtir;
        for j in 1 .. p_juegos(p_idx).piezas.count loop
          l_codart := p_juegos(p_idx).piezas(j).cod_art;
          p_juegos(p_idx).piezas(j).stock_actual := p_calculo(j).stock_actual;
          p_juegos(p_idx).piezas(j).saldo_stock := g_stocks(l_codart) - p_calculo(j).cant_final;
          p_juegos(p_idx).piezas(j).cant_final := p_calculo(j).cant_final;
          g_stocks(p_juegos(p_idx).piezas(j).cod_art) :=
                g_stocks(l_codart) - p_juegos(p_idx).piezas(j).cant_final;
        end loop;
      else
        p_juegos(p_idx).partir_ot := 0;
      end if;
    end;

    -- por todos los items de pedidos, consume el stock
    -- progresivamente en el orden dado
    procedure consume_stock(
      p_juegos in out nocopy juegos_aat
    ) is
      l_calculo         calculo_aat;
      l_stock_actual    number  := 0;
      l_tiene_stock_ot  boolean := true;
      l_tiene_stock_itm boolean := true;
      l_puede_partirse  boolean := true;
    begin
      for i in 1 .. p_juegos.count loop
        l_tiene_stock_ot := true;
        l_puede_partirse := true;
        l_calculo.delete();

        for j in 1 .. p_juegos(i).piezas.count loop
          l_stock_actual := g_stocks(p_juegos(i).piezas(j).cod_art);
          l_calculo(j).stock_actual := l_stock_actual;
          l_calculo(j).rendimiento := p_juegos(i).piezas(j).rendimiento;
          l_tiene_stock_itm := l_stock_actual >= p_juegos(i).piezas(j).cantidad;

          if l_tiene_stock_itm then
            l_calculo(j).cant_final := p_juegos(i).piezas(j).cantidad;
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

          p_juegos(i).piezas(j).stock_actual := l_stock_actual;
          p_juegos(i).piezas(j).tiene_stock_itm := case when l_tiene_stock_itm then 'SI' else 'NO' end;
        end loop;

        case
          when l_tiene_stock_ot then
            actualiza_saldo(i, l_calculo, p_juegos);
          when l_puede_partirse then
            parte_orden(i, l_calculo, p_juegos);
          else
            p_juegos(i).tiene_stock_ot := 'NO';
            p_juegos(i).partir_ot := 0;
        end case;
      end loop;
    end;

    function crea_coleccion return juegos_aat is
      l_juegos juegos_aat;
    begin
      for r_pedido in pedidos_cur(p_pais, p_vendedor, p_dias, p_empaque) loop
        -- para el primer quiebre de grupo (item pedido)
        -- normaliza la data
        if r_pedido.oa is not null then
          crea_maestro(r_pedido, l_juegos);
          crea_detalle(r_pedido, l_juegos);
        else
          crea_detalle(r_pedido, l_juegos);
        end if;
      end loop;

      return l_juegos;
    end;

    -- porque Oracle tovadia no acepta forall con collecciones anidadas
    -- tampoco ocepta forall con colleciones indexadas por varchar2
    procedure desnormaliza(
      p_juegos                juegos_aat
    , p_juegos_tmp out nocopy tmp_jgo_aat
    , p_piezas_tmp out nocopy tmp_pza_aat
    , p_saos_tmp out nocopy   tmp_sao_aat
    ) is
    begin
      for i in 1 .. p_juegos.count loop
        -- maestro
        p_juegos_tmp(p_juegos_tmp.count + 1).ranking := p_juegos(i).ranking;
        p_juegos_tmp(p_juegos_tmp.count).nro_pedido := p_juegos(i).nro_pedido;
        p_juegos_tmp(p_juegos_tmp.count).itm_pedido := p_juegos(i).itm_pedido;
        p_juegos_tmp(p_juegos_tmp.count).cod_cliente := p_juegos(i).cod_cliente;
        p_juegos_tmp(p_juegos_tmp.count).nom_cliente := p_juegos(i).nom_cliente;
        p_juegos_tmp(p_juegos_tmp.count).fch_pedido := p_juegos(i).fch_pedido;
        p_juegos_tmp(p_juegos_tmp.count).ot_tipo := p_juegos(i).ot_tipo;
        p_juegos_tmp(p_juegos_tmp.count).ot_serie := p_juegos(i).ot_serie;
        p_juegos_tmp(p_juegos_tmp.count).ot_numero := p_juegos(i).ot_numero;
        p_juegos_tmp(p_juegos_tmp.count).ot_estado := p_juegos(i).ot_estado;
        p_juegos_tmp(p_juegos_tmp.count).cod_jgo := p_juegos(i).formu_art;
        p_juegos_tmp(p_juegos_tmp.count).preuni := p_juegos(i).preuni;
        p_juegos_tmp(p_juegos_tmp.count).valor := p_juegos(i).valor;
        p_juegos_tmp(p_juegos_tmp.count).valor_surtir := p_juegos(i).valor_surtir;
        p_juegos_tmp(p_juegos_tmp.count).es_juego := p_juegos(i).es_juego;
        p_juegos_tmp(p_juegos_tmp.count).tiene_importado := p_juegos(i).tiene_importado;
        p_juegos_tmp(p_juegos_tmp.count).impreso := p_juegos(i).impreso;
        p_juegos_tmp(p_juegos_tmp.count).fch_impresion := p_juegos(i).fch_impresion;
        p_juegos_tmp(p_juegos_tmp.count).partir_ot := p_juegos(i).partir_ot;
        p_juegos_tmp(p_juegos_tmp.count).cant_partir := p_juegos(i).cant_partir;
        p_juegos_tmp(p_juegos_tmp.count).tiene_stock_ot := p_juegos(i).tiene_stock_ot;
        p_juegos_tmp(p_juegos_tmp.count).es_prioritario := p_juegos(i).es_prioritario;

        for j in 1 .. p_juegos(i).piezas.count loop
          -- detalle
          p_piezas_tmp(p_piezas_tmp.count + 1).nro_pedido := p_juegos(i).nro_pedido;
          p_piezas_tmp(p_piezas_tmp.count).itm_pedido := p_juegos(i).itm_pedido;
          p_piezas_tmp(p_piezas_tmp.count).cod_pza := p_juegos(i).piezas(j).cod_art;
          p_piezas_tmp(p_piezas_tmp.count).cantidad := p_juegos(i).piezas(j).cantidad;
          p_piezas_tmp(p_piezas_tmp.count).rendimiento := p_juegos(i).piezas(j).rendimiento;
          p_piezas_tmp(p_piezas_tmp.count).stock_inicial := p_juegos(i).piezas(j).stock_inicial;
          p_piezas_tmp(p_piezas_tmp.count).stock_actual := p_juegos(i).piezas(j).stock_actual;
          p_piezas_tmp(p_piezas_tmp.count).saldo_stock := p_juegos(i).piezas(j).saldo_stock;
          p_piezas_tmp(p_piezas_tmp.count).sobrante := p_juegos(i).piezas(j).sobrante;
          p_piezas_tmp(p_piezas_tmp.count).faltante := p_juegos(i).piezas(j).faltante;
          p_piezas_tmp(p_piezas_tmp.count).cant_final := p_juegos(i).piezas(j).cant_final;
          p_piezas_tmp(p_piezas_tmp.count).linea := p_juegos(i).piezas(j).linea;
          p_piezas_tmp(p_piezas_tmp.count).es_importado := p_juegos(i).piezas(j).es_importado;
          p_piezas_tmp(p_piezas_tmp.count).tiene_stock_itm := p_juegos(i).piezas(j).tiene_stock_itm;

          for k in 1 .. p_juegos(i).piezas(j).saos.count loop
            -- saos
            p_saos_tmp(p_saos_tmp.count + 1).nro_pedido := p_juegos(i).nro_pedido;
            p_saos_tmp(p_saos_tmp.count).itm_pedido := p_juegos(i).itm_pedido;
            p_saos_tmp(p_saos_tmp.count).cod_pza := p_juegos(i).piezas(j).cod_art;
            p_saos_tmp(p_saos_tmp.count).cod_sao := p_juegos(i).piezas(j).saos(k).cod_sao;
            p_saos_tmp(p_saos_tmp.count).cantidad := p_juegos(i).piezas(j).saos(k).cantidad;
            p_saos_tmp(p_saos_tmp.count).rendimiento := p_juegos(i).piezas(j).saos(k).rendimiento;
            p_saos_tmp(p_saos_tmp.count).stock_inicial := p_juegos(i).piezas(j).saos(k).stock_inicial;
            p_saos_tmp(p_saos_tmp.count).saldo_stock := p_juegos(i).piezas(j).saos(k).saldo_stock;
            p_saos_tmp(p_saos_tmp.count).sobrante := p_juegos(i).piezas(j).saos(k).sobrante;
            p_saos_tmp(p_saos_tmp.count).faltante := p_juegos(i).piezas(j).saos(k).faltante;
            p_saos_tmp(p_saos_tmp.count).cant_final := p_juegos(i).piezas(j).saos(k).cant_final;
            p_saos_tmp(p_saos_tmp.count).es_importado := p_juegos(i).piezas(j).saos(k).es_importado;
            p_saos_tmp(p_saos_tmp.count).tiene_stock_itm := p_juegos(i).piezas(j).saos(k).tiene_stock_itm;
            p_saos_tmp(p_saos_tmp.count).id_color := p_juegos(i).piezas(j).saos(k).id_color;
          end loop;
        end loop;

      end loop;
    end;

    procedure guarda_juegos(
      p_juegos_tmp tmp_jgo_aat
    ) is
    begin
      delete from tmp_surte_jgo;

      forall i in 1 .. p_juegos_tmp.count save exceptions
        insert into tmp_surte_jgo values p_juegos_tmp(i);
    exception
      when bulk_errors then
        for i in 1 .. sql%bulk_exceptions.count loop
          logger.log(
                'OA: ' || p_juegos_tmp(sql%bulk_exceptions(i).error_index).ot_numero ||
                ' Articulo: ' || p_juegos_tmp(sql%bulk_exceptions(i).error_index).cod_jgo ||
                ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1)
            );
        end loop;
    end;

    procedure guarda_piezas(
      p_piezas_tmp tmp_pza_aat
    ) is
    begin
      delete from tmp_surte_pza;

      forall i in 1 .. p_piezas_tmp.count save exceptions
        insert into tmp_surte_pza values p_piezas_tmp(i);
    exception
      when bulk_errors then
        for i in 1 .. sql%bulk_exceptions.count loop
          logger.log(
                'pedido: ' || p_piezas_tmp(sql%bulk_exceptions(i).error_index).nro_pedido ||
                ' item: ' || p_piezas_tmp(sql%bulk_exceptions(i).error_index).itm_pedido ||
                ' pza: ' || p_piezas_tmp(sql%bulk_exceptions(i).error_index).cod_pza ||
                ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1)
            );
        end loop;
    end;

    procedure guarda_saos(
      p_saos_tmp tmp_sao_aat
    ) is
    begin
      delete from tmp_surte_sao;

      forall i in 1 .. p_saos_tmp.count save exceptions
        insert into tmp_surte_sao values p_saos_tmp(i);
    exception
      when bulk_errors then
        for i in 1 .. sql%bulk_exceptions.count loop
          logger.log(
                'pedido: ' || p_saos_tmp(sql%bulk_exceptions(i).error_index).nro_pedido ||
                ' item: ' || p_saos_tmp(sql%bulk_exceptions(i).error_index).itm_pedido ||
                ' pza: ' || p_saos_tmp(sql%bulk_exceptions(i).error_index).cod_pza ||
                ' sao: ' || p_saos_tmp(sql%bulk_exceptions(i).error_index).cod_sao ||
                ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1)
            );
        end loop;
    end;

    procedure guarda(
      p_juegos_tmp in tmp_jgo_aat
    , p_piezas_tmp in tmp_pza_aat
    , p_saos_tmp in   tmp_sao_aat
    ) is
    begin
      guarda_juegos(p_juegos_tmp);
      guarda_piezas(p_piezas_tmp);
      guarda_saos(p_saos_tmp);
    end;

  begin
    declare
      l_juegos     juegos_aat;
      l_juegos_tmp tmp_jgo_aat;
      l_piezas_tmp tmp_pza_aat;
      l_saos_tmp   tmp_sao_aat;
    begin
      init();
      l_juegos := crea_coleccion();
      consume_stock(l_juegos);
      desnormaliza(l_juegos, l_juegos_tmp, l_piezas_tmp, l_saos_tmp);
      guarda(l_juegos_tmp, l_piezas_tmp, l_saos_tmp);
      commit;
    end;
  end;

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


  procedure parte_ot_masivo(
    p_prioritario pls_integer default 1
  ) is
  begin
    for r in (
      select *
        from vw_surte_item
       where se_puede_partir = 'SI'
         and (p_prioritario = 1 or (p_prioritario = 0 and es_prioritario = 'NO'))
       order by ranking
      )
    loop
      parte_ot(r.ot_tipo, r.ot_serie, r.ot_numero, r.cant_partir);
    end loop;
  end;

  function total_imprimir return number is
    l_total number := 0;
  begin
    select nvl(sum(valor_surtir), 0)
      into l_total
      from vw_surte_item
     where tiene_stock_ot = 'SI' or se_puede_partir = 'SI';

    return l_total;
  end;

  function total_impreso return number is
    l_total number := 0;
  begin
    select nvl(sum(valor), 0)
      into l_total
      from vw_ordenes_impresas_pendientes
     where color = 'GREEN';

    return l_total;
  end;

  function total_surtir return number is
  begin
    return total_imprimir() + total_impreso();
  end;
end surte;
