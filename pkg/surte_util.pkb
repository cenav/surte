create or replace package body surte_util as

  function bool_to_logic(
    p_bool boolean
  ) return signtype is
  begin
    return case when p_bool then gc_true else gc_false end;
  end;

end surte_util;