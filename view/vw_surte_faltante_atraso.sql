create or replace view vw_surte_faltante_atraso as
  with pedidos as (
    select cod_cliente, nom_cliente, nro_pedido, itm_pedido, valor, fch_pedido
         , ranking, trunc(sysdate) - fch_pedido as dias
      from tmp_surte_faltante
     group by cod_cliente, nom_cliente, nro_pedido, itm_pedido, valor, fch_pedido
            , ranking
    )
select p.cod_cliente, p.nom_cliente
     , sum(case when dias <= 90 then valor else 0 end) as menos_90_dias
     , sum(case when dias >= 91 and dias <= 180 then valor else 0 end) as entre_90_180_dias
     , sum(case when dias >= 181 and dias <= 360 then valor else 0 end) as entre_180_360_dias
     , sum(case when dias >= 361 then valor else 0 end) as mas_360_dias
     , sum(valor) as total
     , min(p.ranking) as ranking
  from pedidos p
 group by p.cod_cliente, p.nom_cliente
 order by ranking;

create or replace public synonym vw_surte_faltante_atraso for pevisa.vw_surte_faltante_atraso;