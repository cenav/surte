create or replace package body surte as
  gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';

  c_header constant simple_integer := 1;

  subtype string_t is varchar2(32672);

  type tmp_aat is table of tmp_ordenes_surtir%rowtype index by pls_integer;

  bulk_errors exception;
  pragma exception_init (bulk_errors, -24381);

  -- private routines

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
    g_stocks    surte_stock.aat;
    g_explosion surte_formula.master_aat;
    g_param     param_surte%rowtype;
    g_colores   surte_color.aat;

    procedure init is
    begin
      g_stocks := surte_stock.carga();
      g_explosion := surte_formula.explosion();
      g_param := api_param_surte.onerow();
      g_colores := surte_color.all_rows();
    end;

    procedure marca_color(
      p_juego in out nocopy surte_struct.juego_rt
    , p_pieza in out nocopy surte_struct.pieza_rt
    , p_sao in out nocopy   surte_struct.sao_rt
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
      p_juego in out nocopy surte_struct.juego_rt
    , p_pieza in out nocopy surte_struct.pieza_rt
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
      p_juego in out nocopy surte_struct.juego_rt
    , p_pieza in out nocopy surte_struct.pieza_rt
    , p_sao in out nocopy   surte_struct.sao_rt
    , p_stock               number
    ) return surte_struct.calc_detail_rt is
      l_calc surte_struct.calc_detail_rt;
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
      p_juego in out nocopy surte_struct.juego_rt
    , p_pieza in out nocopy surte_struct.pieza_rt
    , p_formula             surte_formula.formula_rt
    ) return surte_struct.sao_rt is
      l_sao   surte_struct.sao_rt;
      l_stock number;
    begin
      l_stock := surte_stock.actual(p_formula.cod_for, g_stocks);
      l_sao.cod_sao := p_formula.cod_for;
      l_sao.rendimiento := p_formula.canti;
      l_sao.cantidad := p_formula.canti * p_pieza.cantidad;
      l_sao.stock_inicial := surte_stock.inicial(p_formula.cod_for, g_stocks);
      l_sao.stock_actual := surte_stock.actual(p_formula.cod_for, g_stocks);
      l_sao.calculo := calc_sao(p_juego, p_pieza, l_sao, l_stock);
      return l_sao;
    end;

    function crea_saos(
      p_juego in out nocopy surte_struct.juego_rt
    , p_pieza in out nocopy surte_struct.pieza_rt
    , p_formulas            surte_formula.formulas_aat
    ) return surte_struct.saos_aat is
      l_saos surte_struct.saos_aat;
    begin
      for i in 1 .. p_formulas.count loop
        l_saos(i) := crea_sao(p_juego, p_pieza, p_formulas(i));
      end loop;
      return l_saos;
    end;

    procedure stock_completo2(
      p_juego in out nocopy surte_struct.juego_rt
    ) is
      l_codart surte_util.t_articulo;
    begin
      p_juego.tiene_stock_ot := 'SI';
      p_juego.valor_surtir := p_juego.valor;
      p_juego.partir_ot := 0;
      p_juego.id_color := surte_color.gc_completo;
      for j in 1 .. p_juego.piezas.count loop
        l_codart := p_juego.piezas(j).cod_art;
        p_juego.piezas(j).stock_actual := p_juego.piezas(j).calc_det.stock_actual;
        p_juego.piezas(j).saldo_stock :=
              surte_stock.actual(l_codart, g_stocks) - p_juego.piezas(j).calc_det.cant_final;
        p_juego.piezas(j).cant_final := p_juego.piezas(j).calc_det.cant_final;
        surte_stock.reduce(l_codart, p_juego.piezas(j).cant_final, g_stocks);
        for k in 1 .. p_juego.piezas(j).saos.count loop
          p_juego.piezas(j).saos(k).stock_actual := p_juego.piezas(j).saos(k).calculo.stock_actual;
          p_juego.piezas(j).saos(k).saldo_stock := p_juego.piezas(j).saos(k).calculo.stock_actual -
                                                   p_juego.piezas(j).saos(k).calculo.cant_final;
          p_juego.piezas(j).saos(k).cant_final := p_juego.piezas(j).saos(k).calculo.cant_final;
          surte_stock.reduce(l_codart, p_juego.piezas(j).saos(k).cant_final, g_stocks);
        end loop;
      end loop;
    end;

    procedure stock_completo(
      p_juego in out nocopy surte_struct.juego_rt
    ) is
      l_codart       surte_util.t_articulo;
      l_stock_actual number := 0;
    begin
      p_juego.tiene_stock_ot := 'SI';
      p_juego.valor_surtir := p_juego.valor;
      p_juego.partir_ot := 0;
      p_juego.id_color := surte_color.gc_completo;
      for j in 1 .. p_juego.piezas.count loop
        l_codart := p_juego.piezas(j).cod_art;
        l_stock_actual := surte_stock.actual(l_codart, g_stocks);
        p_juego.piezas(j).stock_actual := l_stock_actual;
        p_juego.piezas(j).saldo_stock := l_stock_actual - p_juego.piezas(j).cantidad;
        p_juego.piezas(j).cant_final := p_juego.piezas(j).cantidad;
        p_juego.piezas(j).tiene_stock_itm :=
            case when l_stock_actual >= p_juego.piezas(j).cantidad then 1 else 0 end;
        p_juego.piezas(j).id_color := surte_color.gc_completo;
        surte_stock.reduce(l_codart, p_juego.piezas(j).cant_final, g_stocks);
        for k in 1 .. p_juego.piezas(j).saos.count loop
          l_codart := p_juego.piezas(j).saos(k).cod_sao;
          l_stock_actual := surte_stock.actual(l_codart, g_stocks);
          p_juego.piezas(j).saos(k).stock_actual := l_stock_actual;
          p_juego.piezas(j).saos(k).saldo_stock := l_stock_actual - p_juego.piezas(j).saos(k).cantidad;
          p_juego.piezas(j).saos(k).cant_final := p_juego.piezas(j).saos(k).cantidad;
          p_juego.piezas(j).saos(k).tiene_stock_itm :=
              case when l_stock_actual >= p_juego.piezas(j).saos(k).cantidad then 1 else 0 end;
          p_juego.piezas(j).saos(k).id_color := surte_color.gc_completo;
          surte_stock.reduce(l_codart, p_juego.piezas(j).saos(k).cant_final, g_stocks);
        end loop;
      end loop;
    end;

    procedure falta_stock(
      p_juego in out nocopy surte_struct.juego_rt
    ) is
      l_codart       surte_util.t_articulo;
      l_stock_actual number := 0;
    begin
      p_juego.tiene_stock_ot := 'NO';
      p_juego.valor_surtir := null;
      p_juego.partir_ot := 0;
      p_juego.id_color := surte_color.gc_faltante;
      for j in 1 .. p_juego.piezas.count loop
        l_codart := p_juego.piezas(j).cod_art;
        l_stock_actual := surte_stock.actual(l_codart, g_stocks);
        p_juego.piezas(j).stock_actual := l_stock_actual;
        p_juego.piezas(j).saldo_stock := null;
        p_juego.piezas(j).cant_final := null;
        if l_stock_actual >= p_juego.piezas(j).cantidad then
          p_juego.piezas(j).tiene_stock_itm := 1;
          p_juego.piezas(j).id_color := surte_color.gc_completo;
        else
          p_juego.piezas(j).tiene_stock_itm := 0;
          p_juego.piezas(j).id_color := surte_color.gc_faltante;
        end if;
        for k in 1 .. p_juego.piezas(j).saos.count loop
          l_codart := p_juego.piezas(j).saos(k).cod_sao;
          l_stock_actual := surte_stock.actual(l_codart, g_stocks);
          p_juego.piezas(j).saos(k).stock_actual := l_stock_actual;
          p_juego.piezas(j).saos(k).saldo_stock := null;
          p_juego.piezas(j).saos(k).cant_final := null;
          if l_stock_actual >= p_juego.piezas(j).saos(k).cantidad then
            p_juego.piezas(j).saos(k).tiene_stock_itm := 1;
            p_juego.piezas(j).saos(k).id_color := surte_color.gc_completo;
          else
            p_juego.piezas(j).saos(k).tiene_stock_itm := 0;
            p_juego.piezas(j).saos(k).id_color := surte_color.gc_faltante;
          end if;
        end loop;
      end loop;
    end;

    function prueba_partir(
      p_juego in out surte_struct.juego_rt
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
      p_juego in out nocopy surte_struct.juego_rt
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

    procedure parte_orden2(
      p_juego in out nocopy surte_struct.juego_rt
    ) is
      l_codart           surte_util.t_articulo;
      l_cant_partir      number;
      l_cant_partir_sao  number;
      l_valor_surtir     number;
      l_cumple_valor_min boolean;
    begin
      p_juego.tiene_stock_ot := 'NO';
      l_cant_partir := multiplo.inferior(p_juego.calculo.min_cant_partir, surte_util.gc_multiplo_partir);
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
            p_juego.piezas(j).saldo_stock :=
                  surte_stock.actual(l_codart, g_stocks) - p_juego.piezas(j).calc_det.cant_final;
            p_juego.piezas(j).id_color := surte_color.gc_partir;
            surte_stock.reduce(l_codart, p_juego.piezas(j).cant_final, g_stocks);
          else
            p_juego.piezas(j).saldo_stock := surte_stock.actual(l_codart, g_stocks);
          end if;
          for k in 1 .. p_juego.piezas(j).saos.count loop
            p_juego.piezas(j).saos(k).stock_actual := p_juego.piezas(j).saos(k).calculo.stock_actual;
            p_juego.piezas(j).saos(k).saldo_stock := p_juego.piezas(j).saos(k).calculo.stock_actual -
                                                     p_juego.piezas(j).saos(k).calculo.cant_final;
            p_juego.piezas(j).saos(k).cant_final := p_juego.piezas(j).saos(k).calculo.cant_final;
            p_juego.piezas(j).saos(k).id_color := surte_color.gc_partir;
            surte_stock.reduce(p_juego.piezas(j).saos(k).cod_sao, p_juego.piezas(j).saos(k).cant_final,
                               g_stocks);
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

    procedure parte_orden(
      p_juego in out nocopy surte_struct.juego_rt
    ) is
      l_codart       surte_util.t_articulo;
      l_stock_actual number := 0;
    begin
      p_juego.tiene_stock_ot := 'NO';
      p_juego.partir_ot := 1;
      p_juego.id_color := surte_color.gc_partir;
      p_juego.cant_partir := p_juego.calculo.min_cant_partir;
      p_juego.valor_surtir := p_juego.calculo.min_cant_partir * p_juego.preuni;
      for j in 1 .. p_juego.piezas.count loop
        l_codart := p_juego.piezas(j).cod_art;
        l_stock_actual := surte_stock.actual(l_codart, g_stocks);
        p_juego.piezas(j).stock_actual := l_stock_actual;
        p_juego.piezas(j).cant_final := p_juego.calculo.min_cant_partir * p_juego.piezas(j).rendimiento;
        if p_juego.piezas(j).es_sao = 0 or
           (p_juego.piezas(j).es_sao = 1 and l_stock_actual >= p_juego.piezas(j).cant_final) then
          p_juego.piezas(j).saldo_stock := l_stock_actual - p_juego.piezas(j).cant_final;
          p_juego.piezas(j).id_color := surte_color.gc_partir;
          surte_stock.reduce(l_codart, p_juego.piezas(j).cant_final, g_stocks);
        else
          p_juego.piezas(j).saldo_stock := surte_stock.actual(l_codart, g_stocks);
          p_juego.piezas(j).id_color := surte_color.gc_armar;
        end if;
        for k in 1 .. p_juego.piezas(j).saos.count loop
          l_codart := p_juego.piezas(j).saos(k).cod_sao;
          l_stock_actual := surte_stock.actual(l_codart, g_stocks);
          p_juego.piezas(j).saos(k).stock_actual := l_stock_actual;
          p_juego.piezas(j).saos(k).cant_final := p_juego.calculo.min_cant_partir *
                                                  p_juego.piezas(j).saos(k).rendimiento;
          p_juego.piezas(j).saos(k).saldo_stock := l_stock_actual -
                                                   p_juego.piezas(j).saos(k).calculo.cant_final;
          p_juego.piezas(j).saos(k).id_color := surte_color.gc_partir;
          surte_stock.reduce(p_juego.piezas(j).saos(k).cod_sao, p_juego.piezas(j).saos(k).cant_final,
                             g_stocks);
        end loop;
      end loop;
    end;

    procedure add_detail_calc(
      p_juego in out nocopy surte_struct.juego_rt
    , p_pieza in out nocopy surte_struct.pieza_rt
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
        p_juego.calculo.falta_importado := true;
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
      p_juego in out nocopy surte_struct.juego_rt
    ) is
      l_codart surte_util.t_articulo;
      l_stock  number;
    begin
      p_juego.id_color := surte_color.gc_reserva;
      for j in 1 .. p_juego.piezas.count loop
        l_stock := p_juego.piezas(j).calc_det.stock_actual;
        l_codart := p_juego.piezas(j).cod_art;
--         p_juego.piezas(j).stock_actual := p_juego.piezas(j).calc_det.stock_actual;
        p_juego.piezas(j).stock_actual := l_stock;
        p_juego.piezas(j).saldo_stock := l_stock - least(l_stock, p_juego.piezas(j).cantidad);
        surte_stock.reduce(l_codart, least(l_stock, p_juego.piezas(j).cantidad), g_stocks);
      end loop;
    end;

    procedure consume_stock2(
      p_juegos in out nocopy surte_struct.juegos_aat
    ) is
      l_stock_actual number := 0;
    begin
      for i in 1 .. p_juegos.count loop
        for j in 1 .. p_juegos(i).piezas.count loop
          l_stock_actual := surte_stock.actual(p_juegos(i).piezas(j).cod_art, g_stocks);
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
          when p_juegos(i).calculo.podria_partirse and not p_juegos(i).calculo.falta_importado then
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

    procedure consume_stock(
      p_juegos in out nocopy surte_struct.juegos_aat
    ) is
    begin
      for i in 1 .. p_juegos.count loop
        for j in 1 .. p_juegos(i).piezas.count loop
          surte_builder.crea_saos(
              p_juegos(i).piezas(j)
            , surte_formula.formula(g_explosion, p_juegos(i).piezas(j).cod_art)
            , g_stocks
            );
        end loop;
        surte_scanner.analiza(p_juegos(i), g_stocks);
        -- despues del analisis toma una opcion
        case
          when surte_scanner.tiene_stock_completo(p_juegos(i).calculo) then
            stock_completo(p_juegos(i));
          when surte_scanner.puede_partirse(p_juegos(i), g_stocks, g_param.valor_partir) then
            parte_orden(p_juegos(i));
          else
            falta_stock(p_juegos(i));
        end case;
      end loop;
    end;

    -- porque Oracle tovadia no acepta forall con collecciones anidadas
-- tampoco ocepta forall con colleciones indexadas por varchar2
    procedure desnormaliza(
      p_juegos                surte_struct.juegos_aat
    , p_juegos_tmp out nocopy surte_struct.tmp_jgo_aat
    , p_piezas_tmp out nocopy surte_struct.tmp_pza_aat
    , p_saos_tmp out nocopy   surte_struct.tmp_sao_aat
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
      p_juegos_tmp surte_struct.tmp_jgo_aat
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
      p_piezas_tmp surte_struct.tmp_pza_aat
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
      p_saos_tmp surte_struct.tmp_sao_aat
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
      p_juegos_tmp in surte_struct.tmp_jgo_aat
    , p_piezas_tmp in surte_struct.tmp_pza_aat
    , p_saos_tmp in   surte_struct.tmp_sao_aat
    ) is
    begin
      guarda_juegos(p_juegos_tmp);
      guarda_piezas(p_piezas_tmp);
      guarda_saos(p_saos_tmp);
    end;

  begin
    declare
      l_juegos     surte_struct.juegos_aat;
      l_juegos_tmp surte_struct.tmp_jgo_aat;
      l_piezas_tmp surte_struct.tmp_pza_aat;
      l_saos_tmp   surte_struct.tmp_sao_aat;
      l_start_time pls_integer;
    begin
      --       l_start_time := dbms_utility.get_cpu_time;
--       dbms_output.put_line('start ' || (dbms_utility.get_cpu_time - l_start_time));
--       l_start_time := dbms_utility.get_cpu_time;
      init();
      --       dbms_output.put_line('init ' || (dbms_utility.get_cpu_time - l_start_time));
--       l_start_time := dbms_utility.get_cpu_time;
      l_juegos := surte_loader.crea_coleccion(p_pais, p_vendedor, p_dias, p_empaque);
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
