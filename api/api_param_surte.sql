create or replace package api_param_surte as
  type aat is table of param_surte%rowtype index by binary_integer;
  type ntt is table of param_surte%rowtype;

  procedure ins(
    p_rec in param_surte%rowtype
  );

  procedure ins(
    p_coll aat
  );

  procedure upd(
    p_rec in param_surte%rowtype
  );

  procedure upd(
    p_coll aat
  );

  procedure del(
    p_id_param in param_surte.id_param%type
  );

  function onerow(
    p_id_param in param_surte.id_param%type default 1
  ) return param_surte%rowtype result_cache;

  function allrows return aat;

  function exist(
    p_id_param in param_surte.id_param%type
  ) return boolean;
end api_param_surte;
/

create or replace package body api_param_surte as
  forall_err exception;
  pragma exception_init (forall_err, -24381);

  procedure ins(
    p_rec in param_surte%rowtype
  ) is
  begin
    insert into param_surte
    values p_rec;
  end;

  procedure ins(
    p_coll in aat
  ) is
  begin
    forall i in 1 .. p_coll.count save exceptions
      insert into param_surte values p_coll(i);
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_param ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));

      end loop;
      raise;
  end;

  procedure upd(
    p_rec in param_surte%rowtype
  ) is
  begin
    update param_surte t
       set row = p_rec
     where t.id_param = p_rec.id_param;
  end;

  procedure upd(
    p_coll in aat
  ) is
  begin
    forall i in 1 .. p_coll.count save exceptions
      update param_surte
         set row = p_coll(i)
       where id_param = p_coll(i).id_param;
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_param ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));
      end loop;
      raise;
  end;

  procedure del(
    p_id_param in param_surte.id_param%type
  ) is
  begin
    delete
      from param_surte t
     where t.id_param = p_id_param;
  end;

  function onerow(
    p_id_param in param_surte.id_param%type
  ) return param_surte%rowtype result_cache is
    rec param_surte%rowtype;
  begin
    select *
      into rec
      from param_surte t
     where t.id_param = p_id_param;

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
      from param_surte;

    return coll;
  end;

  function exist(
    p_id_param in param_surte.id_param%type
  ) return boolean is
    dummy pls_integer;
  begin
    select 1
      into dummy
      from param_surte t
     where t.id_param = p_id_param;

    return true;
  exception
    when no_data_found then
      return false;
    when too_many_rows then
      return true;
  end;
end api_param_surte;

create or replace public synonym api_param_surte for api_param_surte;