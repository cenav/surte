create or replace package body surte as
  gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
  gc_multiplo_partir constant simple_integer := 5;
  gc_infinito constant number := 9999999999;

  c_header constant simple_integer := 1;

  subtype string_t is varchar2(32672);
  subtype stock_t is number;
  subtype codart_t is articul.cod_art%type;
  subtype ranking_t is pls_integer;

  type calc_detail_rt is record (
    stock_actual number,
    rendimiento  number,
    faltante     number,
    cant_final   number,
    cant_patir   number,
    tiene_stock  boolean
  );

  type calc_header_rt is record (
    stock_completo      boolean := true,
    podria_partirse     boolean := true,
    es_partible         boolean := true,
    tiene_stock_ot      boolean := true,
    importado_sin_stock boolean := false,
    min_cant_partir     number := gc_infinito,
    piezas_sin_stock    number := 0,
    peso                number
  );

  type sao_rt is record (
    cod_sao         tmp_surte_sao.cod_sao%type,
    cantidad        tmp_surte_sao.cantidad%type,
    rendimiento     tmp_surte_sao.rendimiento%type,
    stock_inicial   tmp_surte_sao.stock_inicial%type,
    stock_actual    tmp_surte_sao.stock_actual%type,
    saldo_stock     tmp_surte_sao.saldo_stock%type,
    sobrante        tmp_surte_sao.sobrante%type,
    faltante        tmp_surte_sao.faltante%type,
    cant_final      tmp_surte_sao.cant_final%type,
    es_importado    tmp_surte_sao.es_importado%type,
    tiene_stock_itm tmp_surte_sao.tiene_stock_itm%type,
    id_color        tmp_surte_sao.id_color%type,
    calculo         calc_detail_rt
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
    es_sao          tmp_surte_pza.es_sao%type,
    es_armado       tmp_surte_pza.es_armado%type,
    es_reserva      tmp_surte_pza.es_reserva%type,
    id_color        tmp_surte_pza.id_color%type,
    calculo         calc_header_rt,
    calc_det        calc_detail_rt,
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
    es_reserva      tmp_surte_jgo.es_reserva%type,
    id_color        tmp_surte_jgo.id_color%type,
    calculo         calc_header_rt,
    piezas          piezas_aat
  );

  type stock_rt is record (
    stock_inicial stock_t,
    stock_actual  stock_t
  );

  type juegos_aat is table of juego_rt index by ranking_t;

  type stock_aat is table of stock_rt index by codart_t;
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
            , v.pedido
            , v.pedido_item
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
--            and pedido = 14660
--            and pedido_item = 135
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
        p_stocks(r.art_cod_art).stock_inicial := r.stock;
        p_stocks(r.art_cod_art).stock_actual := r.stock;
      end loop;
    end piezas;

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
        p_stocks(r.cod_for).stock_inicial := r.stock;
        p_stocks(r.cod_for).stock_actual := r.stock;
      end loop;
    end saos;
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
    g_colores   surte_color.aat;

    procedure init is
    begin
      g_stocks := carga_stock();
      g_explosion := surte_formula.explosion();
      g_param := api_param_surte.onerow();
      g_colores := surte_color.all_rows();
    end;

    function get_stock(
      p_codart codart_t
    ) return number is
    begin
      return case when g_stocks.exists(p_codart) then g_stocks(p_codart).stock_actual else 0 end;
    end;

    function get_stock_inicial(
      p_codart codart_t
    ) return number is
    begin
      return case when g_stocks.exists(p_codart) then g_stocks(p_codart).stock_inicial else 0 end;
    end;

    procedure reduce_stock(
      p_codart   codart_t
    , p_cantidad number
    ) is
    begin
      g_stocks(p_codart).stock_actual := g_stocks(p_codart).stock_actual - p_cantidad;
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
      p_juegos(p_pedido.ranking).tiene_stock_ot := 'NO';
      p_juegos(p_pedido.ranking).es_prioritario := p_pedido.es_prioritario;
      p_juegos(p_pedido.ranking).valor_surtir := 0;
      p_juegos(p_pedido.ranking).partir_ot := 0;
      p_juegos(p_pedido.ranking).id_color := null;
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
      p_juegos(p_pedido.ranking).piezas(l_idx).cant_final := null;
      p_juegos(p_pedido.ranking).piezas(l_idx).tiene_stock_itm := null;
      p_juegos(p_pedido.ranking).piezas(l_idx).es_sao := p_pedido.es_sao;
      p_juegos(p_pedido.ranking).piezas(l_idx).id_color := null;
    end;

    procedure marca_color(
      p_juego in out nocopy juego_rt
    , p_pieza in out nocopy pieza_rt
    , p_sao in out nocopy   sao_rt
    , p_color_pza           varchar2
    , p_color_sao           varchar2
    ) is
    begin
      p_sao.id_color := p_color_sao;
      if surte_color.peso_mayor(p_pieza.calculo.peso, g_colores(p_color_sao).peso) then
        p_pieza.calculo.peso := g_colores(p_color_pza).peso;
        p_pieza.id_color := p_color_pza;
        p_juego.calculo.peso := g_colores(p_color_sao).peso;
        p_juego.id_color := p_color_sao;
      end if;
    end;

    procedure marca_color(
      p_juego in out nocopy juego_rt
    , p_pieza in out nocopy pieza_rt
    , p_color               varchar2
    ) is
    begin
      p_pieza.id_color := p_color;
      if surte_color.peso_mayor(p_juego.calculo.peso, g_colores(p_color).peso) then
        p_juego.calculo.peso := g_colores(p_color).peso;
        p_juego.id_color := p_color;
      end if;
    end;

    function calc_sao(
      p_juego in out nocopy juego_rt
    , p_pieza in out nocopy pieza_rt
    , p_sao in out nocopy   sao_rt
    , p_stock               number
    ) return calc_detail_rt is
      l_calc calc_detail_rt;
    begin
      l_calc.stock_actual := p_stock;
      l_calc.rendimiento := p_sao.rendimiento;
      l_calc.tiene_stock := p_stock >= p_sao.cantidad;
      if l_calc.tiene_stock then
        p_pieza.calc_det.cant_final := p_sao.cantidad;
        l_calc.cant_final := p_sao.cantidad;
        p_sao.tiene_stock_itm := 1;
        marca_color(p_juego, p_pieza, p_sao, surte_color.gc_armar, surte_color.gc_completo);
      else
        -- no tiene stock completo
        p_juego.calculo.stock_completo := false;
        if p_stock > 0 then
          -- se podria partir
          p_juego.calculo.min_cant_partir := least(p_juego.calculo.min_cant_partir, p_stock);
          p_pieza.calculo.min_cant_partir := least(p_pieza.calculo.min_cant_partir, p_stock);
          p_pieza.calc_det.cant_final := least(p_pieza.calculo.min_cant_partir, p_stock);
          l_calc.cant_final := p_stock;
          p_pieza.id_color := surte_color.gc_armar;
        else
          -- no se puede partir y no tiene stock
          if p_juego.calculo.podria_partirse then
            p_juego.calculo.piezas_sin_stock := p_juego.calculo.piezas_sin_stock + 1;
          end if;
          p_juego.calculo.podria_partirse := false;
          p_juego.calculo.min_cant_partir := 0;
          p_pieza.calculo.podria_partirse := false;
          p_pieza.calculo.min_cant_partir := 0;
          l_calc.cant_final := 0;
          p_sao.tiene_stock_itm := 0;
          marca_color(p_juego, p_pieza, p_sao, surte_color.gc_faltante, surte_color.gc_faltante);
        end if;
      end if;
      return l_calc;
    end;

    function crea_sao(
      p_juego in out nocopy juego_rt
    , p_pieza in out nocopy pieza_rt
    , p_formula             surte_formula.formula_rt
    ) return sao_rt is
      l_sao   sao_rt;
      l_stock number;
    begin
      l_stock := get_stock(p_formula.cod_for);
      l_sao.cod_sao := p_formula.cod_for;
      l_sao.rendimiento := p_formula.canti;
      l_sao.cantidad := p_formula.canti * p_pieza.cantidad;
      l_sao.stock_inicial := get_stock_inicial(p_formula.cod_for);
      l_sao.stock_actual := get_stock(p_formula.cod_for);
      l_sao.calculo := calc_sao(p_juego, p_pieza, l_sao, l_stock);
      return l_sao;
    end;

    function crea_saos(
      p_juego in out nocopy juego_rt
    , p_pieza in out nocopy pieza_rt
    , p_formulas            surte_formula.formulas_aat
    ) return saos_aat is
      l_saos saos_aat;
    begin
      for i in 1 .. p_formulas.count loop
        l_saos(i) := crea_sao(p_juego, p_pieza, p_formulas(i));
      end loop;
      return l_saos;
    end;

    procedure stock_completo(
      p_juego in out nocopy juego_rt
    ) is
      l_codart codart_t;
    begin
      p_juego.tiene_stock_ot := 'SI';
      p_juego.valor_surtir := p_juego.valor;
      p_juego.partir_ot := 0;
      p_juego.id_color := surte_color.gc_completo;
      for j in 1 .. p_juego.piezas.count loop
        l_codart := p_juego.piezas(j).cod_art;
        p_juego.piezas(j).stock_actual := p_juego.piezas(j).calc_det.stock_actual;
        p_juego.piezas(j).saldo_stock := get_stock(l_codart) - p_juego.piezas(j).calc_det.cant_final;
        p_juego.piezas(j).cant_final := p_juego.piezas(j).calc_det.cant_final;
        reduce_stock(l_codart, p_juego.piezas(j).cant_final);
        for k in 1 .. p_juego.piezas(j).saos.count loop
          p_juego.piezas(j).saos(k).stock_actual := p_juego.piezas(j).saos(k).calculo.stock_actual;
          p_juego.piezas(j).saos(k).saldo_stock := p_juego.piezas(j).saos(k).calculo.stock_actual -
                                                   p_juego.piezas(j).saos(k).calculo.cant_final;
          p_juego.piezas(j).saos(k).cant_final := p_juego.piezas(j).saos(k).calculo.cant_final;
          reduce_stock(l_codart, p_juego.piezas(j).saos(k).cant_final);
        end loop;
      end loop;
    end;

    function prueba_partir(
      p_juego in out juego_rt
    , p_cant_partir  number
    ) return boolean is
      l_es_partible boolean := true;
    begin
      for i in 1 .. p_juego.piezas.count loop
        if p_cant_partir * p_juego.piezas(i).rendimiento <= p_juego.piezas(i).calc_det.cant_final then
          p_juego.piezas(i).calc_det.cant_final := p_cant_partir * p_juego.piezas(i).rendimiento;
        else
          l_es_partible := false;
        end if;
        for j in 1 .. p_juego.piezas(i).saos.count loop
          if p_cant_partir * p_juego.piezas(i).saos(j).rendimiento <=
             p_juego.piezas(i).saos(j).calculo.cant_final then
            p_juego.piezas(i).saos(j).calculo.cant_final :=
                  p_cant_partir * p_juego.piezas(i).saos(j).rendimiento;
          else
            l_es_partible := false;
          end if;
        end loop;
      end loop;
      return l_es_partible;
    end;

    procedure pinta_faltantes(
      p_juego in out nocopy juego_rt
    ) is
    begin
      p_juego.calculo.es_partible := false;
      for j in 1 .. p_juego.piezas.count loop
        if p_juego.piezas(j).id_color = surte_color.gc_partir or
           p_juego.piezas(j).id_color is null then
          p_juego.piezas(j).id_color := surte_color.gc_faltante;
          p_juego.calculo.piezas_sin_stock := p_juego.calculo.piezas_sin_stock + 1;
        end if;
        for k in 1 .. p_juego.piezas(j).saos.count loop
          if p_juego.piezas(j).saos(k).id_color = surte_color.gc_partir or
             p_juego.piezas(j).saos(k).id_color is null then
            p_juego.piezas(j).saos(k).id_color := surte_color.gc_faltante;
          end if;
        end loop;
      end loop;
    end;

    procedure parte_orden(
      p_juego in out nocopy juego_rt
    ) is
      l_codart           codart_t;
      l_cant_partir      number;
      l_cant_partir_sao  number;
      l_valor_surtir     number;
      l_cumple_valor_min boolean;
    begin
      p_juego.tiene_stock_ot := 'NO';
      l_cant_partir := multiplo.inferior(p_juego.calculo.min_cant_partir, gc_multiplo_partir);
      l_valor_surtir := l_cant_partir * p_juego.preuni;
      l_cumple_valor_min := l_valor_surtir >= g_param.valor_partir;
      if l_cumple_valor_min and prueba_partir(p_juego, l_cant_partir) then
        p_juego.partir_ot := 1;
        p_juego.id_color := surte_color.gc_partir;
        p_juego.cant_partir := l_cant_partir;
        p_juego.valor_surtir := l_valor_surtir;
        p_juego.calculo.es_partible := true;
        for j in 1 .. p_juego.piezas.count loop
          l_codart := p_juego.piezas(j).cod_art;
          p_juego.piezas(j).stock_actual := p_juego.piezas(j).calc_det.stock_actual;
          p_juego.piezas(j).cant_final := p_juego.piezas(j).calc_det.cant_final;
          if p_juego.piezas(j).id_color != surte_color.gc_armar or p_juego.piezas(j).id_color is null then
            p_juego.piezas(j).saldo_stock := get_stock(l_codart) - p_juego.piezas(j).calc_det.cant_final;
            p_juego.piezas(j).id_color := surte_color.gc_partir;
            reduce_stock(l_codart, p_juego.piezas(j).cant_final);
          else
            p_juego.piezas(j).saldo_stock := get_stock(l_codart);
          end if;
          for k in 1 .. p_juego.piezas(j).saos.count loop
            p_juego.piezas(j).saos(k).stock_actual := p_juego.piezas(j).saos(k).calculo.stock_actual;
            p_juego.piezas(j).saos(k).saldo_stock := p_juego.piezas(j).saos(k).calculo.stock_actual -
                                                     p_juego.piezas(j).saos(k).calculo.cant_final;
            p_juego.piezas(j).saos(k).cant_final := p_juego.piezas(j).saos(k).calculo.cant_final;
            p_juego.piezas(j).saos(k).id_color := surte_color.gc_partir;
            reduce_stock(p_juego.piezas(j).saos(k).cod_sao, p_juego.piezas(j).saos(k).cant_final);
          end loop;
        end loop;
      else
        -- no se puede partir
        p_juego.partir_ot := 0;
        p_juego.id_color := surte_color.gc_faltante;
        p_juego.calculo.es_partible := false;
        pinta_faltantes(p_juego);
      end if;
    end;

    procedure add_detail_calc(
      p_juego in out nocopy juego_rt
    , p_pieza in out nocopy pieza_rt
    , p_stock               number
    ) is
    begin
      p_pieza.calc_det.stock_actual := p_stock;
      p_pieza.calc_det.rendimiento := p_pieza.rendimiento;
      p_pieza.calc_det.tiene_stock := p_stock >= p_pieza.cantidad;
      p_pieza.stock_actual := p_stock;
      p_pieza.tiene_stock_itm := case when p_stock >= p_pieza.cantidad then 1 else 0 end;
      if p_pieza.calc_det.tiene_stock then
        p_pieza.calc_det.cant_final := p_pieza.cantidad;
        marca_color(p_juego, p_pieza, surte_color.gc_completo);
      elsif p_stock = 0 and p_pieza.es_importado = 1 then
        p_juego.calculo.importado_sin_stock := true;
        p_juego.calculo.stock_completo := false;
        p_juego.calculo.tiene_stock_ot := false;
        marca_color(p_juego, p_pieza, surte_color.gc_importado);
      else
        if p_pieza.es_sao = 0 then
          -- no tiene stock completo
          p_juego.calculo.stock_completo := false;
          p_juego.calculo.tiene_stock_ot := false;
          if p_stock > 0 then
            -- se podria partir
            p_juego.calculo.min_cant_partir := least(p_juego.calculo.min_cant_partir, p_stock);
            p_pieza.calc_det.cant_final := p_stock;
          else
            p_juego.calculo.podria_partirse := false;
            p_juego.calculo.min_cant_partir := 0;
            p_pieza.calc_det.cant_final := 0;
            if p_stock < p_pieza.cantidad and p_pieza.es_importado = 1 then
              marca_color(p_juego, p_pieza, surte_color.gc_importado);
            else
              marca_color(p_juego, p_pieza, surte_color.gc_faltante);
              p_juego.calculo.piezas_sin_stock := p_juego.calculo.piezas_sin_stock + 1;
            end if;
          end if;
        end if;
      end if;
    end;

    procedure reserva_stock(
      p_juego in out nocopy juego_rt
    ) is
      l_codart codart_t;
      l_stock  number;
    begin
      p_juego.id_color := surte_color.gc_reserva;
      for j in 1 .. p_juego.piezas.count loop
        l_stock := p_juego.piezas(j).calc_det.stock_actual;
        l_codart := p_juego.piezas(j).cod_art;
