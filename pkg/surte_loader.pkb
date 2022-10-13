create or replace package body surte_loader as

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
--            and exists(
--              select *
--                from pedidos_test t
--               where v.pedido = t.numero
--                 and v.pedido_item = t.item
--            )
        )
    select *
      from detalle d
     order by ranking, oa;

  procedure crea_maestro(
    p_pedido in     pedidos_cur%rowtype
  , p_juegos in out surte_struct.juegos_aat
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
  , p_juegos in out nocopy surte_struct.juegos_aat
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

  function crea_coleccion(
    p_pais     varchar2 default null
  , p_vendedor varchar2 default null
  , p_dias     pls_integer default null
  , p_empaque  varchar2 default null
  ) return surte_struct.juegos_aat is
    l_juegos surte_struct.juegos_aat;
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

end surte_loader;