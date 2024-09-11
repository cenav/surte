create or replace package body pevisa.surte_emite as
  /*
    private routines
  */
  procedure emite_completo is
    l_ot pr_ot%rowtype;
    l_id number;
  begin
    select nvl(max(id_emision), 0) + 1
      into l_id
      from orden_emitida_surte_h;

    insert into orden_emitida_surte_h(id_emision, fch_emision, usuario)
    values (l_id, sysdate, user);

    for r in (
      select p.cod_pza, sum(p.cant_final) as cant_emitir
           , row_number() over (order by p.cod_pza) as item
        from tmp_surte_jgo j
             join tmp_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
       where j.es_armar = 1
         and j.id_color in ('C', 'P')
         and p.es_armado = 1
         and not exists(
         -- items ya emitidos
         select 1
           from vw_orden_emitida_surte_pedido o
          where o.ped_nro = p.nro_pedido
            and o.ped_itm = p.itm_pedido
            and o.cod_art = p.cod_pza
         )
       group by p.cod_pza
       order by cod_pza
      )
    loop
      emite.sao(r.cod_pza, r.cant_emitir, l_ot);

      insert into orden_emitida_surte_m(id_emision, id_item, ot_tpo, ot_ser, ot_nro, cod_art)
      values (l_id, r.item, l_ot.nuot_tipoot_codigo, l_ot.nuot_serie, l_ot.numero, r.cod_pza);

      insert into orden_emitida_surte_l(id_emision, id_item, id_subitem, ped_nro, ped_itm)
      select l_id, r.item, row_number() over (order by p.cod_pza) as subitem
           , p.nro_pedido, p.itm_pedido
        from tmp_surte_jgo j
             join tmp_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
       where j.es_armar = 1
         and j.id_color in ('C', 'P')
         and p.es_armado = 1
         and p.cod_pza = r.cod_pza
       order by cod_pza;
    end loop;
  end;

  procedure emite_todo is
    l_ot pr_ot%rowtype;
    l_id number;
  begin
    select nvl(max(id_emision), 0) + 1
      into l_id
      from orden_emitida_surte_h;

    insert into orden_emitida_surte_h(id_emision, fch_emision, usuario)
    values (l_id, sysdate, user);

    for r in (
      select p.cod_pza, sum(coalesce(p.cant_final, p.cantidad)) as cant_emitir
           , row_number() over (order by p.cod_pza) as item
        from tmp_surte_pza p
       where p.es_armado = 1
         and not exists(
         -- items ya emitidos
         select 1
           from vw_orden_emitida_surte_pedido o
          where o.ped_nro = p.nro_pedido
            and o.ped_itm = p.itm_pedido
            and o.cod_art = p.cod_pza
         )
       group by p.cod_pza
      )
    loop
      emite.sao(r.cod_pza, r.cant_emitir, l_ot);

      insert into orden_emitida_surte_m(id_emision, id_item, ot_tpo, ot_ser, ot_nro, cod_art)
      values (l_id, r.item, l_ot.nuot_tipoot_codigo, l_ot.nuot_serie, l_ot.numero, r.cod_pza);

      insert into orden_emitida_surte_l(id_emision, id_item, id_subitem, ped_nro, ped_itm)
      select l_id, r.item, row_number() over (order by p.cod_pza) as subitem
           , p.nro_pedido, p.itm_pedido
        from tmp_surte_pza p
       where p.es_armado = 1
         and p.cod_pza = r.cod_pza
       order by cod_pza;
    end loop;
  end;

/*
  public routines
*/
  procedure sao(
    p_opcion simple_integer
  ) is
  begin
    case p_opcion
      when 1 then emite_completo();
      when 2 then emite_todo();
    end case;
  end;
end surte_emite;