--         p_juego.piezas(j).stock_actual := p_juego.piezas(j).calc_det.stock_actual;
        p_juego.piezas(j).stock_actual := l_stock;
        p_juego.piezas(j).saldo_stock := l_stock - least(l_stock, p_juego.piezas(j).cantidad);
        reduce_stock(l_codart, least(l_stock, p_juego.piezas(j).cantidad));
      end loop;
    end;

    procedure consume_stock(
      p_juegos in out nocopy juegos_aat
    ) is
      l_stock_actual number := 0;
    begin
      for i in 1 .. p_juegos.count loop
        for j in 1 .. p_juegos(i).piezas.count loop
          l_stock_actual := get_stock(p_juegos(i).piezas(j).cod_art);
          add_detail_calc(p_juegos(i), p_juegos(i).piezas(j), l_stock_actual);
--           if p_juegos(i).piezas(j).es_sao = 1 and p_juegos(i).piezas(j).tiene_stock_itm = 0 then
          if p_juegos(i).piezas(j).es_sao = 1 and l_stock_actual < p_juegos(i).piezas(j).cantidad then
            p_juegos(i).piezas(j).saos :=
                crea_saos(
                    p_juegos(i)
                  , p_juegos(i).piezas(j)
                  , surte_formula.formula(g_explosion, p_juegos(i).piezas(j).cod_art)
                  );
          end if;
        end loop;
        -- tomo una decision al saber el stock que hay en las piezas de un juego
        case
          when p_juegos(i).calculo.stock_completo then
            stock_completo(p_juegos(i));
          when p_juegos(i).calculo.podria_partirse and not p_juegos(i).calculo.importado_sin_stock then
            parte_orden(p_juegos(i));
          else
            pinta_faltantes(p_juegos(i));
        end case;
        --         if p_juegos(i).nro_pedido = 14660 and p_juegos(i).itm_pedido = 135 then
