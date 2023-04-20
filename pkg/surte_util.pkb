create or replace package body surte_util as

  function bool_to_logic(
    p_bool boolean
  ) return signtype is
  begin
    return case when p_bool then gc_true else gc_false end;
  end;

  function material(
    p_formu_cod_art pr_for_ins.formu_art_cod_art%type
  )
    return varchar2 is
    cursor cur_material is
      select f.art_cod_art
        from pr_for_ins f
             join articul a on f.art_cod_art = a.cod_art
       where f.formu_art_cod_art = p_formu_cod_art
         and (a.cod_lin in ('1601', '2004', '2005') or
              (a.cod_lin between '1620' and '1634') or
              (a.cod_lin between '2010' and '2019'))
         and length(a.cod_lin) = 4;

    l_return pkg_types.maxvarchar2;
  begin
    for rec in cur_material loop
      l_return := l_return || ', ' || rec.art_cod_art;
    end loop;

    return substr(l_return, 3);
  end ;

  function ribete(
    p_formu_cod_art pr_for_ins.formu_art_cod_art%type
  )
    return varchar2 is
    cursor cur_material is
      select f.art_cod_art
        from pr_for_ins f
             join articul a on f.art_cod_art = a.cod_art
       where f.formu_art_cod_art = p_formu_cod_art
         and (a.cod_lin between '1851' and '1857')
         and length(a.cod_lin) = 4;

    l_return pkg_types.maxvarchar2;
  begin
    for rec in cur_material loop
      l_return := l_return || ', ' || rec.art_cod_art;
    end loop;

    return substr(l_return, 3);
  end ;

  function subpieza(
    p_formu_cod_art pr_for_ins.formu_art_cod_art%type
  )
    return varchar2 is
    cursor cur_material is
      select f.art_cod_art
        from pr_for_ins f
             join articul a on f.art_cod_art = a.cod_art
       where f.formu_art_cod_art = p_formu_cod_art
         and ((a.cod_lin between '1871' and '1872') or (a.cod_lin between '1650' and '1661'))
         and length(a.cod_lin) = 4;

    l_return pkg_types.maxvarchar2;
  begin
    for rec in cur_material loop
      l_return := l_return || ', ' || rec.art_cod_art;
    end loop;

    return substr(l_return, 3);
  end ;

end surte_util;