create or replace function sf_es_embalaje(
  p_linea articul.cod_lin%type
) return boolean deterministic as
begin
  return length(p_linea) = 3 and p_linea between '800' and '899';
end;