select to_number(cod_cliente) as id_cliente, cod_cliente, cod_notac, porcentaje
  from exclientes_notacredito
 order by cod_cliente;


select to_number(nc.cod_cliente) as id_cliente
     , c.nombre as cliente
     , sum(nc.porcentaje) as porc
  from exclientes_notacredito nc
       join exclientes c on to_number(nc.cod_cliente) = c.cod_cliente
 group by to_number(nc.cod_cliente), c.nombre;

select *
  from exclientes
 where cod_cliente = '996057';

select *
  from expedidos
 where numero = 17288;

-- 17288
-- 505
-- 411.2

-- 17322
-- 427;
-- 2200

  with descuentos as (
    select to_number(cod_cliente) as id_cliente, sum(porcentaje) as porc_desc
      from exclientes_notacredito
     group by to_number(cod_cliente)
    )
select p.numero, p.nro, p.cod_art, p.canti, p.preuni, p.totlin, p.canti * p.preuni as tot_calc
     , d.porc_desc, round(p.totlin * (1 - nvl(d.porc_desc, 0) / 100), 2) as totfin
  from expedido_d p
       left join descuentos d on p.cod_cliente = d.id_cliente
 where p.numero = 17288
   and p.nro = 505;


select * from vw_ordenes_pedido_pendiente;