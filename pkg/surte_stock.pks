create or replace package surte_stock as
  subtype stock_t is number;

  type stock_rt is record (
    stock_inicial stock_t,
    stock_actual  stock_t
  );

  type aat is table of stock_rt index by surte_util.t_articulo;

  function carga return aat;

  function actual(
    p_codart surte_util.t_articulo
  , p_stocks aat
  ) return number;


  function inicial(
    p_codart surte_util.t_articulo
  , p_stocks aat
  ) return number;


  procedure reduce(
    p_codart        surte_util.t_articulo
  , p_cantidad      number
  , p_stocks in out aat
  );
end surte_stock;