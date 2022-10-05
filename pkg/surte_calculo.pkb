create or replace package body surte_calculo as
  function make_header return header_rt is
    l_header header_rt;
  begin
    l_header.tiene_stock_ot := true;
    l_header.puede_partirse := true;
    l_header.es_partible := true;
    l_header.detail := detail_nt();
    return l_header;
  end;

  procedure add_header(
    p_headers in out nocopy header_nt
  , p_header                header_rt
  ) is
    l_idx pls_integer;
  begin
    p_headers.extend();
    l_idx := p_headers.last;
    p_headers(l_idx) := p_header;
  end;

  function make_detail return detail_rt is
    l_detail detail_rt;
  begin
    l_detail.stock_actual := 0;
    l_detail.rendimiento := 0;
    l_detail.cant_final := 0;
    l_detail.tiene_stock := false;
    return l_detail;
  end;

  procedure add_detail(
    p_details in out nocopy detail_nt
  , p_detail                detail_rt
  ) is
    l_idx pls_integer;
  begin
    p_details.extend();
    l_idx := p_details.last;
    p_details(l_idx) := p_detail;
  end;
end surte_calculo;