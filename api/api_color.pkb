create or replace package body api_color as

  forall_err exception;
  pragma exception_init (forall_err, -24381);

  ------------------------------------------------------------------
  -- Tipos de colección
  ------------------------------------------------------------------

  type t_color_by_id is table of color.colorindex%type
    index by varchar2(2);

  type t_color_by_name is table of color.colorindex%type
    index by varchar2(50);

  ------------------------------------------------------------------
  -- Variables globales (cache)
  ------------------------------------------------------------------

  g_color_by_id t_color_by_id;
  g_color_by_name t_color_by_name;
  g_loaded boolean := false;

  procedure ins(
    p_rec in color%rowtype
  ) is
  begin
    insert into color
    values p_rec;
  end;

  procedure ins(
    p_coll in aat
  ) is
  begin
    forall i in 1 .. p_coll.count save exceptions
      insert into color values p_coll
    (i);
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_color ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));

      end loop;
      raise;
  end;

  procedure upd(
    p_rec in color%rowtype
  ) is
  begin
    update color t
       set row = p_rec
     where t.id_color = p_rec.id_color;
  end;

  procedure upd(
    p_coll in aat
  ) is
  begin
    forall i in 1 .. p_coll.count save exceptions
      update color
         set row = p_coll(i)
       where id_color = p_coll(i).id_color;
  exception
    when forall_err then
      for i in 1 .. sql%bulk_exceptions.COUNT loop
        logger.log('PK: ' || p_coll(sql%bulk_exceptions(i).error_index).id_color ||
                   ' Err: ' || sqlerrm(sql%bulk_exceptions(i).error_code * -1));
      end loop;
      raise;
  end;

  procedure del(
    p_id_color in color.id_color%type
  ) is
  begin
    delete
      from color t
     where t.id_color = p_id_color;
  end;

  function onerow(
    p_id_color in color.id_color%type
  ) return color%rowtype result_cache is
    rec color%rowtype;
  begin
    select *
      into rec
      from color t
     where t.id_color = p_id_color;

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
      from color;

    return coll;
  end;

  function exist(
    p_id_color in color.id_color%type
  ) return boolean is
    dummy pls_integer;
  begin
    select 1
      into dummy
      from color t
     where t.id_color = p_id_color;

    return true;
  exception
    when no_data_found then
      return false;
    when too_many_rows then
      return true;
  end;


  ------------------------------------------------------------------
  -- Cargar cache
  ------------------------------------------------------------------

  procedure load_cache is
  begin
    g_color_by_id.delete;
    g_color_by_name.delete;

    for r in (
      select id_color, nom_color, colorindex
        from color
      )
    loop
      g_color_by_id(r.id_color) := r.colorindex;
      g_color_by_name(upper(r.nom_color)) := r.colorindex;
    end loop;

    g_loaded := true;
  end load_cache;

  ------------------------------------------------------------------
  -- Recargar manualmente
  ------------------------------------------------------------------

  procedure reload_cache is
  begin
    g_loaded := false;
    load_cache;
  end reload_cache;

  ------------------------------------------------------------------
  -- Obtener por ID
  ------------------------------------------------------------------

  function colorindex_by_id (p_id_color in color.id_color%type)
    return color.colorindex%type is
  begin
    if not g_loaded then
      load_cache;
    end if;

    return g_color_by_id(p_id_color);

  exception
    when no_data_found then
      return null;
  end colorindex_by_id;

  ------------------------------------------------------------------
  -- Obtener por Nombre
  ------------------------------------------------------------------

  function colorindex_by_name (p_nom_color in color.nom_color%type)
    return color.colorindex%type is
  begin
    if not g_loaded then
      load_cache;
    end if;

    return g_color_by_name(upper(p_nom_color));

  exception
    when no_data_found then
      return null;
  end colorindex_by_name;

end api_color;