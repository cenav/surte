create or replace package surte_calculo as
  type detail_rt is record (
    stock_actual  number,
    rendimiento   number,
    faltante      number,
    cant_final    number,
    tiene_stock   boolean,
    sao_sin_stock boolean
  );

  type detail_nt is table of detail_rt;

  type header_rt is record (
    tiene_stock_ot      boolean := true,
    puede_partirse      boolean := true,
    importado_sin_stock boolean := false,
    es_partible         boolean,
    detail              detail_nt
  );

  type header_nt is table of header_rt;

  function make_header return header_rt;

  procedure add_header(
    p_headers in out nocopy header_nt
  , p_header                header_rt
  );

  function make_detail return detail_rt;

  procedure add_detail(
    p_details in out nocopy detail_nt
  , p_detail                detail_rt
  );
end surte_calculo;