declare
    g_param param_surte%rowtype;
    l_juego surte_struct.juego_rt;
    l_stocks surte_stock.aat;
begin
    g_param := api_param_surte.onerow();
    l_stocks('180.490NA').stock_inicial := 414;
    l_stocks('180.490NA').stock_actual := 414;
    l_stocks('SA 90010-3BR').stock_inicial := 140;
    l_stocks('SA 90010-3BR').stock_actual := 140;

    l_juego.ranking := 1;
    l_juego.valor := 9582;
    l_juego.cant_prog := 300;
    l_juego.formu_art := 'KIT MXF HS 3804897 SB';
    l_juego.es_juego := 0;
    l_juego.tiene_importado := 0;
    l_juego.es_prioritario := 0;
    l_juego.valor_surtir := 0;
    l_juego.partir_ot := 0;
    -- pieza con stock
    l_juego.piezas(1).cod_art := '180.490NA';
    l_juego.piezas(1).cantidad := 300;
    l_juego.piezas(1).stock_inicial := 414;
    l_juego.piezas(1).es_importado := 0;
    l_juego.piezas(1).rendimiento := 1;
    l_juego.piezas(1).es_sao := 0;
    -- pieza sin stock pero se puede partir
    l_juego.piezas(2).cod_art := 'SA 90010-3BR';
    l_juego.piezas(2).cantidad := 300;
    l_juego.piezas(2).stock_inicial := 140;
    l_juego.piezas(2).es_importado := 0;
    l_juego.piezas(2).rendimiento := 1;
    l_juego.piezas(2).es_sao := 1;

    surte_scanner.analiza(l_juego, l_stocks, g_param);

    dbms_output.put_line(l_juego.calculo.min_cant_partir);
    dbms_output.put_line(l_juego.calculo.piezas_sin_stock);
end;