--           dbms_output.put_line(p_juegos(i).valor);
--           dbms_output.put_line(p_juegos(i).calculo.piezas_sin_stock);
--           dbms_output.put_line(case when p_juegos(i).calculo.stock_completo then 'true' else 'false' end);
--           dbms_output.put_line(case when p_juegos(i).calculo.es_partible then 'true' else 'false' end);
--         end if;
        if p_juegos(i).calculo.piezas_sin_stock <= g_param.max_faltante_reserva and
           p_juegos(i).valor >= g_param.min_valor_reserva and
           not p_juegos(i).calculo.stock_completo and not p_juegos(i).calculo.es_partible then
          reserva_stock(p_juegos(i));
        end if;
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
        p_juegos_tmp(p_juegos_tmp.count).es_reserva := p_juegos(i).es_reserva;
        p_juegos_tmp(p_juegos_tmp.count).id_color := p_juegos(i).id_color;

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
          p_piezas_tmp(p_piezas_tmp.count).es_sao := p_juegos(i).piezas(j).es_sao;
          p_piezas_tmp(p_piezas_tmp.count).es_armado := p_juegos(i).piezas(j).es_armado;
          p_piezas_tmp(p_piezas_tmp.count).es_reserva := p_juegos(i).piezas(j).es_reserva;
          p_piezas_tmp(p_piezas_tmp.count).id_color := p_juegos(i).piezas(j).id_color;

          for k in 1 .. p_juegos(i).piezas(j).saos.count loop
            -- saos
            p_saos_tmp(p_saos_tmp.count + 1).nro_pedido := p_juegos(i).nro_pedido;
            p_saos_tmp(p_saos_tmp.count).itm_pedido := p_juegos(i).itm_pedido;
            p_saos_tmp(p_saos_tmp.count).cod_pza := p_juegos(i).piezas(j).cod_art;
            p_saos_tmp(p_saos_tmp.count).cod_sao := p_juegos(i).piezas(j).saos(k).cod_sao;
            p_saos_tmp(p_saos_tmp.count).cantidad := p_juegos(i).piezas(j).saos(k).cantidad;
            p_saos_tmp(p_saos_tmp.count).rendimiento := p_juegos(i).piezas(j).saos(k).rendimiento;
            p_saos_tmp(p_saos_tmp.count).stock_inicial := p_juegos(i).piezas(j).saos(k).stock_inicial;
            p_saos_tmp(p_saos_tmp.count).stock_actual := p_juegos(i).piezas(j).saos(k).stock_actual;
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
      l_start_time pls_integer;
    begin
      --       l_start_time := dbms_utility.get_cpu_time;
