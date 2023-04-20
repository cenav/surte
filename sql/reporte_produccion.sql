select a.dsc_grupo, p.cod_pza, a.cod_lin
     , sum(p.cantidad) as cantidad
  from vw_surte_jgo j
       join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
       join vw_articulo a on p.cod_pza = a.cod_art
 where j.id_color in ('R', 'F')
   and p.id_color = 'F'
   and p.es_sao = 'NO'
--    and ((j.es_simulacion like :p_simulacion) and
--         (j.es_urgente like :p_urgente) and
--         (j.cant_faltante = :p_faltante or :p_faltante is null))
 group by a.dsc_grupo, p.cod_pza, a.cod_lin
 order by dsc_grupo, cod_pza;


-- resumen cliente dias atraso faltante
  with pedidos as (
    select j.cod_cliente, j.nom_cliente, j.nro_pedido, j.itm_pedido, j.valor, j.fch_pedido
         , j.ranking, trunc(sysdate) - j.fch_pedido as dias
      from vw_surte_jgo j
           join vw_surte_pza p on j.nro_pedido = p.nro_pedido and j.itm_pedido = p.itm_pedido
           join vw_articulo a on p.cod_pza = a.cod_art
     where j.id_color in ('R', 'F')
       and p.id_color = 'F'
       and p.es_sao = 'NO'
     group by j.cod_cliente, j.nom_cliente, j.nro_pedido, j.itm_pedido, j.valor, j.fch_pedido
            , j.ranking
    )
select p.cod_cliente, p.nom_cliente
     , sum(case when dias >= 90 and dias < 180 then valor else 0 end) as entre_90_180_dias
     , sum(case when dias >= 180 and dias < 360 then valor else 0 end) as entre_180_360_dias
     , sum(case when dias >= 360 then valor else 0 end) as mas_360_dias
     , sum(case when dias >= 90 then valor else 0 end) as mas_90_dias
     , sum(case when dias < 90 then valor else 0 end) as menos_90_dias
     , sum(valor) as total
     , min(p.ranking) as ranking
  from pedidos p
 group by p.cod_cliente, p.nom_cliente
 order by ranking;

select * from vw_surte_jgo;

-- CREATE USER ksiguenas PROFILE 'profile_usuario_sig';
alter user pruebas account unlock;


alter user oquintana account lock;


alter user pruebas identified by "pevisa.123";


alter user pruebas password expire;


grant select any table, insert any table, delete any table, update any table to asocial;

-- Account locked
select username, account_status, created, lock_date, expiry_date
  from dba_users
 where username like 'PRUEBAS';

select *
  from tmp_surte_jgo
 where nro_pedido = 15604;

select *
  from vw_surte_jgo
 where nro_pedido = 15604
   and itm_pedido = 15;