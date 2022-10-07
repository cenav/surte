create or replace package surte_parte as
  procedure parte_ot(
    p_tipo        pr_ot.nuot_tipoot_codigo%type
  , p_serie       pr_ot.nuot_serie%type
  , p_numero      pr_ot.numero%type
  , p_cant_partir pr_ot.cant_prog%type
  );

  procedure ot_masivo;

  procedure ot_masivo(
    p_prioritario pls_integer
  );
end surte_parte;