create or replace package surte_impresion as

  procedure marca(
    p_tpo_ot varchar2
  , p_ser_ot varchar2
  , p_nro_ot number
  );

  procedure temporal(
    p_tpo_ot  varchar2
  , p_ser_ot  varchar2
  , p_nro_ot  number
  , p_usuario varchar2
  );

  procedure temporal(
    p_tpo_ot varchar2
  , p_ser_ot varchar2
  , p_nro_ot number
  );

  procedure borra(
    p_usuario varchar2
  );

  procedure borra;

  procedure selecciona(
    p_juegos  varchar2
  , p_sueltos varchar2
  );

end surte_impresion;
/
