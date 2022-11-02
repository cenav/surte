create or replace package surte_color as
  gc_completo constant surte_util.t_string := 'C';
  gc_partir constant surte_util.t_string := 'P';
  gc_faltante constant surte_util.t_string := 'F';
  gc_importado constant surte_util.t_string := 'I';
  gc_desarrollo constant surte_util.t_string := 'D';
  gc_armar constant surte_util.t_string := 'A';
  gc_reserva constant surte_util.t_string := 'R';

  type aat is table of color_surtimiento%rowtype index by varchar2(1);

  function all_rows return aat;

  function peso_mayor(
    p_old_peso number
  , p_new_peso number
  ) return boolean;
end surte_color;