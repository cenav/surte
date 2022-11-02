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
    p_tpo_ot  varchar2
  , p_ser_ot  varchar2
  , p_nro_ot  number
  );

  procedure borra(
    p_usuario varchar2 default user
  );

  procedure borra;

end surte_impresion;
/

