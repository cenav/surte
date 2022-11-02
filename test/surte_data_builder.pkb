create or replace package body surte_data_builder as

  function juego_completo return surte_struct.juego_rt is
    l_juego surte_struct.juego_rt;
  begin
    l_juego.ranking := 1;
    l_juego.valor := 1000;
    l_juego.cant_prog := 470;
    l_juego.formu_art := 'KIT AUT VK 1535-1 R';
    l_juego.es_juego := 0;
    l_juego.tiene_importado := 0;
    l_juego.es_prioritario := 0;
    l_juego.valor_surtir := 0;
    l_juego.partir_ot := 0;
    -- pieza completa
    l_juego.piezas(1).cod_art := '400.2291SIL';
    l_juego.piezas(1).cantidad := 2820;
    l_juego.piezas(1).stock_inicial := 18570;
    l_juego.piezas(1).es_importado := 0;
    l_juego.piezas(1).rendimiento := 6;
    l_juego.piezas(1).es_sao := 0;
    -- pieza completa
    l_juego.piezas(2).cod_art := '380.820SIL';
    l_juego.piezas(2).cantidad := 470;
    l_juego.piezas(2).stock_inicial := 648;
    l_juego.piezas(2).es_importado := 0;
    l_juego.piezas(2).rendimiento := 1;
    l_juego.piezas(2).es_sao := 0;

    return l_juego;
  end;

  function stocks_completo return surte_stock.aat is
    l_stocks surte_stock.aat;
  begin
    l_stocks('400.2291SIL').stock_inicial := 18570;
    l_stocks('400.2291SIL').stock_actual := 18570;
    l_stocks('380.820SIL').stock_inicial := 648;
    l_stocks('380.820SIL').stock_actual := 648;
    return l_stocks;
  end;

  procedure completo(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  ) is
  begin
    p_juego := juego_completo();
    p_stocks := stocks_completo();
  end;

  function juego_partir return surte_struct.juego_rt is
    l_juego surte_struct.juego_rt;
  begin
    l_juego.ranking := 1;
    l_juego.valor := 460;
    l_juego.cant_prog := 155;
    l_juego.formu_art := 'KIT AUT VK 95360 R';
    l_juego.es_juego := 0;
    l_juego.tiene_importado := 0;
    l_juego.es_prioritario := 0;
    l_juego.valor_surtir := 0;
    l_juego.partir_ot := 0;
    -- pieza con stock
    l_juego.piezas(1).cod_art := '400.2462';
    l_juego.piezas(1).cantidad := 155;
    l_juego.piezas(1).stock_inicial := 2156;
    l_juego.piezas(1).es_importado := 0;
    l_juego.piezas(1).rendimiento := 1;
    l_juego.piezas(1).es_sao := 0;
    -- pieza sin stock pero se puede partir
    l_juego.piezas(2).cod_art := '380.857';
    l_juego.piezas(2).cantidad := 155;
    l_juego.piezas(2).stock_inicial := 41;
    l_juego.piezas(2).es_importado := 0;
    l_juego.piezas(2).rendimiento := 1;
    l_juego.piezas(2).es_sao := 0;
    return l_juego;
  end;

  function stocks_partir return surte_stock.aat is
    l_stocks surte_stock.aat;
  begin
    l_stocks('400.2462').stock_inicial := 2156;
    l_stocks('400.2462').stock_actual := 2156;
    l_stocks('380.857').stock_inicial := 41;
    l_stocks('380.857').stock_actual := 41;
    return l_stocks;
  end;

  procedure partir(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  ) is
  begin
    p_juego := juego_partir();
    p_stocks := stocks_partir();
  end;

  function juego_faltante return surte_struct.juego_rt is
    l_juego surte_struct.juego_rt;
  begin
    l_juego.ranking := 1;
    l_juego.valor := 3112;
    l_juego.cant_prog := 455;
    l_juego.formu_art := 'KIT AUT MS 15202 F A';
    l_juego.es_juego := 0;
    l_juego.tiene_importado := 1;
    l_juego.es_prioritario := 0;
    l_juego.valor_surtir := 0;
    l_juego.partir_ot := 0;
    -- pieza sin stock pero se puede partir
    l_juego.piezas(1).cod_art := '180.618FIB';
    l_juego.piezas(1).cantidad := 455;
    l_juego.piezas(1).stock_inicial := 271;
    l_juego.piezas(1).es_importado := 0;
    l_juego.piezas(1).rendimiento := 1;
    l_juego.piezas(1).es_sao := 0;
    -- pieza sin stock
    l_juego.piezas(2).cod_art := '180.619FIB';
    l_juego.piezas(2).cantidad := 455;
    l_juego.piezas(2).stock_inicial := 0;
    l_juego.piezas(2).es_importado := 0;
    l_juego.piezas(2).rendimiento := 1;
    l_juego.piezas(2).es_sao := 0;
    -- pieza con stock
    l_juego.piezas(3).cod_art := '400.1440SR';
    l_juego.piezas(3).cantidad := 455;
    l_juego.piezas(3).stock_inicial := 4511;
    l_juego.piezas(3).es_importado := 1;
    l_juego.piezas(3).rendimiento := 1;
    l_juego.piezas(3).es_sao := 0;
    return l_juego;
  end;

  function stocks_faltante return surte_stock.aat is
    l_stocks surte_stock.aat;
  begin
    l_stocks('180.618FIB').stock_inicial := 271;
    l_stocks('180.618FIB').stock_actual := 271;
    l_stocks('180.619FIB').stock_inicial := 0;
    l_stocks('180.619FIB').stock_actual := 0;
    l_stocks('400.1440SR').stock_inicial := 4511;
    l_stocks('400.1440SR').stock_actual := 4511;
    return l_stocks;
  end;

  procedure faltante(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  ) is
  begin
    p_juego := juego_faltante();
    p_stocks := stocks_faltante();
  end;

  function juego_importado return surte_struct.juego_rt is
    l_juego surte_struct.juego_rt;
  begin
    l_juego.ranking := 1;
    l_juego.valor := 808;
    l_juego.cant_prog := 80;
    l_juego.formu_art := 'KIT AUT VK 70043 R';
    l_juego.es_juego := 1;
    l_juego.tiene_importado := 1;
    l_juego.es_prioritario := 0;
    l_juego.valor_surtir := 0;
    l_juego.partir_ot := 0;
    -- pieza sin stock pero se puede partir
    l_juego.piezas(1).cod_art := '380.1043SIL';
    l_juego.piezas(1).cantidad := 80;
    l_juego.piezas(1).stock_inicial := 36;
    l_juego.piezas(1).es_importado := 0;
    l_juego.piezas(1).rendimiento := 1;
    l_juego.piezas(1).es_sao := 0;
    -- pieza sin stock y es importada
    l_juego.piezas(2).cod_art := '380.1186SIL';
    l_juego.piezas(2).cantidad := 80;
    l_juego.piezas(2).stock_inicial := 0;
    l_juego.piezas(2).es_importado := 1;
    l_juego.piezas(2).rendimiento := 1;
    l_juego.piezas(2).es_sao := 0;
    -- pieza con stock
    l_juego.piezas(3).cod_art := 'SA 400.2999-26';
    l_juego.piezas(3).cantidad := 80;
    l_juego.piezas(3).stock_inicial := 604;
    l_juego.piezas(3).es_importado := 0;
    l_juego.piezas(3).rendimiento := 1;
    l_juego.piezas(3).es_sao := 1;
    return l_juego;
  end;

  function stocks_importado return surte_stock.aat is
    l_stocks surte_stock.aat;
  begin
    l_stocks('380.1043SIL').stock_inicial := 36;
    l_stocks('380.1043SIL').stock_actual := 36;
    l_stocks('380.1186SIL').stock_inicial := 0;
    l_stocks('380.1186SIL').stock_actual := 0;
    l_stocks('SA 400.2999-26').stock_inicial := 604;
    l_stocks('SA 400.2999-26').stock_actual := 604;
    return l_stocks;
  end;

  procedure importado(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  ) is
  begin
    p_juego := juego_importado();
    p_stocks := stocks_importado();
  end;

  function juego_completo_armar_sao return surte_struct.juego_rt is
    l_juego surte_struct.juego_rt;
  begin
    l_juego.ranking := 1;
    l_juego.valor := 808;
    l_juego.cant_prog := 60;
    l_juego.formu_art := 'KIT AUT VK 1526 R';
    l_juego.es_juego := 1;
    l_juego.tiene_importado := 0;
    l_juego.es_prioritario := 0;
    l_juego.valor_surtir := 0;
    l_juego.partir_ot := 0;
    -- pieza con stock completo
    l_juego.piezas(1).cod_art := '380.775';
    l_juego.piezas(1).cantidad := 60;
    l_juego.piezas(1).stock_inicial := 1571;
    l_juego.piezas(1).es_importado := 0;
    l_juego.piezas(1).rendimiento := 1;
    l_juego.piezas(1).es_sao := 0;
    -- SAO sin stock pero se puede armar
    l_juego.piezas(2).cod_art := 'SAKITVK1526R-1';
    l_juego.piezas(2).cantidad := 60;
    l_juego.piezas(2).stock_inicial := 0;
    l_juego.piezas(2).es_importado := 0;
    l_juego.piezas(2).rendimiento := 1;
    l_juego.piezas(2).es_sao := 1;
    -- detalle SAO con stock
    l_juego.piezas(2).saos(1).cod_sao := '400.2521';
    l_juego.piezas(2).saos(1).cantidad := 360;
    l_juego.piezas(2).saos(1).stock_inicial := 3503;
    l_juego.piezas(2).saos(1).es_importado := 0;
    l_juego.piezas(2).saos(1).rendimiento := 6;
    -- detalle SAO con stock
    l_juego.piezas(2).saos(2).cod_sao := '400.2520';
    l_juego.piezas(2).saos(2).cantidad := 1260;
    l_juego.piezas(2).saos(2).stock_inicial := 4275;
    l_juego.piezas(2).saos(2).es_importado := 0;
    l_juego.piezas(2).saos(2).rendimiento := 21;
    return l_juego;
  end;

  function stocks_completo_armar_sao return surte_stock.aat is
    l_stocks surte_stock.aat;
  begin
    l_stocks('380.775').stock_inicial := 1561;
    l_stocks('380.775').stock_actual := 1561;
    l_stocks('SAKITVK1526R-1').stock_inicial := 0;
    l_stocks('SAKITVK1526R-1').stock_actual := 0;
    l_stocks('400.2521').stock_inicial := 3503;
    l_stocks('400.2521').stock_actual := 3503;
    l_stocks('400.2520').stock_inicial := 4275;
    l_stocks('400.2520').stock_actual := 4275;
    return l_stocks;
  end;

  procedure completo_arma_sao(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  ) is
  begin
    p_juego := juego_completo_armar_sao();
    p_stocks := stocks_completo_armar_sao();
  end;

  function juego_faltante_armar_sao return surte_struct.juego_rt is
    l_juego surte_struct.juego_rt;
  begin
    l_juego.ranking := 1;
    l_juego.valor := 4908;
    l_juego.cant_prog := 95;
    l_juego.formu_art := 'KIT MH FS 66037 BR-07';
    l_juego.es_juego := 1;
    l_juego.tiene_importado := 0;
    l_juego.es_prioritario := 0;
    l_juego.valor_surtir := 0;
    l_juego.partir_ot := 0;
    -- pieza con stock completo
    l_juego.piezas(1).cod_art := '380.793ZN';
    l_juego.piezas(1).cantidad := 570;
    l_juego.piezas(1).stock_inicial := 4014;
    l_juego.piezas(1).es_importado := 1;
    l_juego.piezas(1).rendimiento := 6;
    l_juego.piezas(1).es_sao := 0;
    -- SAO sin stock pero se puede armar
    l_juego.piezas(2).cod_art := 'SA MH66037-3';
    l_juego.piezas(2).cantidad := 95;
    l_juego.piezas(2).stock_inicial := 0;
    l_juego.piezas(2).es_importado := 0;
    l_juego.piezas(2).rendimiento := 1;
    l_juego.piezas(2).es_sao := 1;
    -- detalle SAO sin stock
    l_juego.piezas(2).saos(1).cod_sao := '200.970';
    l_juego.piezas(2).saos(1).cantidad := 95;
    l_juego.piezas(2).saos(1).stock_inicial := 3;
    l_juego.piezas(2).saos(1).es_importado := 0;
    l_juego.piezas(2).saos(1).rendimiento := 1;
    -- detalle SAO con stock
    l_juego.piezas(2).saos(2).cod_sao := '290.3810VMI';
    l_juego.piezas(2).saos(2).cantidad := 95;
    l_juego.piezas(2).saos(2).stock_inicial := 592;
    l_juego.piezas(2).saos(2).es_importado := 0;
    l_juego.piezas(2).saos(2).rendimiento := 1;
    return l_juego;
  end;

  function stocks_faltante_armar_sao return surte_stock.aat is
    l_stocks surte_stock.aat;
  begin
    l_stocks('380.793ZN').stock_inicial := 4014;
    l_stocks('380.793ZN').stock_actual := 4014;
    l_stocks('SA MH66037-3').stock_inicial := 0;
    l_stocks('SA MH66037-3').stock_actual := 0;
    l_stocks('200.970').stock_inicial := 3;
    l_stocks('200.970').stock_actual := 3;
    l_stocks('290.3810VMI').stock_inicial := 592;
    l_stocks('290.3810VMI').stock_actual := 592;
    return l_stocks;
  end;

  procedure faltante_arma_sao(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  ) is
  begin
    p_juego := juego_faltante_armar_sao();
    p_stocks := stocks_faltante_armar_sao();
  end;

  function juego_parte_armar_sao return surte_struct.juego_rt is
    l_juego surte_struct.juego_rt;
  begin
    l_juego.ranking := 1;
    l_juego.valor := 4908;
    l_juego.cant_prog := 95;
    l_juego.formu_art := 'KIT MH FS 66037 BR-07';
    l_juego.es_juego := 1;
    l_juego.tiene_importado := 0;
    l_juego.es_prioritario := 0;
    l_juego.valor_surtir := 0;
    l_juego.partir_ot := 0;
    -- pieza con stock completo
    l_juego.piezas(1).cod_art := '380.793ZN';
    l_juego.piezas(1).cantidad := 570;
    l_juego.piezas(1).stock_inicial := 4014;
    l_juego.piezas(1).es_importado := 1;
    l_juego.piezas(1).rendimiento := 6;
    l_juego.piezas(1).es_sao := 0;
    -- SAO sin stock pero se puede armar
    l_juego.piezas(2).cod_art := 'SA MH66037-3';
    l_juego.piezas(2).cantidad := 95;
    l_juego.piezas(2).stock_inicial := 0;
    l_juego.piezas(2).es_importado := 0;
    l_juego.piezas(2).rendimiento := 1;
    l_juego.piezas(2).es_sao := 1;
    -- detalle SAO sin stock completo pero se puede partir
    l_juego.piezas(2).saos(1).cod_sao := '200.970';
    l_juego.piezas(2).saos(1).cantidad := 95;
    l_juego.piezas(2).saos(1).stock_inicial := 79;
    l_juego.piezas(2).saos(1).es_importado := 0;
    l_juego.piezas(2).saos(1).rendimiento := 1;
    -- detalle SAO con stock
    l_juego.piezas(2).saos(2).cod_sao := '290.3810VMI';
    l_juego.piezas(2).saos(2).cantidad := 95;
    l_juego.piezas(2).saos(2).stock_inicial := 890;
    l_juego.piezas(2).saos(2).es_importado := 0;
    l_juego.piezas(2).saos(2).rendimiento := 1;
    return l_juego;
  end;

  function stocks_parte_armar_sao return surte_stock.aat is
    l_stocks surte_stock.aat;
  begin
    l_stocks('380.793ZN').stock_inicial := 4014;
    l_stocks('380.793ZN').stock_actual := 4014;
    l_stocks('SA MH66037-3').stock_inicial := 0;
    l_stocks('SA MH66037-3').stock_actual := 0;
    l_stocks('200.970').stock_inicial := 79;
    l_stocks('200.970').stock_actual := 79;
    l_stocks('290.3810VMI').stock_inicial := 890;
    l_stocks('290.3810VMI').stock_actual := 890;
    return l_stocks;
  end;

  procedure parte_arma_sao(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  ) is
  begin
    p_juego := juego_parte_armar_sao();
    p_stocks := stocks_parte_armar_sao();
  end;

  procedure stock_incompleto_arma_sao(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  ) is
  begin
    p_juego.ranking := 1;
    p_juego.valor := 46;
    p_juego.cant_prog := 10;
    p_juego.formu_art := 'VK 81200 R';
    p_juego.es_juego := 1;
    p_juego.tiene_importado := 0;
    p_juego.es_prioritario := 0;
    p_juego.valor_surtir := 0;
    p_juego.partir_ot := 0;
    -- pieza con stock completo
    p_juego.piezas(1).cod_art := '380.783';
    p_juego.piezas(1).cantidad := 20;
    p_juego.piezas(1).stock_inicial := 1515;
    p_juego.piezas(1).es_importado := 0;
    p_juego.piezas(1).rendimiento := 2;
    p_juego.piezas(1).es_sao := 0;
    -- SAO sin stock pero se puede armar
    p_juego.piezas(2).cod_art := 'SA400.2074-6';
    p_juego.piezas(2).cantidad := 10;
    p_juego.piezas(2).stock_inicial := 142;
    p_juego.piezas(2).es_importado := 0;
    p_juego.piezas(2).rendimiento := 1;
    p_juego.piezas(2).es_sao := 1;
    -- detalle SAO sin stock completo pero se puede partir
    p_juego.piezas(2).saos(1).cod_sao := '400.2074';
    p_juego.piezas(2).saos(1).cantidad := 60;
    p_juego.piezas(2).saos(1).stock_inicial := 117;
    p_juego.piezas(2).saos(1).es_importado := 0;
    p_juego.piezas(2).saos(1).rendimiento := 6;
    -- stocks
    p_stocks('380.783').stock_inicial := 1515;
    p_stocks('380.783').stock_actual := 1235;
    p_stocks('SA400.2074-6').stock_inicial := 142;
    p_stocks('SA400.2074-6').stock_actual := 2;
    p_stocks('400.2074').stock_inicial := 117;
    p_stocks('400.2074').stock_actual := 117;
  end;

  procedure no_quiere_partir(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  ) is
  begin
    p_juego.ranking := 1;
    p_juego.valor := 4635;
    p_juego.cant_prog := 70;
    p_juego.formu_art := 'KIT AUT FS 1262 MX1 TG';
    p_juego.es_juego := 1;
    p_juego.tiene_importado := 0;
    p_juego.es_prioritario := 0;
    p_juego.valor_surtir := 0;
    p_juego.partir_ot := 0;
    p_juego.preuni := 66;
    -- pieza con stock completo rendimiento 2
    p_juego.piezas(1).cod_art := '200.2644SA';
    p_juego.piezas(1).cantidad := 140;
    p_juego.piezas(1).stock_inicial := 3750;
    p_juego.piezas(1).es_importado := 0;
    p_juego.piezas(1).rendimiento := 2;
    p_juego.piezas(1).es_sao := 0;
    -- pieza con stock completo rendimiento 1
    p_juego.piezas(2).cod_art := '200.265ALR';
    p_juego.piezas(2).cantidad := 70;
    p_juego.piezas(2).stock_inicial := 1885;
    p_juego.piezas(2).es_importado := 0;
    p_juego.piezas(2).rendimiento := 1;
    p_juego.piezas(2).es_sao := 0;
    -- pieza sin stock pero se puede partir rendimiento 2
    p_juego.piezas(3).cod_art := '180.914FIB';
    p_juego.piezas(3).cantidad := 140;
    p_juego.piezas(3).stock_inicial := 12;
    p_juego.piezas(3).es_importado := 0;
    p_juego.piezas(3).rendimiento := 2;
    p_juego.piezas(3).es_sao := 0;
    -- pieza sin stock pero se puede partir rendimiento 1
    p_juego.piezas(4).cod_art := '200.2107ALR';
    p_juego.piezas(4).cantidad := 70;
    p_juego.piezas(4).stock_inicial := 55;
    p_juego.piezas(4).es_importado := 0;
    p_juego.piezas(4).rendimiento := 1;
    p_juego.piezas(4).es_sao := 0;
    -- stocks
    p_stocks('200.2644SA').stock_inicial := 3750;
    p_stocks('200.2644SA').stock_actual := 3750;
    p_stocks('200.265ALR').stock_inicial := 1885;
    p_stocks('200.265ALR').stock_actual := 1885;
    p_stocks('180.914FIB').stock_inicial := 12;
    p_stocks('180.914FIB').stock_actual := 12;
    p_stocks('200.2107ALR').stock_inicial := 55;
    p_stocks('200.2107ALR').stock_actual := 55;
  end;

  procedure faltante_suelto(
    p_juego out nocopy  surte_struct.juego_rt
  , p_stocks out nocopy surte_stock.aat
  ) is
  begin
    p_juego.ranking := 1;
    p_juego.valor := 524;
    p_juego.cant_prog := 105;
    p_juego.formu_art := 'KIT AUT OS 32118 S R';
    p_juego.es_juego := 0;
    p_juego.tiene_importado := 0;
    p_juego.es_prioritario := 0;
    p_juego.valor_surtir := 0;
    p_juego.partir_ot := 0;
    -- pieza sin stock
    p_juego.piezas(1).cod_art := '300.346SR';
    p_juego.piezas(1).cantidad := 105;
    p_juego.piezas(1).es_importado := 0;
    p_juego.piezas(1).rendimiento := 1;
    p_juego.piezas(1).es_sao := 0;
    -- stocks
    p_stocks('300.346SR').stock_actual := 1;
  end;

end surte_data_builder;