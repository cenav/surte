create or replace package body surte_impresion as

  procedure marca(
    p_tpo_ot varchar2
  , p_ser_ot varchar2
  , p_nro_ot number
  ) is
  begin
    insert into orden_impresa_surtimiento(ot_tpo, ot_ser, ot_nro, usuario, fch_ins)
    values (p_tpo_ot, p_ser_ot, p_nro_ot, user, sysdate);
  exception
    when dup_val_on_index then
      update orden_impresa_surtimiento
         set fch_upd = sysdate
       where ot_tpo = p_tpo_ot
         and ot_ser = p_ser_ot
         and ot_nro = p_nro_ot;
  end;

  procedure temporal(
    p_tpo_ot  varchar2
  , p_ser_ot  varchar2
  , p_nro_ot  number
  , p_usuario varchar2
  ) is
  begin
    insert into tmp_imprime_ot(usuario, tpo_ot, ser_ot, nro_ot)
    values (p_usuario, p_tpo_ot, p_ser_ot, p_nro_ot);
  end;

  procedure temporal(
    p_tpo_ot varchar2
  , p_ser_ot varchar2
  , p_nro_ot number
  ) is
  begin
    temporal(p_tpo_ot, p_ser_ot, p_nro_ot, user);
  end;

  procedure borra(
    p_usuario varchar2
  ) is
  begin
    delete from tmp_imprime_ot where usuario = p_usuario;
  end;

  procedure borra is
  begin
    borra(user);
  end;

  procedure selecciona(
    p_juegos  varchar2
  , p_sueltos varchar2
  ) is
  begin
    update tmp_surte_jgo
       set imprimir = case
                        when id_color in ('C', 'P') and es_simulacion = 0 then
                          case
                            when es_prioritario = 1 then 1
                            when p_juegos = 1 and es_juego = 1 then 1
                            when p_sueltos = 1 and es_juego = 0 then 1
                            else 0
                          end
                        else
                          0
                      end;
  end;
end surte_impresion;
/
