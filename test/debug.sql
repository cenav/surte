begin
  surte.parte_ot(p_tipo => 'AR', p_serie => '3', p_numero => 785051, p_cant_partir => 1500);
  commit;
end;

select * from logger_logs order by id desc;