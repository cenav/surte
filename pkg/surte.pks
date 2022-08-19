create or replace package surte as
  procedure por_cliente(
    p_cliente varchar2
  , p_opcion  opcion_enum.t_opcion
  );

  procedure por_item(
    p_pais     varchar2 default null
  , p_vendedor varchar2 default null
  , p_dias     pls_integer default null
  );

  procedure parte_ot(
    p_tipo        pr_ot.nuot_tipoot_codigo%type
  , p_serie       pr_ot.nuot_serie%type
  , p_numero      pr_ot.numero%type
  , p_cant_partir pr_ot.cant_prog%type
  );

  procedure parte_ot_masivo;
end surte;
