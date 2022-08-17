create or replace package api_expednac_d as
  type aat is table of expednac_d%rowtype index by binary_integer;
  type ntt is table of expednac_d%rowtype;

  procedure ins(
    p_rec in expednac_d%rowtype
  );

  procedure ins(
    p_coll aat
  );

  procedure upd(
    p_rec in expednac_d%rowtype
  );

  procedure upd(
    p_coll aat
  );

  procedure del(
    p_numero in expednac_d.numero%type
  , p_nro in    expednac_d.nro%type
  );

  function onerow(
    p_numero in expednac_d.numero%type
  , p_nro in    expednac_d.nro%type
  ) return expednac_d%rowtype result_cache;

  function allrows return aat;

  function exist(
    p_numero in expednac_d.numero%type
  , p_nro in    expednac_d.nro%type
  ) return boolean;

  function next_key(
    p_numero expednac_d.numero%type
  ) return expednac_d.nro%type;
end api_expednac_d;
/

create or replace package body api_expednac_d as
  forall_err exception;
  pragma exception_init (forall_err, -24381);

  procedure ins(
    p_rec in expednac_d%rowtype
  ) is
  begin
    insert into expednac_d
    values p_rec;
  end;

  procedure ins(
    p_coll in aat
  ) is
  begin
    forall i in 1 .. p_coll.count save exceptions
      insert into expednac_d values p_coll(i);
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).numero ||
                   ' ^ ' || p_coll(sql%bulk_exceptions(i).error_index).nro ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));

      end loop;
      raise;
  end;

  procedure upd(
    p_rec in expednac_d%rowtype
  ) is
  begin
    update expednac_d t
       set row = p_rec
     where t.numero = p_rec.numero and t.nro = p_rec.nro;
  end;

  procedure upd(
    p_coll in aat
  ) is
  begin
    forall i in 1 .. p_coll.count save exceptions
      update expednac_d
         set row = p_coll(i)
       where numero = p_coll(i).numero and nro = p_coll(i).nro;
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).numero ||
                   ' ^ ' || p_coll(sql%bulk_exceptions(i).error_index).nro ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));
      end loop;
      raise;
  end;

  procedure del(
    p_numero in expednac_d.numero%type
  , p_nro in    expednac_d.nro%type
  ) is
  begin
    delete
      from expednac_d t
     where t.numero = p_numero and t.nro = p_nro;
  end;

  function onerow(
    p_numero in expednac_d.numero%type
  , p_nro in    expednac_d.nro%type
  ) return expednac_d%rowtype result_cache is
    rec expednac_d%rowtype;
  begin
    select *
      into rec
      from expednac_d t
     where t.numero = p_numero and t.nro = p_nro;

    return rec;
  exception
    when no_data_found then
      return null;
    when too_many_rows then
      raise;
  end;

  function allrows return aat is
    coll aat;
  begin
    select * bulk collect
      into coll
      from expednac_d;

    return coll;
  end;

  function exist(
    p_numero in expednac_d.numero%type
  , p_nro in    expednac_d.nro%type
  ) return boolean is
    dummy pls_integer;
  begin
    select 1
      into dummy
      from expednac_d t
     where t.numero = p_numero and t.nro = p_nro;

    return true;
  exception
    when no_data_found then
      return false;
    when too_many_rows then
      return true;
  end;

  function next_key(
    p_numero expednac_d.numero%type
  ) return expednac_d.nro%type is
    l_key expednac_d.nro%type;
  begin
    select nvl(max(nro), 0) + 1
      into l_key
      from expednac_d
     where numero = p_numero;

    return l_key;
  end;
end api_expednac_d;

create or replace public synonym api_expednac_d for api_expednac_d;