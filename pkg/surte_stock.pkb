create or replace package body surte_stock as
  function carga return aat is
    l_stocks aat;

    procedure piezas(
      p_stocks in out nocopy aat
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
      p_stocks in out nocopy aat
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

  function actual(
    p_codart surte_util.t_articulo
  , p_stocks aat
  ) return number is
  begin
    return case when p_stocks.exists(p_codart) then p_stocks(p_codart).stock_actual else 0 end;
  end;

  function inicial(
    p_codart surte_util.t_articulo
  , p_stocks aat
  ) return number is
  begin
    return case when p_stocks.exists(p_codart) then p_stocks(p_codart).stock_inicial else 0 end;
  end;

  procedure reduce(
    p_codart        surte_util.t_articulo
  , p_cantidad      number
  , p_stocks in out aat
  ) is
  begin
    p_stocks(p_codart).stock_actual := p_stocks(p_codart).stock_actual - p_cantidad;
  end;
end surte_stock;