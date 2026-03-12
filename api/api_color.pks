create or replace package api_color as

  type aat is table of color%rowtype index by binary_integer;
  type ntt is table of color%rowtype;

  procedure ins(p_rec in color%rowtype);

  procedure ins(p_coll aat);

  procedure upd(p_rec in color%rowtype);

  procedure upd(p_coll aat);

  procedure del(p_id_color in color.id_color%type);

  function onerow(p_id_color in color.id_color%type)
    return color%rowtype result_cache;

  function allrows return aat;

  function exist(p_id_color in color.id_color%type)
    return boolean;

  -- Devuelve colorindex buscando por ID_COLOR
  function colorindex_by_id (p_id_color in color.id_color%type)
    return color.colorindex%type;

  -- Devuelve colorindex buscando por NOM_COLOR
  function colorindex_by_name (p_nom_color in color.nom_color%type)
    return color.colorindex%type;

  -- Permite recargar el cache manualmente
  procedure reload_cache;

end api_color;
