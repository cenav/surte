create or replace package body pevisa.surte as
  gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';

  bulk_errors exception;
  pragma exception_init (bulk_errors, -24381);

  -- private routines

  -- public routines
  procedure por_item(
    p_pais     varchar2 default null
  , p_vendedor varchar2 default null
  , p_dias     pls_integer default null
  , p_empaque  varchar2 default null
  , p_es_juego pls_integer default null
  , p_orden    pls_integer default 1
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

    procedure stock_completo(
      p_juego in out nocopy surte_struct.juego_rt
    ) is
      l_codart       surte_util.t_articulo;
      l_stock_actual number := 0;
    begin
      p_juego.tiene_stock_ot := 'SI';
      p_juego.valor_surtir :=
          case p_juego.es_simulacion when surte_util.gc_false then p_juego.valor end;
      p_juego.valor_simulado :=
          case p_juego.es_simulacion when surte_util.gc_true then p_juego.valor end;
      p_juego.partir_ot := surte_util.gc_false;
      p_juego.id_color := surte_color.gc_completo;
      for j in 1 .. p_juego.piezas.count loop
        l_codart := p_juego.piezas(j).cod_art;
        l_stock_actual := surte_stock.actual(l_codart, g_stocks);
        if p_juego.piezas(j).es_sao = 1 and l_stock_actual < p_juego.piezas(j).cantidad then
          p_juego.piezas(j).stock_actual := l_stock_actual;
          p_juego.piezas(j).saldo_stock := null;
          p_juego.piezas(j).cant_final := p_juego.piezas(j).cantidad;
          p_juego.piezas(j).tiene_stock_itm :=
              case when l_stock_actual >= p_juego.piezas(j).cantidad then 1 else 0 end;
          p_juego.piezas(j).id_color := surte_color.gc_armar;
        else
          p_juego.piezas(j).stock_actual := l_stock_actual;
          p_juego.piezas(j).saldo_stock := l_stock_actual - p_juego.piezas(j).cantidad;
          p_juego.piezas(j).cant_final := p_juego.piezas(j).cantidad;
          p_juego.piezas(j).tiene_stock_itm :=
              case when l_stock_actual >= p_juego.piezas(j).cantidad then 1 else 0 end;
          p_juego.piezas(j).id_color := surte_color.gc_completo;
          surte_stock.reduce(l_codart, p_juego.piezas(j).cant_final, g_stocks);
        end if;
        for k in 1 .. p_juego.piezas(j).saos.count loop
          l_codart := p_juego.piezas(j).saos(k).cod_sao;
          l_stock_actual := surte_stock.actual(l_codart, g_stocks);
          p_juego.piezas(j).saos(k).stock_actual := l_stock_actual;
          p_juego.piezas(j).saos(k).saldo_stock := l_stock_actual -
                                                   p_juego.piezas(j).saos(k).cantidad;
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
      p_juego.valor_simulado := null;
      p_juego.partir_ot := surte_util.gc_false;
      p_juego.id_color := surte_color.gc_faltante;
      for j in 1 .. p_juego.piezas.count loop
        l_codart := p_juego.piezas(j).cod_art;
        l_stock_actual := surte_stock.actual(l_codart, g_stocks);
        p_juego.piezas(j).stock_actual := l_stock_actual;
        p_juego.piezas(j).saldo_stock := null;
        p_juego.piezas(j).cant_final := null;
        if p_juego.piezas(j).es_sao = surte_util.gc_true and p_juego.piezas(j).calculo.armar
          --            l_stock_actual < p_juego.piezas(j).cantidad and
--            l_stock_actual > 0
        then
          p_juego.piezas(j).tiene_stock_itm := surte_util.gc_false;
          p_juego.piezas(j).id_color := surte_color.gc_armar;
        elsif l_stock_actual >= p_juego.piezas(j).cantidad then
          p_juego.piezas(j).tiene_stock_itm := surte_util.gc_true;
          p_juego.piezas(j).id_color := surte_color.gc_completo;
        else
          p_juego.piezas(j).tiene_stock_itm := surte_util.gc_false;
          p_juego.piezas(j).id_color := surte_color.gc_faltante;
        end if;
        for k in 1 .. p_juego.piezas(j).saos.count loop
          l_codart := p_juego.piezas(j).saos(k).cod_sao;
          l_stock_actual := surte_stock.actual(l_codart, g_stocks);
          p_juego.piezas(j).saos(k).stock_actual := l_stock_actual;
          p_juego.piezas(j).saos(k).saldo_stock := null;
          p_juego.piezas(j).saos(k).cant_final := null;
          if l_stock_actual >= p_juego.piezas(j).saos(k).cantidad then
            p_juego.piezas(j).saos(k).tiene_stock_itm := surte_util.gc_true;
            p_juego.piezas(j).saos(k).id_color := surte_color.gc_completo;
          else
            p_juego.piezas(j).saos(k).tiene_stock_itm := surte_util.gc_false;
            p_juego.piezas(j).saos(k).id_color := surte_color.gc_faltante;
          end if;
        end loop;
      end loop;
    end;

    procedure parte_orden(
      p_juego in out nocopy surte_struct.juego_rt
    ) is
      l_codart       surte_util.t_articulo;
      l_stock_actual number := 0;
--       l_marca        varchar2(30) := 'SI';
    begin
      p_juego.tiene_stock_ot := 'NO';
      p_juego.partir_ot := surte_util.gc_true;
      p_juego.id_color := surte_color.gc_partir;
      p_juego.cant_partir := p_juego.calculo.min_cant_partir;
      p_juego.valor_surtir := case p_juego.es_simulacion
                                when surte_util.gc_false then
                                  p_juego.calculo.min_cant_partir * p_juego.preuni
                              end;
      p_juego.valor_simulado := case p_juego.es_simulacion
                                  when surte_util.gc_true then
                                    p_juego.calculo.min_cant_partir * p_juego.preuni
                                end;
      for j in 1 .. p_juego.piezas.count loop
        l_codart := p_juego.piezas(j).cod_art;
        l_stock_actual := surte_stock.actual(l_codart, g_stocks);
        p_juego.piezas(j).stock_actual := l_stock_actual;
        p_juego.piezas(j).cant_final :=
              p_juego.calculo.min_cant_partir * p_juego.piezas(j).rendimiento;
        if p_juego.piezas(j).es_sao = 0 or
           (p_juego.piezas(j).es_sao = 1 and l_stock_actual >= p_juego.piezas(j).cant_final)
        then
          p_juego.piezas(j).saldo_stock := l_stock_actual - p_juego.piezas(j).cant_final;
          p_juego.piezas(j).id_color := surte_color.gc_completo;
          surte_stock.reduce(l_codart, p_juego.piezas(j).cant_final, g_stocks);
--           l_marca := 'NO';
          p_juego.piezas(j).saos.delete();
          p_juego.piezas(j).calculo.armar := false; -- refactorizar deberia estar en scanner
        else
          p_juego.piezas(j).id_color := surte_color.gc_armar;
--           l_marca := 'SI';
        end if;
--         if l_marca = 'SI' then
        for k in 1 .. p_juego.piezas(j).saos.count loop
          l_codart := p_juego.piezas(j).saos(k).cod_sao;
          l_stock_actual := surte_stock.actual(l_codart, g_stocks);
          p_juego.piezas(j).saos(k).stock_actual := l_stock_actual;
          p_juego.piezas(j).saos(k).cant_final := p_juego.piezas(j).cant_final *
                                                  p_juego.piezas(j).saos(k).rendimiento;
          p_juego.piezas(j).saos(k).saldo_stock := l_stock_actual -
                                                   p_juego.piezas(j).saos(k).cant_final;
          p_juego.piezas(j).saos(k).id_color := surte_color.gc_completo;
          surte_stock.reduce(p_juego.piezas(j).saos(k).cod_sao,
                             p_juego.piezas(j).saos(k).cant_final,
                             g_stocks);
        end loop;
--         end if;
      end loop;
    end;

    procedure reserva_stock(
      p_juego in out nocopy surte_struct.juego_rt
    ) is
      l_codart surte_util.t_articulo;
      l_stock  number := 0;
    begin
      p_juego.tiene_stock_ot := 'NO';
      p_juego.valor_surtir := null;
      p_juego.valor_simulado := null;
      p_juego.partir_ot := surte_util.gc_false;
      p_juego.id_color := surte_color.gc_reserva;
      for j in 1 .. p_juego.piezas.count loop
        l_codart := p_juego.piezas(j).cod_art;
        l_stock := surte_stock.actual(l_codart, g_stocks);
        if p_juego.piezas(j).es_sao = surte_util.gc_true and p_juego.piezas(j).calculo.armar then
          p_juego.piezas(j).stock_actual := l_stock;
          p_juego.piezas(j).saldo_stock := l_stock;
          p_juego.piezas(j).tiene_stock_itm := surte_util.gc_false;
          p_juego.piezas(j).id_color := surte_color.gc_armar;
        elsif l_stock >= p_juego.piezas(j).cantidad then
          p_juego.piezas(j).stock_actual := l_stock;
          p_juego.piezas(j).saldo_stock := l_stock - least(l_stock, p_juego.piezas(j).cantidad);
          p_juego.piezas(j).tiene_stock_itm := surte_util.gc_true;
          p_juego.piezas(j).id_color := surte_color.gc_completo;
          surte_stock.reduce(l_codart, least(l_stock, p_juego.piezas(j).cantidad), g_stocks);
        else
          p_juego.piezas(j).stock_actual := l_stock;
          p_juego.piezas(j).saldo_stock := l_stock - least(l_stock, p_juego.piezas(j).cantidad);
          p_juego.piezas(j).tiene_stock_itm := surte_util.gc_false;
          p_juego.piezas(j).id_color := surte_color.gc_faltante;
          surte_stock.reduce(l_codart, least(l_stock, p_juego.piezas(j).cantidad), g_stocks);
        end if;
        for k in 1 .. p_juego.piezas(j).saos.count loop
          l_codart := p_juego.piezas(j).saos(k).cod_sao;
          l_stock := surte_stock.actual(l_codart, g_stocks);
          p_juego.piezas(j).saos(k).stock_actual := l_stock;
          p_juego.piezas(j).saos(k).saldo_stock := l_stock -
                                                   least(l_stock, p_juego.piezas(j).saos(k).cantidad);
          surte_stock.reduce(
              p_juego.piezas(j).saos(k).cod_sao
            , least(l_stock, p_juego.piezas(j).saos(k).cantidad)
            , g_stocks
            );
          if l_stock >= p_juego.piezas(j).saos(k).cantidad then
            p_juego.piezas(j).saos(k).tiene_stock_itm := surte_util.gc_true;
            p_juego.piezas(j).saos(k).id_color := surte_color.gc_completo;
          else
            p_juego.piezas(j).saos(k).tiene_stock_itm := surte_util.gc_false;
            p_juego.piezas(j).saos(k).id_color := surte_color.gc_faltante;
          end if;
        end loop;
      end loop;
    end;

    procedure falta_importado(
      p_juego in out nocopy surte_struct.juego_rt
    ) is
      l_codart       surte_util.t_articulo;
      l_stock_actual number := 0;
    begin
      p_juego.tiene_stock_ot := 'NO';
      p_juego.valor_surtir := null;
      p_juego.valor_simulado := null;
      p_juego.partir_ot := surte_util.gc_false;
      p_juego.id_color := surte_color.gc_importado;
      for j in 1 .. p_juego.piezas.count loop
        l_codart := p_juego.piezas(j).cod_art;
        l_stock_actual := surte_stock.actual(l_codart, g_stocks);
        p_juego.piezas(j).stock_actual := l_stock_actual;
        p_juego.piezas(j).saldo_stock := null;
        p_juego.piezas(j).cant_final := null;
        if p_juego.piezas(j).es_sao = surte_util.gc_true and p_juego.piezas(j).calculo.armar
          --            l_stock_actual < p_juego.piezas(j).cantidad and
--            l_stock_actual > 0
        then
          p_juego.piezas(j).tiene_stock_itm := surte_util.gc_false;
          p_juego.piezas(j).id_color := surte_color.gc_armar;
        elsif l_stock_actual >= p_juego.piezas(j).cantidad then
          p_juego.piezas(j).tiene_stock_itm := surte_util.gc_true;
          p_juego.piezas(j).id_color := surte_color.gc_completo;
        elsif l_stock_actual < p_juego.piezas(j).cantidad and
              p_juego.piezas(j).es_importado = 1 then
          p_juego.piezas(j).tiene_stock_itm := surte_util.gc_false;
          p_juego.piezas(j).id_color := surte_color.gc_importado;
        else
          p_juego.piezas(j).tiene_stock_itm := surte_util.gc_false;
          p_juego.piezas(j).id_color := surte_color.gc_faltante;
        end if;
        for k in 1 .. p_juego.piezas(j).saos.count loop
          l_codart := p_juego.piezas(j).saos(k).cod_sao;
          l_stock_actual := surte_stock.actual(l_codart, g_stocks);
          p_juego.piezas(j).saos(k).stock_actual := l_stock_actual;
          p_juego.piezas(j).saos(k).saldo_stock := null;
          p_juego.piezas(j).saos(k).cant_final := null;
          if l_stock_actual >= p_juego.piezas(j).saos(k).cantidad then
            p_juego.piezas(j).saos(k).tiene_stock_itm := surte_util.gc_true;
            p_juego.piezas(j).saos(k).id_color := surte_color.gc_completo;
          else
            p_juego.piezas(j).saos(k).tiene_stock_itm := surte_util.gc_false;
            p_juego.piezas(j).saos(k).id_color := surte_color.gc_faltante;
          end if;
        end loop;
      end loop;
    end;

    procedure marca_es_armar(
      p_juego in out nocopy surte_struct.juego_rt
    ) is
    begin
      for j in 1 .. p_juego.piezas.count loop
        if p_juego.piezas(j).id_color = surte_color.gc_armar then
          p_juego.calculo.armar := true;
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
        surte_scanner.analiza(p_juegos(i), g_stocks, g_param);
        -- despues del analisis toma una opcion
        case
          when p_juegos(i).calculo.stock_completo then
            stock_completo(p_juegos(i));
          when p_juegos(i).calculo.podria_partirse then
            parte_orden(p_juegos(i));
          when p_juegos(i).calculo.reserva_stock then
            reserva_stock(p_juegos(i));
          when p_juegos(i).calculo.falta_importado then
            falta_importado(p_juegos(i));
          else
            falta_stock(p_juegos(i));
        end case;
        marca_es_armar(p_juegos(i)); -- mejorar la formar como se marca lo por armar
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
        p_juegos_tmp(p_juegos_tmp.count).cant_prog := p_juegos(i).cant_prog;
        p_juegos_tmp(p_juegos_tmp.count).preuni := p_juegos(i).preuni;
        p_juegos_tmp(p_juegos_tmp.count).valor := p_juegos(i).valor;
        p_juegos_tmp(p_juegos_tmp.count).valor_surtir := p_juegos(i).valor_surtir;
        p_juegos_tmp(p_juegos_tmp.count).valor_simulado := p_juegos(i).valor_simulado;
        p_juegos_tmp(p_juegos_tmp.count).es_juego := p_juegos(i).es_juego;
        p_juegos_tmp(p_juegos_tmp.count).tiene_importado := p_juegos(i).tiene_importado;
        p_juegos_tmp(p_juegos_tmp.count).impreso := p_juegos(i).impreso;
        p_juegos_tmp(p_juegos_tmp.count).fch_impresion := p_juegos(i).fch_impresion;
        p_juegos_tmp(p_juegos_tmp.count).partir_ot := p_juegos(i).partir_ot;
        p_juegos_tmp(p_juegos_tmp.count).cant_partir := p_juegos(i).cant_partir;
        p_juegos_tmp(p_juegos_tmp.count).tiene_stock_ot := p_juegos(i).tiene_stock_ot;
        p_juegos_tmp(p_juegos_tmp.count).es_prioritario := p_juegos(i).es_prioritario;
        p_juegos_tmp(p_juegos_tmp.count).es_reserva := p_juegos(i).es_reserva;
        p_juegos_tmp(p_juegos_tmp.count).es_urgente :=
            surte_util.bool_to_logic(p_juegos(i).calculo.urgente);
        p_juegos_tmp(p_juegos_tmp.count).es_simulacion := p_juegos(i).es_simulacion;
        p_juegos_tmp(p_juegos_tmp.count).es_armar :=
            surte_util.bool_to_logic(p_juegos(i).calculo.armar);
        p_juegos_tmp(p_juegos_tmp.count).cant_faltante := p_juegos(i).calculo.piezas_sin_stock;
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
          p_piezas_tmp(p_piezas_tmp.count).es_armado :=
              surte_util.bool_to_logic(p_juegos(i).piezas(j).calculo.armar);
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
            p_saos_tmp(p_saos_tmp.count).stock_inicial :=
                p_juegos(i).piezas(j).saos(k).stock_inicial;
            p_saos_tmp(p_saos_tmp.count).stock_actual := p_juegos(i).piezas(j).saos(k).stock_actual;
            p_saos_tmp(p_saos_tmp.count).saldo_stock := p_juegos(i).piezas(j).saos(k).saldo_stock;
            p_saos_tmp(p_saos_tmp.count).sobrante := p_juegos(i).piezas(j).saos(k).sobrante;
            p_saos_tmp(p_saos_tmp.count).faltante := p_juegos(i).piezas(j).saos(k).faltante;
            p_saos_tmp(p_saos_tmp.count).cant_final := p_juegos(i).piezas(j).saos(k).cant_final;
            p_saos_tmp(p_saos_tmp.count).es_importado := p_juegos(i).piezas(j).saos(k).es_importado;
            p_saos_tmp(p_saos_tmp.count).tiene_stock_itm :=
                p_juegos(i).piezas(j).saos(k).tiene_stock_itm;
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

    procedure guarda_reserva is
    begin
      insert into reserva_surtimiento(pedido_nro, pedido_itm, ot_tpo, ot_ser, ot_nro, estado)
      select j.nro_pedido, j.itm_pedido, j.ot_tipo, j.ot_serie, j.ot_numero, 0
        from tmp_surte_jgo j
       where j.id_color = surte_color.gc_reserva
         and not exists(
           select 1
             from reserva_surtimiento r
            where j.nro_pedido = r.pedido_nro
              and j.itm_pedido = r.pedido_itm
         );
    exception
      when dup_val_on_index then null;
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
      l_juegos :=
          surte_loader.crea_coleccion(p_pais, p_vendedor, p_dias, p_empaque, p_es_juego, p_orden);
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
      guarda_reserva();
      commit;
    end;
  end;

  procedure guarda_manual is
  begin
    if true then
      insert into tmp_surte_jgo_manual( nro_pedido, itm_pedido, cod_cliente, nom_cliente, fch_pedido
                                      , ot_tipo, ot_serie, ot_numero, cod_jgo, cant_prog
                                      , cant_surtir, valor, valor_surtir, id_color, ranking)
      select nro_pedido, itm_pedido, cod_cliente, nom_cliente, fch_pedido
           , ot_tipo, ot_serie, ot_numero, cod_jgo, cant_prog
           , case when id_color in ('C', 'P') then coalesce(cant_partir, cant_prog) end, valor
           , valor_surtir, id_color, ranking
        from tmp_surte_jgo
       where es_prioritario = 0
          or cod_jgo in (
         select cod_art
           from tmp_selecciona_articulo
         );

      insert into tmp_surte_pza_manual( nro_pedido, itm_pedido, cod_pza, cantidad, rendimiento
                                      , stock_actual, cant_final, linea, es_importado
                                      , tiene_stock_itm, es_sao, es_armado, es_reserva, id_color)
      select nro_pedido, itm_pedido, cod_pza, cantidad, rendimiento
           , stock_actual, cant_final, linea, es_importado
           , tiene_stock_itm, es_sao, es_armado, es_reserva, id_color
        from tmp_surte_pza p
       where exists(
                 select 1
                   from tmp_surte_jgo_manual j
                  where j.nro_pedido = p.nro_pedido
                    and j.itm_pedido = p.itm_pedido
               );
    end if;
  end;

  procedure manual(
    p_pais     varchar2 default null
  , p_vendedor varchar2 default null
  , p_dias     pls_integer default null
  , p_empaque  varchar2 default null
  , p_es_juego pls_integer default null
  , p_orden    pls_integer default 1
  ) is
  begin
    por_item(p_pais, p_vendedor, p_dias, p_empaque, p_es_juego, p_orden);
    guarda_manual();
    commit;
  end;

  procedure emite_sao(
    p_opcion simple_integer
  ) is
  begin
    surte_emite.sao(p_opcion);
  end;

  function total_imprimir return number is
    l_total number := 0;
  begin
    select nvl(sum(valor_surtir), 0)
      into l_total
      from vw_surte_jgo
     where id_color in (surte_color.gc_completo, surte_color.gc_partir);

    return l_total;
  end;

  function total_simulado return number is
    l_total number := 0;
  begin
    select nvl(sum(valor_simulado), 0)
      into l_total
      from vw_surte_jgo
     where id_color in (surte_color.gc_completo, surte_color.gc_partir);

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
/
