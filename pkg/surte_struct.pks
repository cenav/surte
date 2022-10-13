create or replace package surte_struct as
  type calc_detail_rt is record (
    stock_actual number,
    rendimiento  number,
    faltante     number,
    cant_final   number,
    cant_patir   number,
    tiene_stock  boolean
  );

  type calc_header_rt is record (
    stock_completo   boolean := true,
    podria_partirse  boolean := true,
    es_partible      boolean := true,
    tiene_stock_ot   boolean := true,
    armar            boolean := true,
    falta_importado  boolean := false,
    min_cant_partir  number := surte_util.gc_infinito,
    piezas_sin_stock number := 0,
    peso             number
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

  type juegos_aat is table of juego_rt index by surte_util.t_ranking;

  type tmp_jgo_aat is table of tmp_surte_jgo%rowtype index by pls_integer;
  type tmp_pza_aat is table of tmp_surte_pza%rowtype index by pls_integer;
  type tmp_sao_aat is table of tmp_surte_sao%rowtype index by pls_integer;
end surte_struct;