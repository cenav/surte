select *
  from vw_surte_jgo
 where id_color = 'I'
   and (cod_cliente = :cliente or :cliente is null);

create or replace view vw_importado_por_llegar as
  with por_llegar as (
    select cod_art, num_importa, fecha_pedido, cantidad as cantidad_colocada, cantidad_packing
         , etd as fch_embarque, eta as fch_llegada
         , row_number() over (partition by cod_art order by eta, fecha_pedido) as rn
      from view_saldoped_embarque_ingreso
    )
select cod_art, num_importa, fecha_pedido, cantidad_colocada, cantidad_packing, fch_embarque
     , fch_llegada
  from por_llegar
 where rn = 1;

select * from vw_importado_por_llegar;

  with por_llegar as (
    select cod_art, num_importa, fecha_pedido, cantidad_packing, etd as fch_embarque
         , eta as fch_llegada
         , row_number() over (partition by cod_art order by eta, fecha_pedido) as rn
      from view_saldoped_embarque_ingreso
    )
select cod_art, num_importa, fecha_pedido, cantidad_packing, fch_embarque, fch_llegada, rn
  from por_llegar
--  where rn = 1
 where cod_art = 'AKU450.004SIL NB-G';

