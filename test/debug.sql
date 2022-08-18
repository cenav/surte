begin
  surte.parte_ot(p_tipo => 'AR', p_serie => '3', p_numero => 785207, p_cant_partir => 4000);
end;

select * from logger_logs order by id desc;