--       dbms_output.put_line('start ' || (dbms_utility.get_cpu_time - l_start_time));
--       l_start_time := dbms_utility.get_cpu_time;
      init();
      --       dbms_output.put_line('init ' || (dbms_utility.get_cpu_time - l_start_time));
--       l_start_time := dbms_utility.get_cpu_time;
      l_juegos := crea_coleccion();
      --       dbms_output.put_line('crea_coleccion ' || (dbms_utility.get_cpu_time - l_start_time));
--       l_start_time := dbms_utility.get_cpu_time;
      consume_stock(l_juegos);
      --       dbms_output.put_line('consume_stock ' || (dbms_utility.get_cpu_time - l_start_time));
--       l_start_time := dbms_utility.get_cpu_time;
      desnormaliza(l_juegos, l_juegos_tmp, l_piezas_tmp, l_saos_tmp);
      --       dbms_output.put_line('desnormaliza ' || (dbms_utility.get_cpu_time - l_start_time));
--       l_start_time := dbms_utility.get_cpu_time;
      guarda(l_juegos_tmp, l_piezas_tmp, l_saos_tmp);
--       dbms_output.put_line('guarda ' || (dbms_utility.get_cpu_time - l_start_time));
      commit;
    end;
  end;

  function total_imprimir return number is
    l_total number := 0;
  begin
    select nvl(sum(valor_surtir), 0)
      into l_total
      from vw_surte_jgo
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
